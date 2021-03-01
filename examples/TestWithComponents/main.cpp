#include <PWC/comp1/comp1.hpp>
#include <PWC/comp2/comp2.hpp>

#include <cstdlib>
#include <cstdio>

int main()
{
    std::puts("Hello World from CMakeJSON!");
    comp2_print_message("Call comp2: Hello World!");
    comp1_print_message("Call comp1: Hello World!");
    return EXIT_SUCCESS;
}