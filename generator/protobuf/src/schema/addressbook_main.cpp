#include "addressbook.pb.h"
#include "pbjson.h"

int print_usage()
{
    std::cerr << "Usage:" << std::endl;
    std::cerr << "  pbjson-addressbook [-r] <binary> <json>" << std::endl;
    return -1;
}

int main(int argc, char **argv)
{
    AddressBook addressbook;
    try {
        if (argc < 3) {
            return print_usage();
        } else if (std::strcmp(argv[1], "-r") == 0) {
            if (argc < 4) {
                return print_usage();
            }
            return convert_json_to_binary(addressbook, argv[3], argv[2]);
        } else {
            return convert_binary_to_json(addressbook, argv[1], argv[2]);
        }
    } catch (std::exception &e) {
        std::cerr << e.what() << std::endl;
        return -1;
    }
}
