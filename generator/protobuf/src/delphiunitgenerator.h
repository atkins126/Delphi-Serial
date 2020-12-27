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
        std::string name;
        std::string json_name;
        std::string type;
        bool required;
        bool repeated;
        bool packable;
        bool packed;
        int tag;
    };
    struct Enumerator
    {
        std::string name;
        int number;
        int isLast;
    };

    void Print(const FileDescriptor *desc);
    void Print(const Descriptor *desc);
    void Print(const EnumDescriptor *desc);
    void Print(const Enumerator &enumerator);
    void Print(const Field &field);

    std::vector<Enumerator> GetEnumerators(const EnumDescriptor *desc);
    std::vector<Field> GetFields(const Descriptor *desc);
    std::string GetFieldType(const FieldDescriptor *desc);

    std::map<std::string, std::string> _variables;
    std::set<std::string> _types;
    io::Printer _printer;

    bool _emitJsonNames = false;
};

#endif // DELPHIUNITGENERATOR_H
