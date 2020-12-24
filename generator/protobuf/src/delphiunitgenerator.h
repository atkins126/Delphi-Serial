#ifndef DELPHIUNITGENERATOR_H
#define DELPHIUNITGENERATOR_H

#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>

#include <list>

using namespace google::protobuf;

class DelphiUnitGenerator
{
public:
    DelphiUnitGenerator(const std::string &unitname,
                        const std::string &parameter,
                        io::ZeroCopyOutputStream *stream);

    void Generate(const FileDescriptor *desc);

private:
    struct Field
    {
        std::string name;
        std::string type;
        bool required;
        bool repeated;
        bool packable;
        bool packed;
        int tag;
    };

    void Print(const FileDescriptor *desc);
    void Print(const Descriptor *desc);
    void Print(const EnumDescriptor *desc);
    void Print(const EnumValueDescriptor *desc);
    void Print(const Field &field);

    std::list<Field> GetFields(const Descriptor *desc);
    std::string GetFieldType(const FieldDescriptor *desc);

    std::map<std::string, std::string> _parameters;
    std::map<std::string, std::string> _variables;
    std::set<std::string> _types;
    io::Printer _printer;
};

#endif // DELPHIUNITGENERATOR_H
