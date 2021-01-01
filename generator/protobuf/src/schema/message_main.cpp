#include "message.pb.h"
#include "pbjson.h"

int print_usage()
{
    std::cerr << "Usage:" << std::endl;
    std::cerr << "  pbjson-message [-r] <binary> <json>" << std::endl;
    return -1;
}

int main(int argc, char **argv)
{
    Message message;
    try {
        if (argc < 3) {
            return print_usage();
        } else if (std::strcmp(argv[1], "-r") == 0) {
            if (argc < 4) {
                return print_usage();
            }
            return convert_json_to_binary(message, argv[3], argv[2]);
        } else {
            return convert_binary_to_json(message, argv[1], argv[2]);
        }
    } catch (std::exception &e) {
        std::cerr << e.what() << std::endl;
        return -1;
    }
}
