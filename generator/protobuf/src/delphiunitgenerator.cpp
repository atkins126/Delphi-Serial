#include "delphiunitgenerator.h"

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
    if (_emitJsonNames) {
        _printer.Print(_variables, "Delphi.Serial,\n");
    }
    _printer.Print(_variables, "Delphi.Serial.Protobuf;\n\n");
    _printer.Outdent();
    _printer.Print(_variables, "type\n\n");
    _printer.Indent();
    for (int i = 0; i < desc->enum_type_count(); ++i) {
        Print(desc->enum_type(i));
    }
    for (int i = 0; i < desc->message_type_count(); ++i) {
        Print(desc->message_type(i));
    }
    _printer.Outdent();
    _printer.Print(_variables, "implementation\n\n");
    _printer.Print(_variables, "end.\n");
}

void DelphiUnitGenerator::Print(const Descriptor *desc)
{
    const auto recordname = GetRecordName(desc->name());
    if (_types.find(recordname) != _types.end())
        return;
    _types.insert(recordname);

    const auto fields = GetFields(desc);

    _variables["recordname"] = recordname;
    _printer.Print(_variables, "$recordname$ = record\n");
    _printer.Indent();
    for (auto &field : fields) {
        Print(field);
    }
    _printer.Outdent();
    _printer.Print(_variables, "end;\n\n");
}

void DelphiUnitGenerator::Print(const EnumDescriptor *desc)
{
    const auto enumname = GetEnumName(desc->name());
    if (_types.find(enumname) != _types.end())
        return;
    _types.insert(enumname);

    const auto enumerators = GetEnumerators(desc);

    _variables["enumname"] = enumname;
    _printer.Print(_variables, "$enumname$ = (\n");
    _printer.Indent();
    int nextNumber = 0;
    for (auto &enumerator : enumerators) {
        for (int k = nextNumber; k < enumerator.number; ++k) {
            _variables["valuenumber"] = std::to_string(k);
            _printer.Print(_variables, "_unused$valuenumber$ = $valuenumber$,\n");
        }
        Print(enumerator);
        nextNumber = enumerator.number + 1;
    }
    _printer.Outdent();
    _printer.Print(_variables, ");\n\n");
}

void DelphiUnitGenerator::Print(const Enumerator &enumerator)
{
    _variables["valuename"] = GetCamelCase(ToLower(enumerator.name));
    _variables["valuenumber"] = std::to_string(enumerator.number);
    if (enumerator.isLast) {
        _printer.Print(_variables, "$valuename$ = $valuenumber$\n");
    } else {
        _printer.Print(_variables, "$valuename$ = $valuenumber$,\n");
    }
}

void DelphiUnitGenerator::Print(const Field &field)
{
    std::string fieldoptions;
    if (field.required) {
        fieldoptions += ", Required";
    }
    if (field.packable && !field.packed) {
        fieldoptions += ", UnPacked";
    }
    if (_emitJsonNames) {
        fieldoptions += ", FieldName('" + field.json_name + "')";
    }
    _variables["fieldname"] = field.name;
    _variables["fieldtype"] = field.repeated ? GetArrayType(field.type) : field.type;
    _variables["fieldtag"] = std::to_string(field.tag);
    _variables["fieldoptions"] = fieldoptions;
    _printer.Print(_variables, "[FieldTag($fieldtag$)$fieldoptions$] $fieldname$: $fieldtype$;\n");
}

std::vector<DelphiUnitGenerator::Enumerator> DelphiUnitGenerator::GetEnumerators(
    const EnumDescriptor *desc)
{
    std::vector<Enumerator> result;
    result.reserve(desc->value_count());
    for (int i = 0; i < desc->value_count(); ++i) {
        const auto value = desc->value(i);
        result.push_back({value->name(), value->number(), false});
    }
    std::sort(result.begin(), result.end(), [](const Enumerator &lhs, const Enumerator &rhs) {
        return lhs.number < rhs.number;
    });
    result.back().isLast = true;
    return result;
}

std::vector<DelphiUnitGenerator::Field> DelphiUnitGenerator::GetFields(const Descriptor *desc)
{
    std::vector<Field> result;
    result.reserve(desc->field_count());
    for (int i = 0; i < desc->field_count(); ++i) {
        const auto field = desc->field(i);
        result.push_back({GetFieldName(field->name()),
                          field->json_name(),
                          GetFieldType(field),
                          field->is_required(),
                          field->is_repeated(),
                          field->is_packable(),
                          field->is_packed(),
                          field->number()});
    }
    return result;
}

std::string DelphiUnitGenerator::GetFieldType(const FieldDescriptor *desc)
{
    switch (desc->type()) {
    case FieldDescriptor::TYPE_ENUM:
        Print(desc->enum_type());
        return GetEnumName(desc->enum_type()->name());
    case FieldDescriptor::TYPE_GROUP:
    case FieldDescriptor::TYPE_MESSAGE:
        Print(desc->message_type());
        return GetRecordName(desc->message_type()->name());
    default:
        return desc->type_name();
    }
}
