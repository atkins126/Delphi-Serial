#include "pbjson.h"

#include <fstream>

#include <google/protobuf/stubs/logging.h>
#include <google/protobuf/util/json_util.h>

int convert_binary_to_json(google::protobuf::Message &message,
                           const char *inputPath,
                           const char *outputPath)
{
    std::ifstream istream(inputPath, std::ios::binary);
    if (!message.ParseFromIstream(&istream)) {
        GOOGLE_LOG(ERROR) << "Could not parse the input file: " << inputPath;
        return -1;
    }
    std::string json;
    google::protobuf::util::JsonPrintOptions options;
    options.add_whitespace = true;
    const auto status = google::protobuf::util::MessageToJsonString(message, &json, options);
    if (status.ok()) {
        std::ofstream(outputPath) << json;
    } else {
        GOOGLE_LOG(ERROR) << status.error_message();
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
        std::ofstream ostream(outputPath, std::ios::binary);
        if (!message.SerializeToOstream(&ostream)) {
            GOOGLE_LOG(ERROR) << "Could not write to the output file: " << outputPath;
            return -1;
        }
    } else {
        GOOGLE_LOG(ERROR) << status.error_message();
    }
    return status.error_code();
}
