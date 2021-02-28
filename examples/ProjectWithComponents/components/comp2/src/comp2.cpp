#include "PWC/core/core.hpp"
#include "PWC/comp1/comp1.hpp"
#include "PWC/comp2/comp2.hpp"
#include <cstdio>

void comp2_print_message(const char* text)
{
    std::puts("From comp2:");
    comp1_print_message(text);
    core_print(text);
    return;
};