#include <google/protobuf/compiler/plugin.h>

#include "delphicodegenerator.h"

int main(int argc, char **argv)
{
    DelphiCodeGenerator generator;
    return google::protobuf::compiler::PluginMain(argc, argv, &generator);
}
