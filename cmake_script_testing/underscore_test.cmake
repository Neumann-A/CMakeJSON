cmake_minimum_required(VERSION 3.19)
include(CMakePrintHelpers)
function(get_required_underscores underscores_out command_in)
    set(_under "")
    if(COMMAND _${command_in})
        get_required_underscores(_under _${command_in})
        set(_under "_${_under}")
    endif()
    set(${underscores_out} "${_under}" PARENT_SCOPE)
endfunction()

macro(test)
endmacro()

# macro(_test)
# endmacro()

# macro(__test)
# endmacro()

get_required_underscores(CMAKEJSON_PROJECT_UNDERSCORES test)

cmake_print_variables(CMAKEJSON_PROJECT_UNDERSCORES)