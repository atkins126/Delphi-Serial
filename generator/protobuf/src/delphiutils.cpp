#include "delphiutils.h"

std::string GetCamelCase(const std::string &name)
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
