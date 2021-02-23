function(cmakejson_validate_project_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_set_project_parse_defaults _filename)
    # TODO Check for PARENT_PROJECT and adjust
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_NAME)
        set(CMakeJSON_PARSE_PROJECT_NAME "${_filename}")
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION)
        set(CMakeJSON_PARSE_PROJECT_VERSION "0.1" PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PACKAGE_NAME)
        set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME ${CMakeJSON_PARSE_PROJECT_NAME} PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAME)
        set(CMakeJSON_PARSE_PROJECT_EXPORT_NAME ${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME} PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE)
        set(CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE ${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME} PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION)
        set(CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}" PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION)
        set(CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig" PARENT_SCOPE)
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY)
        set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${CMAKE_INSTALL_INCLUDEDIR}" PARENT_SCOPE)
    endif()
endfunction()

macro(cmakejson_run_func_over_parsed_range _varprefix _function)
    math(EXPR range_length "${${_varprefix}_LENGTH}-1")
    foreach(json_index RANGE ${range_length})
        cmake_language(CALL ${_function} "${_varprefix}_${json_index}" ${ARGN})
    endforeach()
    unset(range_length)
endmacro()

function(cmakejson_add_dependency _depprefix)
    #TODO
endfunction()

function(cmakejson_add_optional_dependency _depprefix _optprefix)
    #TODO
endfunction()

function(cmakejson_project_option_setup _optprefix)
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PROJECT_OPTIONS _optprefix)
    if(NOT DEFINED ${_optprefix}_VARIABLE AND NOT DEFINED ${_optprefix}_NAME)
        message(${CMakeJSON_MSG_ERROR_TYPE} "Invalid option in '${_optprefix}'. Option has neither a member 'name' or 'variable'! At least one is required!")
    endif() 
    if(NOT DEFINED ${_optprefix}_VARIABLE)
        cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
        string(TOUPPER "${PACKAGE_NAME}_WITH_${${_optprefix}_NAME}" ${_optprefix}_VARIABLE)
    endif()
    if(NOT DEFINED ${_optprefix}_NAME)
        string(REPLACE "^WITH_" "" ${_optprefix}_NAME "${${_optprefix}_VARIABLE}")
        string(TOLOWER "${${_optprefix}_NAME}" ${_optprefix}_NAME)
    endif()

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
        
        # Can only add feature info to BOOL options
        if(NOT ${_optprefix}_NO_FEATURE_INFO)
            add_feature_info("${${_optprefix}_NAME}" "${${_optprefix}_VARIABLE}" "${${_optprefix}_DESCRIPTION}")
        endif()
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY OPTIONS "${${_optprefix}_NAME}")
        cmakejson_set_project_property(PROPERTY "OPTION_${${_optprefix}_NAME}_VARIABLE" )
        cmakejson_set_project_property(PROPERTY "OPTION_${${_optprefix}_NAME}_DEFAULT_VALUE" )
        cmakejson_set_project_property(PROPERTY "OPTION_${${_optprefix}_NAME}_DESCRIPTION" )
        cmakejson_set_project_property(PROPERTY "OPTION_${${_optprefix}_NAME}_CONDITION" )
        if(${${_optprefix}_DEPENDENCIES})
            cmakejson_run_func_over_parsed_range(${_optprefix}_DEPENDENCIES cmakejson_add_optional_dependency OPTION_${${_optprefix}_NAME})
        endif()
        if(${${_optprefix}_VARIABLE})
            # TODO: Do something?
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
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_OPTIONS cmakejson_project_option_setup)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_get_list_element_function _out_func _element)
    if(_element MATCHES "target\\\.json$" OR _element STREQUAL "target")
        set(${_out_func} "cmakejson_target_file")
    elseif(_element MATCHES "project\\\.json$" OR _element STREQUAL "project")
        set(${_out_func} "cmakejson_project_file")
    elseif(_element MATCHES "\\\.cmake$" OR _element STREQUAL "include" )
        set(${_out_func} "include")
    elseif(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_element}")
        set(${_out_func} "add_subdirectory")
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot figure out what to do with '${_element}' in member 'list'!")
    endif()
    set(${_out_func} ${${_out_func}} PARENT_SCOPE)
endfunction()

function(cmakejson_analyze_list _listprefix)
    set(call_func)
    set(_element)
    if(DEFINED ${_listprefix})
        set(_element "${${_listprefix}}")
    elseif(DEFINED ${_listprefix}_TYPE)
        set(_element "${${_listprefix}_TYPE}")
    elseif(DEFINED ${_listprefix}_ELEMENT)
        set(_element "${${_listprefix}_ELEMENT}")
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot figure out what to do with '${_listprefix}' in member 'list'!")
    endif()
    cmakejson_get_list_element_function(call_func "${_element}")
    cmake_language(CALL ${call_func} "${_element}")
endfunction()

function(cmakejson_setup_project)
    list(APPEND CMAKE_MESSAGE_CONTEXT "setup")

    list(APPEND CMAKE_MESSAGE_CONTEXT "general")
    # TODO: More Parent project handling!
    set(PARRENT_PROJECT)
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(CURRENT_PROJECT)
        set(PARENT_PROJECT "${CURRENT_PROJECT}")
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT VERBOSE "Adding '${CMakeJSON_PARSE_PROJECT_NAME}' as a subporject to '${CURRENT_PROJECT}'")
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY CHILD_PROJECTS "${CMakeJSON_PARSE_PROJECT_NAME}")
    endif()

    cmakejson_set_directory_property(PROPERTY CURRENT_PROJECT "${CMakeJSON_PARSE_PROJECT_NAME}")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(NOT CURRENT_PROJECT STREQUAL "${CMakeJSON_PARSE_PROJECT_NAME}")
        message(FATAL_ERROR "'${CURRENT_PROJECT}' does not match '${CMakeJSON_PARSE_PROJECT_NAME}'")
    endif()
    cmakejson_set_directory_property(PROPERTY "${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY" "${PROJECT_SOURCE_DIR}")
    if(PARRENT_PROJECT)
        cmakejson_set_project_property(PROPERTY PARENT_PROJECT "${PARENT_PROJECT}")
    endif()
    cmakejson_set_project_property(PROPERTY PACKAGE_NAME "${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
    cmakejson_set_project_property(PROPERTY EXPORT_NAME "${CMakeJSON_PARSE_PROJECT_EXPORT_NAME}")
    cmakejson_set_project_property(PROPERTY EXPORT_NAMESPACE "${CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE}")

    cmakejson_set_project_property(PROPERTY VERSION "${CMakeJSON_PARSE_PROJECT_VERSION}")
    cmakejson_set_project_property(PROPERTY VERSION_COMPATIBILITY "${CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY}")

    cmakejson_set_project_property(PROPERTY CMAKE_CONFIG_INSTALL_DESTINATION "${CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION}")
    cmakejson_set_project_property(PROPERTY PKGCONFIG_INSTALL_DESTINATION "${CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION}")

    cmakejson_set_project_property(PROPERTY USAGE_INCLUDE_DIRECTORY "${CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY}")
    cmakejson_set_project_property(PROPERTY PUBLIC_CMAKE_MODULE_PATH "${CMakeJSON_PARSE_PROJECT_PUBLIC_CMAKE_MODULE_PATH}")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    list(APPEND CMAKE_MESSAGE_CONTEXT "deps")
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_DEPENDENCIES cmakejson_add_dependency)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    cmakejson_project_options()

    list(APPEND CMAKE_MESSAGE_CONTEXT "list")
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_LIST cmakejson_analyze_list)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_determine_list_element)
    cmakejson_create_function_parse_arguments_prefix(_PREFIX)
    cmake_parse_arguments(PARSE_ARGV 0 "${_PREFIX}" "" "OUTPUT_FUNCTION;INPUT" "")
endfunction()

function(cmakejson_close_project)
endfunction()

function(cmakejson_project _input _filename)
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
            cmakejson_message_if(CMakeJSON_DEBUG_PROJECT STATUS "Project condition '${CMakeJSON_PARSE_PROJECT_CONDITION}' is false. Skipping project!")
            list(POP_BACK CMAKE_MESSAGE_CONTEXT)
            return() # Skip project completly
        endif()
    endif()

    cmakejson_set_project_parse_defaults("${_filename}") # Setup some defaults if nothing has been passed

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
    get_filename_component(_filename "${_file}" NAME_WE)
    file(READ "${_file}" _contents)
    cmakejson_project("${_contents}" "${_filename}")
endfunction()

### project() override
if(CMakeJSON_ENABLE_PROJECT_OVERRIDE)
    macro(project)
        list(APPEND CMAKE_MESSAGE_CONTEXT "CMakeJSON")
        if(${ARGV0} MATCHES ".json$")
            set(CMakeJSON_USE_PROJECT_OVERRIDE ON)
            message(${CMakeJSON_MSG_VERBOSE_TYPE} "Detected json file: '${ARGV0}'")
        else()
            message(${CMakeJSON_MSG_VERBOSE_TYPE} "Normal cmake project call!")
            set(CMakeJSON_USE_PROJECT_OVERRIDE OFF)
        endif()
        if(NOT CMakeJSON_USE_PROJECT_OVERRIDE)
            _project(${ARGN})
        else()
            get_filename_component(ARGV0_PATH "${ARGV0}" ABSOLUTE)
            if(EXISTS "${ARGV0_PATH}")
                message(${CMakeJSON_MSG_VERBOSE_TYPE} "Creating project from file: '${ARGV0}'")
                cmakejson_project_file("${ARGV0_PATH}")
            else() 
                message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot create project from given arguments! '${ARGN}'")
            endif()
        endif()
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    endmacro()
endif()
