#include "delphicodegenerator.h"

#include <google/protobuf/io/zero_copy_stream.h>

#include "delphiunitgenerator.h"
#include "delphiutils.h"

DelphiCodeGenerator::DelphiCodeGenerator()
{
    
}

bool DelphiCodeGenerator::Generate(const FileDescriptor *file,
                                   const std::string &parameter,
                                   compiler::GeneratorContext *generator_context,
                                   std::string *error) const
{
    try {
        const auto unitname = GetUnitName(file->name());
        std::vector<std::pair<std::string, std::string>> parameters;
        compiler::ParseGeneratorParameter(parameter, &parameters);
        std::unique_ptr<io::ZeroCopyOutputStream> stream(generator_context->Open(unitname + ".pas"));
        DelphiUnitGenerator generator(unitname, parameters, stream.get());
        generator.Generate(file);
    } catch (std::exception &e) {
        *error = e.what();
        return false;
    }
    return true;
}
