#ifndef DELPHIUTILS_H
#define DELPHIUTILS_H

#include <string>

std::string GetCamelCase(const std::string &name);

inline std::string GetRecordName(const std::string &name)
{
    return "T" + GetCamelCase(name);
}

inline std::string GetEnumName(const std::string &name)
{
    return "T" + GetCamelCase(name);
}

inline std::string GetFieldName(const std::string &name)
{
    return "F" + GetCamelCase(name);
}

inline std::string GetArrayType(const std::string &name)
{
    return "TArray<" + name + ">";
}

#endif // DELPHIUTILS_H
