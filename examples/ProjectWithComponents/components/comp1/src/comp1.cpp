#include "PWC/core/core.hpp"
#include "PWC/comp1/comp1.hpp"
#include <cstdio>

void comp1_print_message(const char* text)
{
    std::puts("From comp1:");
    core_print(text);
    return;
};