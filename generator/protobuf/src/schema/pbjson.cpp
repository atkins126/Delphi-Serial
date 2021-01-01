#include "pbjson.h"

#include <fstream>

#include <google/protobuf/util/json_util.h>

int convert_binary_to_json(google::protobuf::Message &message,
                           const char *inputPath,
                           const char *outputPath)
{
    std::ifstream istream(inputPath);
    if (!message.ParseFromIstream(&istream)) {
        std::cerr << "Could not parse the input file: " << inputPath << std::endl;
        return -1;
    }
    std::string json;
    google::protobuf::util::JsonPrintOptions options;
    options.add_whitespace = true;
    const auto status = google::protobuf::util::MessageToJsonString(message, &json, options);
    if (status.ok()) {
        std::ofstream(outputPath) << json;
    } else {
        std::cerr << status.error_message() << std::endl;
    }
    return status.error_code();
}

int convert_json_to_binary(google::protobuf::Message &message,
                           const char *inputPath,
                           const char *outputPath)
{
    std::string json;
    std::ifstream(inputPath) >> json;
    google::protobuf::util::JsonParseOptions options;
    options.case_insensitive_enum_parsing = true;
    const auto status = google::protobuf::util::JsonStringToMessage(json, &message, options);
    if (status.ok()) {
        std::ofstream ostream(outputPath);
        if (!message.SerializeToOstream(&ostream)) {
            std::cerr << "Could not write to the output file: " << outputPath << std::endl;
            return -1;
        }
    } else {
        std::cerr << status.error_message() << std::endl;
    }
    return status.error_code();
}
