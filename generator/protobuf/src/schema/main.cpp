#include <fstream>
#include <ostream>

#include <google/protobuf/util/json_util.h>

#include "addressbook.pb.h"

int print_usage()
{
    std::cerr << "Usage:" << std::endl;
    std::cerr << "  pbjson-addressbook [-r] <binary> <json>" << std::endl;
    return -1;
}

int convert_binary_to_json(const char *inputPath, const char *outputPath)
{
    tutorial::AddressBook addressbook;
    std::ifstream istream(inputPath);
    addressbook.ParseFromIstream(&istream);
    std::string json;
    google::protobuf::util::JsonPrintOptions options;
    google::protobuf::util::MessageToJsonString(addressbook, &json, options);
    std::ofstream(outputPath) << json;
    return 0;
}

int convert_json_to_binary(const char *inputPath, const char *outputPath)
{
    std::string json;
    std::ifstream(inputPath) >> json;
    tutorial::AddressBook addressbook;
    google::protobuf::util::JsonParseOptions options;
    google::protobuf::util::JsonStringToMessage(json, &addressbook, options);
    std::ofstream ostream(outputPath);
    addressbook.SerializeToOstream(&ostream);
    return 0;
}

int main(int argc, char **argv)
{
    try {
        if (argc < 3) {
            return print_usage();
        } else if (std::strcmp(argv[1], "-r") == 0) {
            if (argc < 4) {
                return print_usage();
            }
            return convert_json_to_binary(argv[3], argv[2]);
        } else {
            return convert_binary_to_json(argv[1], argv[2]);
        }
    } catch (std::exception &e) {
        std::cerr << e.what() << std::endl;
        return -1;
    }
}
