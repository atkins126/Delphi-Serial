#include "delphiunitgenerator.h"

#include "delphiutils.h"

DelphiUnitGenerator::DelphiUnitGenerator(const std::string &unitname,
                                         const std::string &parameter,
                                         io::ZeroCopyOutputStream *stream)
    : _printer(stream, '$')
{
    _variables["unitname"] = unitname;
    // init parameters
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

    _variables["enumname"] = enumname;
    _printer.Print(_variables, "$enumname$ = (\n");
    _printer.Indent();
    for (int i = 0; i < desc->value_count(); ++i) {
        Print(desc->value(i));
    }
    _printer.Outdent();
    _printer.Print(_variables, ");\n\n");
}

void DelphiUnitGenerator::Print(const EnumValueDescriptor *desc)
{
    auto name = desc->name();
    std::transform(name.begin(), name.end(), name.begin(), [](unsigned char c) {
        return std::tolower(c);
    });
    _variables["valuename"] = GetCamelCase(name);
    _variables["valuenumber"] = std::to_string(desc->number());
    if (desc->index() == desc->type()->value_count() - 1) {
        _printer.Print(_variables, "$valuename$ = $valuenumber$\n");
    } else {
        _printer.Print(_variables, "$valuename$ = $valuenumber$,\n");
    }
}

void DelphiUnitGenerator::Print(const Field &field)
{
    _variables["fieldname"] = field.name;
    _variables["fieldtype"] = field.type;
    _variables["fieldtag"] = std::to_string(field.tag);
    _printer.Print(_variables, "[Protobuf($fieldtag$)] $fieldname$: $fieldtype$;\n");
}

std::list<DelphiUnitGenerator::Field> DelphiUnitGenerator::GetFields(const Descriptor *desc)
{
    std::list<Field> result;
    for (int i = 0; i < desc->field_count(); ++i) {
        const auto field = desc->field(i);
        const auto fieldname = GetFieldName(field->name());
        auto fieldtype = GetFieldType(field);
        if (field->is_repeated()) {
            fieldtype = GetArrayType(fieldtype);
        }
        result.push_back({fieldname, fieldtype, field->number()});
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
