
#include "simple.hpp"
#include "simple_private.hpp"

#include <cstdio>

void hello_from_library()
{
    std::puts(hello_private.data());
}