#ifndef DELPHIUTILS_H
#define DELPHIUTILS_H

#include <algorithm>
#include <string>

std::string GetPascalCase(const std::string &name);
bool StartsWith(const std::string &value, const std::string &prefix, bool ignoreCase = false);

inline std::string ToLower(const std::string &name)
{
    auto result = name;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

inline std::string ToUpper(const std::string &name)
{
    auto result = name;
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}

inline std::string GetFullName(const std::string &name)
{
    auto result = GetPascalCase(name);
    result.erase(std::remove(result.begin(), result.end(), '.'), result.end());
    return result;
}

inline std::string GetRecordName(const std::string &name)
{
    return "T" + GetFullName(name);
}

inline std::string GetUnitName(const std::string &name)
{
    auto result = GetPascalCase(name);
    std::replace(result.begin(), result.end(), '/', '.');
    return result;
}

inline std::string GetEnumName(const std::string &name)
{
    return "T" + GetFullName(name);
}

inline std::string GetEnumValueName(const std::string &name, const std::string &prefix)
{
    auto result = GetPascalCase(ToLower(name));
    if (StartsWith(result, prefix, true))
        result.erase(0, prefix.length());
    return result;
}

inline std::string GetFieldName(const std::string &name)
{
    return "F" + GetPascalCase(name);
}

inline std::string GetArrayType(const std::string &name)
{
    return "TArray<" + name + ">";
}

#endif // DELPHIUTILS_H
