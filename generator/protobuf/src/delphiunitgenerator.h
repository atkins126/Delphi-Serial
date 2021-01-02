#ifndef DELPHIUNITGENERATOR_H
#define DELPHIUNITGENERATOR_H

#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>

using namespace google::protobuf;

class DelphiUnitGenerator
{
public:
    DelphiUnitGenerator(const std::string &unitname,
                        const std::vector<std::pair<std::string, std::string>> &parameters,
                        io::ZeroCopyOutputStream *stream);

    void Generate(const FileDescriptor *desc);

private:
    struct Field
    {
        std::string type;
        const FieldDescriptor *desc;
    };
    struct EnumValue
    {
        std::string name;
        int number;
        int isLast;
    };
    struct EnumContext
    {
        std::string nameprefix;
        std::map<std::string, int> names;
        int nextNumber = 0;
    };

    void Print(const FileDescriptor *desc);
    std::string Print(const Descriptor *desc);
    std::string Print(const EnumDescriptor *desc);
    void Print(const EnumValue &enumerator, EnumContext &context);
    void Print(const EnumValue &enumerator);
    void Print(const Field &field);
    void Print(const OneofDescriptor *oneof, bool closePrevious);

    std::vector<EnumValue> GetEnumValues(const EnumDescriptor *desc);
    std::vector<EnumValue> GetEnumValues(const OneofDescriptor *desc);
    std::vector<Field> GetFields(const Descriptor *desc);
    std::string GetFieldType(const FieldDescriptor *desc);
    std::string GetFieldOptions(const FieldDescriptor *desc);
    static std::string GetFieldDefault(const FieldDescriptor *desc);

    std::map<std::string, std::string> _variables;
    std::set<std::string> _types;
    io::Printer _printer;

    bool _emitJsonNames = false;
    bool _emitUnusedTypes = false;
};

#endif // DELPHIUNITGENERATOR_H
