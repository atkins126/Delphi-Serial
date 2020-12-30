#ifndef DELPHIUTILS_H
#define DELPHIUTILS_H

#include <algorithm>
#include <string>

std::string GetCamelCase(const std::string &name);

inline std::string GetFullName(const std::string &name)
{
    auto result = GetCamelCase(name);
    result.erase(std::remove(result.begin(), result.end(), '.'), result.end());
    return result;
}

inline std::string GetRecordName(const std::string &name)
{
    return "T" + GetFullName(name);
}

inline std::string GetUnitName(const std::string &name)
{
    auto result = GetCamelCase(name);
    std::replace(result.begin(), result.end(), '/', '.');
    return result;
}

inline std::string GetEnumName(const std::string &name)
{
    return "T" + GetFullName(name);
}

inline std::string GetFieldName(const std::string &name)
{
    return "F" + GetCamelCase(name);
}

inline std::string GetArrayType(const std::string &name)
{
    return "TArray<" + name + ">";
}

inline std::string ToLower(const std::string &name)
{
    auto result = name;
    std::transform(result.begin(), result.end(), result.begin(), [](unsigned char c) {
        return std::tolower(c);
    });
    return result;
}

inline std::string ToUpper(const std::string &name)
{
    auto result = name;
    std::transform(result.begin(), result.end(), result.begin(), [](unsigned char c) {
        return std::toupper(c);
    });
    return result;
}

#endif // DELPHIUTILS_H
