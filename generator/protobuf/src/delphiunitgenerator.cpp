#include "delphiunitgenerator.h"

#include <google/protobuf/stubs/logging.h>

#include "delphiutils.h"

DelphiUnitGenerator::DelphiUnitGenerator(
    const std::string &unitname,
    const std::vector<std::pair<std::string, std::string>> &parameters,
    io::ZeroCopyOutputStream *stream)
    : _printer(stream, '$')
{
    _variables["unitname"] = unitname;
    for (const auto &pair : parameters) {
        if (pair.first == "emit_json_names") {
            _emitJsonNames = true;
        } else if (pair.first == "emit_unused_types") {
            _emitUnusedTypes = true;
        }
    }
}

void DelphiUnitGenerator::Generate(const FileDescriptor *desc)
{
    Print(desc);
}

void DelphiUnitGenerator::Print(const FileDescriptor *desc)
{
    _printer.Print(_variables, "unit $unitname$;\n\n");
    _printer.Print(_variables, "{$$SCOPEDENUMS ON}\n\n");
    _printer.Print(_variables, "interface\n\n");
    _printer.Print(_variables, "uses\n");
    _printer.Indent();
    _printer.Print(_variables, "Delphi.Serial;\n\n");
    _printer.Outdent();
    _printer.Print(_variables, "type\n\n");
    _printer.Indent();
    if (_emitUnusedTypes) {
        for (int i = 0; i < desc->enum_type_count(); ++i) {
            Print(desc->enum_type(i));
        }
    }
    for (int i = 0; i < desc->message_type_count(); ++i) {
        Print(desc->message_type(i));
    }
    _printer.Outdent();
    _printer.Print(_variables, "implementation\n\n");
    _printer.Print(_variables, "end.\n");
}

std::string DelphiUnitGenerator::Print(const Descriptor *desc)
{
    const auto recordname = GetRecordName(desc->full_name());
    if (!_types.emplace(recordname).second)
        return recordname;

    if (_emitUnusedTypes) {
        for (int i = 0; i < desc->enum_type_count(); ++i) {
            Print(desc->enum_type(i));
        }
        for (int i = 0; i < desc->nested_type_count(); ++i) {
            Print(desc->nested_type(i));
        }
    }
    const auto fields = GetFields(desc);

    _variables["recordname"] = recordname;
    _printer.Print(_variables, "$recordname$ = record\n");
    _printer.Indent();
    const OneofDescriptor *oneof = nullptr;
    for (const auto &field : fields) {
        if (field.oneof != oneof) {
            Print(field.oneof, oneof);
            oneof = field.oneof;
        }
        Print(field);
    }
    Print(nullptr, oneof);
    _printer.Outdent();
    _printer.Print(_variables, "end;\n\n");
    return recordname;
}

std::string DelphiUnitGenerator::Print(const EnumDescriptor *desc)
{
    const auto enumname = GetEnumName(desc->full_name());
    if (!_types.emplace(enumname).second)
        return enumname;

    _variables["enumname"] = enumname;
    _printer.Print(_variables, "$enumname$ = (\n");
    _printer.Indent();
    EnumContext context;
    context.nameprefix = GetPascalCase(desc->name());
    for (const auto &enumerator : GetEnumValues(desc)) {
        Print(enumerator, context);
    }
    _printer.Outdent();
    _printer.Print(_variables, ");\n\n");
    return enumname;
}

void DelphiUnitGenerator::Print(const EnumValue &value, EnumContext &context)
{
    const auto valuename = GetEnumValueName(value.name, context.nameprefix);
    if (!context.names.emplace(ToLower(valuename), value.number).second) {
        GOOGLE_LOG(WARNING)
            << "Enum name ignored because it would result in identifier redeclared: " << value.name;
        return;
    }
    for (int k = context.nextNumber; k < value.number; ++k) {
        _variables["valuenumber"] = std::to_string(k);
        _printer.Print(_variables, "_unused$valuenumber$ = $valuenumber$,\n");
    }
    _variables["valuename"] = valuename;
    _variables["valuenumber"] = std::to_string(value.number);
    if (value.isLast) {
        _printer.Print(_variables, "&$valuename$ = $valuenumber$\n");
    } else {
        _printer.Print(_variables, "&$valuename$ = $valuenumber$,\n");
    }
    context.nextNumber = value.number + 1;
}

void DelphiUnitGenerator::Print(const EnumValue &value)
{
    _variables["valuename"] = GetFullName(value.name);
    _variables["valuenumber"] = std::to_string(value.number);
    if (value.isLast) {
        _printer.Print(_variables, "&$valuename$ = $valuenumber$\n");
    } else {
        _printer.Print(_variables, "&$valuename$ = $valuenumber$,\n");
    }
}

void DelphiUnitGenerator::Print(const Field &field)
{
    const auto fieldoptions = GetFieldOptions(field);
    _variables["fieldname"] = GetFieldName(field.name);
    _variables["fieldtype"] = field.repeated ? GetArrayType(field.type) : field.type;
    _variables["fieldtag"] = std::to_string(field.tag);
    _variables["fieldoptions"] = fieldoptions;
    _printer.Print(_variables, "[FieldTag($fieldtag$)$fieldoptions$] $fieldname$: $fieldtype$;\n");
}

std::string DelphiUnitGenerator::GetFieldOptions(const DelphiUnitGenerator::Field &field)
{
    std::string result;
    if (field.required) {
        result += ", Required";
    }
    if (field.packable && !field.packed) {
        result += ", UnPacked";
    }
    if (_emitJsonNames) {
        result += ", FieldName('" + field.json_name + "')";
    }
    return result;
}

void DelphiUnitGenerator::Print(const OneofDescriptor *oneof, bool closePrevious)
{
    if (closePrevious) {
        _printer.Outdent();
        _printer.Print(_variables, "end;\n");
    }
    if (oneof) {
        _variables["fieldname"] = GetFieldName(oneof->name());
        _printer.Print(_variables, "[Oneof] $fieldname$: record\n");
        _printer.Indent();
        _printer.Print(_variables, "[Oneof] FCase: (\n");
        _printer.Indent();
        for (const auto &enumerator : GetEnumValues(oneof)) {
            Print(enumerator);
        }
        _printer.Outdent();
        _printer.Print(_variables, ");\n");
    }
}

auto DelphiUnitGenerator::GetEnumValues(const EnumDescriptor *desc) -> std::vector<EnumValue>
{
    std::vector<EnumValue> result;
    result.reserve(desc->value_count());
    for (int i = 0; i < desc->value_count(); ++i) {
        const auto value = desc->value(i);
        result.push_back({value->name(), value->number(), false});
    }
    std::sort(result.begin(), result.end(), [](const EnumValue &lhs, const EnumValue &rhs) {
        return lhs.number < rhs.number;
    });
    result.back().isLast = true;
    return result;
}

auto DelphiUnitGenerator::GetEnumValues(const OneofDescriptor *desc) -> std::vector<EnumValue>
{
    std::vector<EnumValue> result;
    result.reserve(desc->field_count() + 1);
    result.push_back({desc->full_name() + "Unspecified", 0, false});
    for (int i = 0; i < desc->field_count(); ++i) {
        const auto field = desc->field(i);
        assert(i == field->index_in_oneof());
        result.push_back({field->full_name(), i + 1, false});
    }
    result.back().isLast = true;
    return result;
}

auto DelphiUnitGenerator::GetFields(const Descriptor *desc) -> std::vector<Field>
{
    std::vector<Field> result;
    result.reserve(desc->field_count());
    for (int i = 0; i < desc->field_count(); ++i) {
        const auto field = desc->field(i);
        result.push_back({field->name(),
                          field->json_name(),
                          GetFieldType(field),
                          field->is_required(),
                          field->is_repeated(),
                          field->is_packable(),
                          field->is_packed(),
                          field->number(),
                          field->containing_oneof()});
    }
    return result;
}

std::string DelphiUnitGenerator::GetFieldType(const FieldDescriptor *desc)
{
    switch (desc->type()) {
    case FieldDescriptor::TYPE_ENUM:
        return Print(desc->enum_type());
    case FieldDescriptor::TYPE_GROUP:
    case FieldDescriptor::TYPE_MESSAGE:
        return Print(desc->message_type());
    default:
        return desc->type_name();
    }
}
