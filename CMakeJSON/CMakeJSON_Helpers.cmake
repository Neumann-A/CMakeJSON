macro(cmakejson_create_function_parse_arguments_prefix)
    #string(REGEX REPLACE  "_([a-zA-Z])[^_]+" "\\1" ${ARGV0} "${CMAKE_CURRENT_FUNCTION}")
    string(REPLACE "cmakejson" "_cmakejson_" ${ARGV0} "${CMAKE_CURRENT_FUNCTION}")
endmacro()

macro(cmakejson_print_variables_if _if)
    if(${_if})
        cmake_print_variables(${ARGN})
    endif()
endmacro()
#TODO: Validate all fields in the input

macro(cmakejson_return_to_parent_scope)
    list(APPEND CMAKE_MESSAGE_CONTEXT "return")
    foreach(arg IN ITEMS ${ARGN})
        set(${arg} ${${arg}} PARENT_SCOPE)
        cmakejson_print_variables_if(CMakeJSON_DEBUG_RETURN_PARENT ${arg})
    endforeach()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()

macro(cmakejson_message_if _if)
    if(${_if})
        message("${ARGN}")
    endif()
endmacro()

macro(cmakejson_variable_exists_or_error_impl)
    set(_VAR_PREFIX cmakejson_variable_exists_or_error_impl)
    cmake_parse_arguments("${_VAR_PREFIX}" "" "PREFIX" "VARIABLE_NAMES" ${ARGN})
    foreach(_variable IN LISTS _cmcs_eoe_impl_VARIABLE_NAMES)
        if(DEFINED ${_VAR_PREFIX}_PREFIX AND NOT ${${_VAR_PREFIX}_PREFIX} MATCHES "^[\\\t ]+$") 
            # Variables are prefixed 
            if(NOT DEFINED ${${_VAR_PREFIX}_PREFIX}_${_variable} OR ${${_VAR_PREFIX}_PREFIX}_${_variable} MATCHES "^[\\\t ]+$")
                message(${CMakeJSON_MSG_ERROR_TYPE} "Function '${CMAKE_CURRENT_FUNCTION}' requires parameter ${_variable}! (prefixed)")
            endif()
        else() 
            # Variables are not prefixed 
            if(NOT DEFINED ${_variable} OR "x${_variable}x" STREQUAL "xx")
                message(${CMakeJSON_MSG_ERROR_TYPE} "Function '${CMAKE_CURRENT_FUNCTION}' requires parameter ${_variable}!")
            endif()
        endif()
    endforeach()
endmacro()

function(cmakejson_variable_exists_or_error)
    set(_VAR_PREFIX cmakejson_variable_exists_or_error)
    cmake_parse_arguments("${_VAR_PREFIX}" "" "PREFIX" "VARIABLE_NAMES" ${ARGN})
    cmakejson_variable_exists_or_error_impl(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "VARIABLE_NAMES")
    cmakejson_variable_exists_or_error_impl(PREFIX ${${_VAR_PREFIX}_PREFIX} VARIABLE_NAMES ${${_VAR_PREFIX}_VARIABLE_NAMES})
endfunction()


### CMakeJSON Property Helpers
# Global property helpers
function(cmakejson_define_global_property)
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    #cmake_print_variables(${_VAR_PREFIX}_UNPARSED_ARGUMENTS)
    define_property(GLOBAL PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} INHERITED ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
endfunction()
function(cmakejson_set_global_property)
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "APPEND_OPTION;PREFIX;PROPERTY;VARIABLE" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY;VARIABLE")
    if(${_VAR_PREFIX}_PREFIX)
        set_property(GLOBAL ${${_VAR_PREFIX}_APPEND_OPTION} PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${${_VAR_PREFIX}_PREFIX}_${${_VAR_PREFIX}_PROPERTY}} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    else()
        set_property(GLOBAL ${${_VAR_PREFIX}_APPEND_OPTION} PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${${_VAR_PREFIX}_PROPERTY}} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    endif()
endfunction()
function(cmakejson_get_global_property)
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "PREFIX;PROPERTY;VARIABLE" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY;VARIABLE")
    if(${_VAR_PREFIX}_PREFIX)
        get_property(${${_VAR_PREFIX}_PREFIX}_${${_VAR_PREFIX}_PROPERTY} GLOBAL PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
        cmakejson_return_to_parent_scope(${${_VAR_PREFIX}_PREFIX}_${${_VAR_PREFIX}_PROPERTY})
    else()
        get_property(${${_VAR_PREFIX}_PROPERTY} GLOBAL PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
        cmakejson_return_to_parent_scope(${${_VAR_PREFIX}_PROPERTY})
    endif()
endfunction()

# Scoped (Directory) property helpers
function(cmakejson_define_directory_property)
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "INHERITED" "PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    #cmake_print_variables(${_VAR_PREFIX}_UNPARSED_ARGUMENTS)
    set(${_VAR_PREFIX}_OPTIONS)
    if(${_VAR_PREFIX}_INHERITED)
        list(APPEND ${_VAR_PREFIX}_OPTIONS INHERITED)
    endif()
    define_property(DIRECTORY PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_OPTIONS} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
endfunction()

function(cmakejson_set_directory_property)
    list(APPEND CMAKE_MESSAGE_CONTEXT "set_directory_property")
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "APPEND_OPTION;PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    set_property(DIRECTORY ${${_VAR_PREFIX}_APPEND_OPTION} PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()
function(cmakejson_get_directory_property)
    list(APPEND CMAKE_MESSAGE_CONTEXT "get_directory_property")
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    get_property(${${_VAR_PREFIX}_PROPERTY} DIRECTORY PROPERTY _CMakeJSON_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    cmakejson_return_to_parent_scope(${${_VAR_PREFIX}_PROPERTY})
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()


function(cmakejson_set_project_property)
    list(APPEND CMAKE_MESSAGE_CONTEXT "set_project_property")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    cmakejson_get_directory_property(PROPERTY ${CURRENT_PROJECT}_DIRECTORY)
    set(CURRENT_PROJECT_DIRECTORY ${${CURRENT_PROJECT}_DIRECTORY})
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "APPEND_OPTION;PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    set_property(DIRECTORY "${CURRENT_PROJECT_DIRECTORY}" ${${_VAR_PREFIX}_APPEND_OPTION} PROPERTY _CMakeJSON_${CURRENT_PROJECT}_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_get_project_property)
list(APPEND CMAKE_MESSAGE_CONTEXT "get_project_property")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    cmakejson_get_directory_property(PROPERTY ${CURRENT_PROJECT}_DIRECTORY)
    set(CURRENT_PROJECT_DIRECTORY ${${CURRENT_PROJECT}_DIRECTORY})
    if(NOT CURRENT_PROJECT)
        message(${CMakeJSON_MSG_ERROR_TYPE} "cmakejson_get_project_property called without CURRENT_PROJECT being set!")
    endif()
    cmakejson_create_function_parse_arguments_prefix(_VAR_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_VAR_PREFIX}" "" "PROPERTY" "")
    cmakejson_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "PROPERTY")
    get_property(${${_VAR_PREFIX}_PROPERTY} DIRECTORY "${CURRENT_PROJECT_DIRECTORY}" PROPERTY _CMakeJSON_${CURRENT_PROJECT}_${${_VAR_PREFIX}_PROPERTY} ${${_VAR_PREFIX}_UNPARSED_ARGUMENTS})
    cmakejson_return_to_parent_scope(${${_VAR_PREFIX}_PROPERTY})
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

### 