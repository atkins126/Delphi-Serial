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
        auto unitname = GetCamelCase(file->name());
        std::replace(unitname.begin(), unitname.end(), '/', '.');
        std::unique_ptr<io::ZeroCopyOutputStream> stream(generator_context->Open(unitname + ".pas"));
        DelphiUnitGenerator generator(unitname, parameter, stream.get());
        generator.Generate(file);
    } catch (std::exception &e) {
        *error = e.what();
        return false;
    }
    return true;
}
