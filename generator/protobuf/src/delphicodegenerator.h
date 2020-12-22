#ifndef DELPHICODEGENERATOR_H
#define DELPHICODEGENERATOR_H

#include <google/protobuf/compiler/code_generator.h>

using namespace google::protobuf;

class DelphiCodeGenerator : public compiler::CodeGenerator
{
public:
    DelphiCodeGenerator();

    virtual bool Generate(const FileDescriptor *file,
                          const std::string &parameter,
                          compiler::GeneratorContext *generator_context,
                          std::string *error) const;
};

#endif // DELPHICODEGENERATOR_H
