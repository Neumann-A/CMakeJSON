function(cmakejson_validate_project_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_set_project_parse_defaults)
endfunction()

function(cmakejson_set_project_parse_defaults)
endfunction()

function(cmakejson_project_option_setup _optprefix)
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PROJECT_OPTIONS _optprefix)
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_OPTIONS "Creating option '${${_optprefix}_VARIABLE}': '${${_optprefix}_DESCRIPTION}'")
    set(IS_BOOL_OPTION TRUE)
    set(HAS_TYPE FALSE)
    if(DEFINED ${${_optprefix}}_TYPE)
        set(HAS_TYPE TRUE)
        string(TOUPPER "${${_optprefix}}_TYPE" _type)
        if(NOT ${${_optprefix}}_TYPE STR "BOOL")
            set(IS_BOOL_OPTION FALSE)
        endif()
    endif()

    if(IS_BOOL_OPTION)
        set(OPT_FUNC option)
        set(OPT_PARAMS)
        if(DEFINED ${${_optprefix}}_CONDITION)
            if(${${_optprefix}}_CONDITION STREQUAL "")
                message(${CMakeJSON_MSG_WARNING_TYPE} "Value 'condition' for option '${${_optprefix}_VARIABLE}' is an empty string!")
            endif()
            if(NOT DEFINED ${_optprefix}_DEFAULT_VALUE)
                set(${_optprefix}_DEFAULT_VALUE OFF)
            endif()
            set(OPT_FUNC cmake_dependent_option)
            set(OPT_PARAMS "${${${_optprefix}}_CONDITION}" OFF)
        endif()
        cmake_language(CALL ${OPT_FUNC} "${${_optprefix}_VARIABLE}" "${${_optprefix}_DEFAULT_VALUE}" "${${_optprefix}_DESCRIPTION}" ${OPT_PARAMS})
        if(${${_optprefix}_VARIABLE})
            # TODO: Do something?
        endif()
        if(${${_optprefix}_DEPENDENCIES})
            # TODO: Setup dependency list. 
        endif()
    else()
        if(NOT DEFINED ${${_optprefix}_DEFAULT_VALUE})
            message(${CMakeJSON_MSG_WARNING_TYPE} "Missing 'default_value' for option '${${_optprefix}_VARIABLE}'! Assuming empty string.")
            set(${_optprefix}_DEFAULT_VALUE "")
        endif()
        set(${${_optprefix}_VARIABLE} "{${$_optprefix}_DEFAULT_VALUE}" CACHE ${${_optprefix}_TYPE} "${${_optprefix}_DESCRIPTION}")
        if(DEFINED ${$_optprefix}_VALID_VALUES)
            set_property(CACHE "${${_optprefix}_VARIABLE}" PROPERTY STRINGS "${${$_optprefix}_VALID_VALUES}")
            set(IS_VALID FALSE)
            foreach(_VALID IN LISTS ${$_optprefix}_VALID_VALUES)
                if("${_VALID}" STREQUAL "${${${_optprefix}_VARIABLE}}")
                    set(IS_VALID TRUE)
                endif()
            endforeach()
            if(NOT IS_VALID)
                message(${CMakeJSON_MSG_ERROR_TYPE} "Option '${${_optprefix}_VARIABLE}' has invalid value of '${${${_optprefix}_VARIABLE}}'! Valid values: ${${$_optprefix}_VALID_VALUES}")
            endif()
        endif()
    endif()
endfunction()

function(cmakejson_project_options)
    list(APPEND CMAKE_MESSAGE_CONTEXT "options")
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PROJECT_OPTIONS CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH)
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH OR CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH LESS_EQUAL 0)
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_OPTIONS VERBOSE "No project options found!")
        return()
    endif()
    math(EXPR range_length "${CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH}-1")
    foreach(json_index RANGE ${range_length})
        cmakejson_project_option_setup(CMakeJSON_PARSE_PROJECT_OPTIONS_${json_index})
    endforeach()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_setup_project)
    list(APPEND CMAKE_MESSAGE_CONTEXT "setup")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_determine_list_element)
    cmakejson_create_function_parse_arguments_prefix(_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_PREFIX}" "" "OUTPUT_FUNCTION;INPUT" "")
endfunction()

function(cmakejson_close_project)
endfunction()

function(cmakejson_project _input)
    list(APPEND CMAKE_MESSAGE_CONTEXT "project")

    cmakejson_validate_project_json("${_input}")

    list(APPEND CMAKE_MESSAGE_CONTEXT "parse")
    cmakejson_parse_json(JSON_INPUT "${_input}"
                         VARIABLE_PREFIX "PROJECT"
                         OUTPUT_LIST_CREATED_VARIABLES "PROJECT_PARSED_VARIABLES"
    )
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT STATUS "Variables created by project parse:")
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PROJECT PROJECT_PARSED_VARIABLES)

    if(DEFINED CMakeJSON_PARSE_PROJECT_CONDITION)
        if(NOT ${CMakeJSON_PARSE_PROJECT_CONDITION})
            list(POP_BACK CMAKE_MESSAGE_CONTEXT)
            return() # Skip project completly
        endif()
    endif()

    cmakejson_set_project_parse_defaults() # Setup some defaults if nothing has been passed
    if(CMakeJSON_USE_PROJECT_OVERRIDE) # Assume manual setup otherwise. 
        _project("${CMakeJSON_PARSE_PROJECT_NAME}"
                    VERSION "${CMakeJSON_PARSE_PROJECT_VERSION}"
                    DESCRIPTION "${CMakeJSON_PARSE_PROJECT_DESCRIPTION}"
                    HOMEPAGE_URL "${CMakeJSON_PARSE_PROJECT_HOMEPAGE}"
                    LANGUAGES ${CMakeJSON_PARSE_PROJECT_LANGUAGES}
                )
    else()
        if(NOT DEFINED PROJECT_NAME)
            message(FATAL_ERROR "CMakeJSON_USE_PROJECT_OVERRIDE is false and PROJECT_NAME is not defined!\nEither manually call project() or set CMakeJSON_USE_PROJECT_OVERRIDE to true!")
        endif()
    endif()
    cmakejson_project_options()
    cmakejson_setup_project()

    if(DEFINED "${CMakeJSON_PARSE_PROJECT_CUSTOM_STEPS}")
        if(${CMakeJSON_PARSE_PROJECT_CUSTOM_STEPS})
            cmakejson_message_if(CMakeJSON_DEBUG_PROJECT VERBOSE "Found field 'custom_steps' in project! Don't forget to call cmakejson_close_project() if finished!")
            list(POP_BACK CMAKE_MESSAGE_CONTEXT)
            return()
        endif()
    endif()
    cmakejson_close_project()

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()



# Simply load a file and pass contents further to cmakejson_project
function(cmakejson_project_file _file)
    #TODO: Decide wether to check for *.json extension or special project filename
    file(TO_CMAKE_PATH "${_file}" _file)
    if(IS_ABSOLUTE "${_file}")
        set(file "${_file}")
    else()
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            set(file "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
        else()
            message(FATAL_ERROR "File '${_file}' does not exists!\nNeither is it absolute nor does it exists in the directory '${CMAKE_CURRENT_SOURCE_DIR}'!")
        endif()
    endif()
    file(READ "${_file}" _contents)
    cmakejson_project("${_contents}")
endfunction()

### project() override
if(CMakeJSON_ENABLE_PROJECT_OVERRIDE)
    macro(project)
        if(NOT CMakeJSON_USE_PROJECT_OVERRIDE)
            _project(${ARGN})
        else()
            list(APPEND CMAKE_MESSAGE_CONTEXT "CMakeJSON")
            get_filename_component(ARGV0_PATH "${ARGV0}" ABSOLUTE)
            if(EXISTS "${ARGV0_PATH}")
                message(${CMakeJSON_MSG_VERBOSE_TYPE} "Creating project from file: '${ARGV0}'")
                cmakejson_project_file("${ARGV0_PATH}")
            else() 
                cmakejson_project(${ARGN})
            endif()
            list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        endif()
    endmacro()
endif()