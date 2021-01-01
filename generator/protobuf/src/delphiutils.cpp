#include "delphiutils.h"

std::string GetPascalCase(const std::string &name)
{
    auto isAlpha = false;
    std::string result;
    for (auto &ch : name) {
        if (ch == '_') {
            isAlpha = false;
        } else if (!std::isalpha(ch)) {
            result += ch;
            isAlpha = false;
        } else if (isAlpha) {
            result += ch;
        } else {
            result += std::toupper(ch);
            isAlpha = true;
        }
    }
    return result;
}

bool StartsWith(const std::string &value, const std::string &prefix, bool ignoreCase)
{
    if (value.length() < prefix.length())
        return false;
    if (ignoreCase) {
        for (std::size_t i = 0; i < prefix.length(); ++i) {
            if (std::tolower(value[i]) != std::tolower(prefix[i])) {
                return false;
            }
        }
    } else {
        for (std::size_t i = 0; i < prefix.length(); ++i) {
            if (value[i] != prefix[i]) {
                return false;
            }
        }
    }
    return true;
}
