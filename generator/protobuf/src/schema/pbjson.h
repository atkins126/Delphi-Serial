#ifndef PBJSON_H
#define PBJSON_H

#include <google/protobuf/message.h>

int convert_binary_to_json(google::protobuf::Message &message,
                           const char *inputPath,
                           const char *outputPath);
int convert_json_to_binary(google::protobuf::Message &message,
                           const char *inputPath,
                           const char *outputPath);

#endif // PBJSON_H
