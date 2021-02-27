function(cmakejson_validate_project_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_set_project_parse_defaults _filename)
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_NAME)
        set(CMakeJSON_PARSE_PROJECT_NAME "${_filename}")
    endif()
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(CURRENT_PROJECT) # If this is set there is a parrent
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION)
            cmakejson_get_project_property(PROPERTY VERSION)
            set(CMakeJSON_PARSE_PROJECT_VERSION "${VERSION}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY)
            cmakejson_get_project_property(PROPERTY VERSION_COMPATIBILITY)
            set(CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY "${VERSION_COMPATIBILITY}" PARENT_SCOPE)
        endif()
        # Components of a package are searched in cmake via <package>_<component>
        set(component_include)
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PACKAGE_NAME AND NOT DEFINED CMakeJSON_PARSE_PROJECT_COMPONENT_PACKAGE_NAME)
            cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_NAME}" PARENT_SCOPE)
            set(component_include "${CMakeJSON_PARSE_PROJECT_NAME}")
        elseif(DEFINED CMakeJSON_PARSE_PROJECT_COMPONENT_PACKAGE_NAME)
            cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_COMPONENT_PACKAGE_NAME}" PARENT_SCOPE)
            set(component_include "${CMakeJSON_PARSE_PROJECT_COMPONENT_PACKAGE_NAME}")
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE AND NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
            set(CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE "${EXPORT_NAMESPACE}::${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}" PARENT_SCOPE)
        elseif(DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${EXPORT_NAMESPACE}::${CMakeJSON_PARSE_PROJECT_EXPORT_COMPONENT_NAME}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION)
            cmakejson_get_project_property(PROPERTY CMAKE_CONFIG_INSTALL_DESTINATION)
            set(CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION "${CMAKE_CONFIG_INSTALL_DESTINATION}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION)
            cmakejson_get_project_property(PROPERTY PKGCONFIG_INSTALL_DESTINATION)
            set(CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION "${PKGCONFIG_INSTALL_DESTINATION}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY)
            cmakejson_get_project_property(PROPERTY USAGE_INCLUDE_DIRECTORY)
            set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${USAGE_INCLUDE_DIRECTORY}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION)
            cmakejson_get_project_property(PROPERTY PUBLIC_HEADER_INSTALL_DESTINATION)
            set(CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION "${PUBLIC_HEADER_INSTALL_DESTINATION}/" PARENT_SCOPE)
        endif()
    else()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION)
            set(CMakeJSON_PARSE_PROJECT_VERSION "0.1" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY)
            set(CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY "AnyNewerVersion" PARENT_SCOPE)
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
            if(CMakeJSON_PARSE_PROJECT_VERSIONED_INSTALLED)
                set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${CMAKE_INSTALL_INCLUDEDIR}/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}-${CMakeJSON_PARSE_PROJECT_VERSION}" PARENT_SCOPE)
            else()
                set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${CMAKE_INSTALL_INCLUDEDIR}" PARENT_SCOPE)
            endif()
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION)
            set(CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION "${CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION}/${component_include}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

function(cmakejson_setup_project_common_dependency_properties _depprefix _out_depname)
    if(DEFINED ${_depprefix})
        set(dep_name ${${_depprefix}})
    elseif(DEFINED ${_depprefix}_NAME)
        set(dep_name ${${_depprefix}_NAME})
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Dependency parsed as '${_depprefix}' is missing a name!")
    endif()
    set(dep_infos PKG_CONFIG_NAME DESCRIPTION PURPOSE COMPONENTS VERSION FIND_OPTIONS)
    foreach(dep_info IN LISTS dep_infos)
        if(DEFINED ${_depprefix}_${dep_info})
            cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_${dep_info} "${${_depprefix}_${dep_info}}")
        endif()
    endforeach()
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY DEPENDENCIES "${dep_name}")

    set(${_out_depname} "${dep_name}" PARENT_SCOPE)
endfunction()

function(cmakejson_generate_find_package_string _depprefix _out_string)
    if(DEFINED ${_depprefix})
        set(dep_name ${${_depprefix}})
    elseif(DEFINED ${_depprefix}_NAME)
        set(dep_name ${${_depprefix}_NAME})
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Dependency parsed as '${_depprefix}' is missing a name!")
    endif()
    set(dep_infos PKG_CONFIG_NAME DESCRIPTION PURPOSE COMPONENTS VERSION FIND_OPTIONS)
    foreach(dep_info IN LISTS dep_infos)
        if(DEFINED ${_depprefix}_${dep_info})
            cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_${dep_info} "${${_depprefix}_${dep_info}}")
        endif()
    endforeach()
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY DEPENDENCIES "${dep_name}")

    set(${_out_depname} "${dep_name}" PARENT_SCOPE)
endfunction()

function(cmakejson_add_dependency _depprefix)
    cmakejson_setup_project_common_dependency_properties(${_depprefix} dep_name)
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY REQUIRED_DEPENDENCIES "${dep_name}") # Just in case
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "Adding required dependency: ${dep_name}!")
    cmakejson_get_directory_property(PROPERTY ${dep_name}_FOUND)

    cmakejson_run_func_over_parsed_range(${_depprefix}_COMPONENTS cmakejson_gather_json_array_as_list components)
    cmakejson_run_func_over_parsed_range(${_depprefix}_FIND_PARAMETERS cmakejson_gather_json_array_as_list params)

    set(find_package_params "${dep_name}")
    if(NOT DEFINED ${_depprefix}_VERSION)
        list(APPEND find_package_params ${${_depprefix}_VERSION})
    endif()
    if(${dep_name}_FOUND) # Internal to remove REQUIRED parameter
        foreach(_comp IN LISTS ${components})
            cmakejson_get_directory_property(PROPERTY ${dep_name}_${_comp}_FOUND)
            if(NOT ${dep_name}_${_comp}_FOUND)
                message(${CMakeJSON_MSG_ERROR_TYPE} "'${dep_name}' was found but required component '${_comp}' was not found!\nPlease re-check your build options for '${dep_name}' and the current project!")
            endif()
        endforeach()
    else()
        list(APPEND find_package_params REQUIRED)
    endif()
    if(components)
        list(APPEND find_package_params COMPONENTS ${components})
    endif()
    if(params)
        list(APPEND find_package_params ${params})
    endif()
    list(JOIN find_package_params ";" find_package_str)
    cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_FIND_PACKAGE "${find_package_params}")
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "find_package(${find_package_str})")
    find_package(${find_package_str})
    if(DEFINED ${_depprefix}_PURPOSE)
        set_package_properties(${dep_name} PROPERTIES PURPOSE "${${_depprefix}_PURPOSE}")
    endif()
    set_package_properties(${dep_name} PROPERTIES TYPE REQUIRED)
endfunction()

function(cmakejson_add_optional_dependency _depprefix _optname)
    cmakejson_setup_project_common_dependency_properties(${_depprefix} dep_name)
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY OPTIONAL_DEPENDENCIES "${dep_name}") # Just in case
    cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_OPTION "${_optname}")
    cmakejson_get_project_property(PROPERTY OPTION_${_optname}_VARIABLE)
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "Adding optional dependency: ${dep_name}!")

    cmakejson_get_directory_property(PROPERTY ${dep_name}_FOUND)
    cmakejson_run_func_over_parsed_range(${_depprefix}_COMPONENTS cmakejson_gather_json_array_as_list components)
    cmakejson_run_func_over_parsed_range(${_depprefix}_FIND_PARAMETERS cmakejson_gather_json_array_as_list params)

    set(find_package_params "${dep_name}")
    if(NOT DEFINED ${_depprefix}_VERSION)
        list(APPEND find_package_params ${${_depprefix}_VERSION})
    endif()
    set(disable_package)
    if(${dep_name}_FOUND) # Internal to remove REQUIRED parameter
        foreach(_comp IN LISTS ${components})
            cmakejson_get_directory_property(PROPERTY ${dep_name}_${_comp}_FOUND)
            if(NOT ${dep_name}_${_comp}_FOUND)
                message(${CMakeJSON_MSG_ERROR_TYPE} "'${dep_name}' was found but required component '${_comp}' was not found!\nPlease re-check your build options for '${dep_name}' and the current project!")
            endif()
        endforeach()
    else()
        if(${OPTION_${_optname}_VARIABLE})
            list(APPEND find_package_params REQUIRED)
        else()
            # CMAKE_DISABLE_FIND_PACKAGE_<package> does deactivate find_package completly 
            # which also means that feature_summary will not pick it up
            # So NO_DEFAULT_PATH is used here so that the package is not found.
            set(disable_package NO_DEFAULT_PATH)
        endif()
    endif()
    if(components)
        list(APPEND find_package_params COMPONENTS ${components})
    endif()
    if(params)
        list(APPEND find_package_params ${params})
    endif()
    list(JOIN find_package_params ";" find_package_str)
    cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_FIND_PACKAGE "${find_package_params}")
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "find_package(${find_package_str} ${disable_package})")
    find_package(${find_package_str} ${disable_package})

    if(DEFINED ${_depprefix}_PURPOSE)
        set_package_properties(${dep_name} PROPERTIES PURPOSE "${${_depprefix}_PURPOSE}")
    endif()
    set_package_properties(${dep_name} PROPERTIES TYPE OPTIONAL)
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
        if(NOT ${${_optprefix}}_TYPE STREQUAL "BOOL")
            set(IS_BOOL_OPTION FALSE)
        endif()
    endif()

    if(IS_BOOL_OPTION)
        set(OPT_FUNC option)
        set(OPT_PARAMS ${${_optprefix}_VARIABLE} "${${_optprefix}_DESCRIPTION}" ${${_optprefix}_DEFAULT_VALUE})
        if(DEFINED ${${_optprefix}}_CONDITION)
            if(${${_optprefix}}_CONDITION STREQUAL "")
                message(${CMakeJSON_MSG_WARNING_TYPE} "Value 'condition' for option '${${_optprefix}_VARIABLE}' is an empty string!")
            endif()
            if(NOT DEFINED ${_optprefix}_DEFAULT_VALUE)
                set(${_optprefix}_DEFAULT_VALUE OFF)
            endif()
            set(OPT_FUNC cmake_dependent_option)
            list(APPEND OPT_PARAMS "${${${_optprefix}}_CONDITION}")
            list(APPEND OPT_PARAMS OFF)
        endif()
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_OPTIONS "${OPT_FUNC}(${OPT_PARAMS})")
        cmake_language(CALL ${OPT_FUNC} ${OPT_PARAMS})
        
        # Can only add feature info to BOOL options
        if(NOT ${_optprefix}_NO_FEATURE_INFO)
            add_feature_info("${${_optprefix}_NAME}" "${${_optprefix}_VARIABLE}" "${${_optprefix}_DESCRIPTION}")
        endif()
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY OPTIONS "${${_optprefix}_NAME}")

        set(opt_props VARIABLE DEFAULT_VALUE DESCRIPTION CONDITION EXPORT)
        foreach(prop IN LISTS opt_props)
            if(DEFINED ${_optprefix}_${prop})
                cmakejson_set_project_property(PROPERTY "OPTION_${${_optprefix}_NAME}_${prop}" "${${_optprefix}_${prop}}")
            endif()
        endforeach()

        cmakejson_run_func_over_parsed_range(${_optprefix}_DEPENDENCIES cmakejson_add_optional_dependency ${${_optprefix}_NAME})

        # if(${${_optprefix}_VARIABLE} AND DEFINED ${_optprefix}_CODE)
        #     # TODO: Do something?
        # endif()
    else()
        if(NOT DEFINED ${_optprefix}_DEFAULT_VALUE)
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
    set(PARENT_PROJECT)
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(CURRENT_PROJECT)
        set(PARENT_PROJECT "${CURRENT_PROJECT}")
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT VERBOSE "Adding '${CMakeJSON_PARSE_PROJECT_NAME}' as a subporject to '${CURRENT_PROJECT}'")
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY CHILD_PROJECTS "${CMakeJSON_PARSE_PROJECT_NAME}")
        cmakejson_set_project_property(PROPERTY CHILD_${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
        cmakejson_set_project_property(PROPERTY CHILD_${CMakeJSON_PARSE_PROJECT_NAME}_PACKAGE_NAME "${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
    endif()

    cmakejson_set_directory_property(PROPERTY CURRENT_PROJECT "${CMakeJSON_PARSE_PROJECT_NAME}")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(NOT CURRENT_PROJECT STREQUAL "${CMakeJSON_PARSE_PROJECT_NAME}")
        message(FATAL_ERROR "'${CURRENT_PROJECT}' does not match '${CMakeJSON_PARSE_PROJECT_NAME}'")
    endif()
    cmakejson_set_directory_property(PROPERTY "${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY" "${PROJECT_SOURCE_DIR}")
    if(PARENT_PROJECT)
        cmakejson_set_project_property(PROPERTY PARENT_PROJECT "${PARENT_PROJECT}")
    endif()
    set(project_properties DESCRIPTION
                           HOMEPAGE
                           PACKAGE_NAME
                           EXPORT_NAME
                           EXPORT_NAMESPACE
                           VERSION
                           VERSION_COMPATIBILITY
                           CMAKE_CONFIG_INSTALL_DESTINATION
                           PKGCONFIG_INSTALL_DESTINATION
                           USAGE_INCLUDE_DIRECTORY
                           PUBLIC_HEADER_INSTALL_DESTINATION
                           PUBLIC_CMAKE_MODULE_PATH)
    foreach(_prop IN LISTS project_properties)
        if(DEFINED CMakeJSON_PARSE_PROJECT_${_prop})
            cmakejson_set_project_property(PROPERTY ${_prop}  "${CMakeJSON_PARSE_PROJECT_${_prop}}")
        endif()
    endforeach()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    if(CMakeJSON_PARSE_PROJECT_PUBLIC_CMAKE_MODULE_PATH)
        file(REAL_PATH "${CMakeJSON_PARSE_PROJECT_PUBLIC_CMAKE_MODULE_PATH}" module_path)
        list(APPEND CMAKE_MODULE_PATH "${module_path}")
        unset(module_path)
    endif()

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

function(cmakejson_generate_project_config)
    list(APPEND CMAKE_MESSAGE_CONTEXT "generate_config")

    cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
    cmakejson_get_project_property(PROPERTY EXPORT_NAME)
    cmakejson_get_project_property(PROPERTY PUBLIC_CMAKE_MODULE_PATH)
    cmakejson_get_project_property(PROPERTY CMAKE_CONFIG_INSTALL_DESTINATION)

    cmakejson_get_project_property(PROPERTY OPTIONS) # Check if the option is exported

    if(IS_ABSOLUTE "${CMAKE_CONFIG_INSTALL_DESTINATION}")
        message(${CMakeJSON_MSG_ERROR_TYPE} "Member 'cmake_config_install_destination' destination needs to be relative! Value:'${CMAKE_CONFIG_INSTALL_DESTINATION}'")
    endif()

    set(EXPORTED_CONFIG_VARS)
    set(EXPORTED_CONFIG_PATH_VARS)

    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INPUT)
        set(_config_contents)
        string(APPEND _config_contents "#This file was automatically generated by CMakeCS!\n")
        string(APPEND _config_contents "@PACKAGE_INIT@\n")
        string(APPEND _config_contents "cmake_policy (PUSH)\n")
        string(APPEND _config_contents "cmake_minimum_required (VERSION 3.19)\n\n")
        list(APPEND ${PROJECT_NAME}_CONFIG_VARS CMAKE_CURRENT_LIST_FILE)
        if(PUBLIC_CMAKE_MODULE_PATH)
            list(APPEND ${PROJECT_NAME}_CONFIG_VARS \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH)
            string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH \"\${CMAKE_CURRENT_LIST_DIR}/cmake\")\n")        
            string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH_BACKUP \${CMAKE_MODULE_PATH})\n")
            string(APPEND _config_contents "list(PREPEND CMAKE_MODULE_PATH \"\${CMAKE_CURRENT_LIST_DIR}/cmake\")\n") # Prepending makes sure we get the correct modules
            # string(APPEND _config_contents "if(0)\n") #@${PROJECT_NAME}_BUILD_DIR_CONFIG@
            # foreach(_dir IN LISTS PUBLIC_CMAKE_MODULE_PATH)
            #     if(IS_ABSOLUTE "${_dir}")
            #         string(APPEND _config_contents "    list(PREPEND CMAKE_MODULE_PATH \"${_dir}\")\n")
            #         string(APPEND _config_contents "    list(APPEND \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH \"${_dir}\")\n")
            #     else()
            #         string(APPEND _config_contents "    list(PREPEND CMAKE_MODULE_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/${_dir}\")\n")
            #         string(APPEND _config_contents "    list(PREPEND CMAKE_MODULE_PATH \"${CMAKE_CURRENT_BINARY_DIR}/${_dir}\")\n")
            #         string(APPEND _config_contents "    list(APPEND \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH \"${CMAKE_CURRENT_SOURCE_DIR}/${_dir}\")\n")
            #         string(APPEND _config_contents "    list(APPEND \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH \"${CMAKE_CURRENT_BINARY_DIR}/${_dir}\")\n")
            #     endif()
            # endforeach()
            # string(APPEND _config_contents "endif()\n")
            string(APPEND _config_contents "list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)\n")
            string(APPEND _config_contents "list(REMOVE_DUPLICATES \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH)\n")
            string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH \"\${\${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH}\" CACHE INTERNAL \"\")\n\n")   
        endif()

        string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_BUILD_AS_SHARED @BUILD_SHARED_LIBS@ CACHE INTERNAL \"\")\n")     
        #string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_BUILD_DIR_CONFIG 0) # Is config within build dir?\n")
        foreach(_opt IN LISTS OPTIONS)
            cmakejson_get_project_property(PROPERTY ${_opt}_TYPE)
            cmakejson_get_project_property(PROPERTY ${_opt}_VARIABLE)
            cmakejson_get_project_property(PROPERTY ${_opt}_EXPORT)
            set(_var ${${_opt}_VARIABLE})
            set(_set_var "set")
            set(_var_package)
            if(${_opt}_TYPE STREQUAL "PATH")
                set(_set_var set_and_check)
                set(_var_package PACKAGE_)
                if(${_opt}_EXPORT)
                    list(APPEND EXPORTED_CONFIG_PATH_VARS \${CMAKE_FIND_PACKAGE_NAME}_${_var})
                endif()
            endif()
            if(${_opt}_EXPORT)
                string(APPEND _config_contents "${_set_var}(\${CMAKE_FIND_PACKAGE_NAME}_${_var} @${_var_package}${_var}@ CACHE INTERNAL \"\")\n")
                list(APPEND EXPORTED_CONFIG_VARS \${CMAKE_FIND_PACKAGE_NAME}_${_var})
            else()
                string(APPEND _config_contents "${_set_var}(\${CMAKE_FIND_PACKAGE_NAME}_${_var} @${_var_package}${_var}@)\n")
            endif()
            unset(_var)
            unset(_set_var)
            unset(_var_package)
            unset(${_opt}_VARIABLE)
            unset(${_opt}_EXPORT)
            unset(${_opt}_TYPE)
        endforeach()

        # string(APPEND _config_contents "\n # Deal with modules to include\n")
        # foreach(_module IN LISTS ${PROJECT_NAME}_MODULES_TO_INCLUDE)
        #     string(APPEND _config_contents "option(\${CMAKE_FIND_PACKAGE_NAME}_WITHOUT_CMAKE_MODULE_${_module} \"Deactivate inclusion of module ${_module} for \${CMAKE_FIND_PACKAGE_NAME} \" OFF)\n")
        #     string(APPEND _config_contents "if(NOT \${CMAKE_FIND_PACKAGE_NAME}_WITHOUT_CMAKE_MODULE_${_module})\n")
        #     string(APPEND _config_contents "    include(${_module})\n")
        #     string(APPEND _config_contents "endif()\n")
        # endforeach()

        # Deal with dependencies
        cmakejson_get_project_property(PROPERTY DEPENDENCIES)
        string(APPEND _config_contents "\n # Deal with dependencies \n")
        string(APPEND _config_contents "include(CMakeFindDependencyMacro)\n")
        string(APPEND _config_contents "\n # Dependencies \n")
        # Write find_dependency calls fo required packages
        foreach(_dep IN LISTS DEPENDENCIES)
            cmakejson_get_project_property(PROPERTY DEPENDENCY_${_dep}_FIND_PACKAGE)
            cmakejson_get_project_property(PROPERTY DEPENDENCY_${_dep}_OPTION)
            if(DEPENDENCY_${_dep}_OPTION)
                cmakejson_get_project_property(PROPERTY OPTION_${DEPENDENCY_${_dep}_OPTION}_VARIABLE)
                string(APPEND _config_contents "if(@${OPTION_${DEPENDENCY_${_dep}_OPTION}_VARIABLE}@)\n  ")
            endif()
            list(REMOVE_ITEM DEPENDENCY_${_dep}_FIND_PACKAGE REQUIRED)
            string(APPEND _config_contents "find_dependency(")
            string(APPEND _config_contents "${DEPENDENCY_${_dep}_FIND_PACKAGE}")
            string(APPEND _config_contents ")\n")
            if(DEPENDENCY_${_dep}_OPTION)
                string(APPEND _config_contents "endif(@${OPTION_${DEPENDENCY_${_dep}_OPTION}_VARIABLE}@)\n  ")
                unset(OPTION_${DEPENDENCY_${_dep}_OPTION})
                unset(OPTION_${DEPENDENCY_${_dep}_OPTION}_VARIABLE)
            endif()
            unset(DEPENDENCY_${_dep}_FIND_PACKAGE)
        endforeach()

        # Deal with components
        cmakejson_get_project_property(PROPERTY CHILD_PROJECTS)
        if(CHILD_PROJECTS)
            set(_available_components )
            string(APPEND _config_contents "\n # Deal with components \n")
            foreach(_child IN LISTS CHILD_PROJECTS)
                cmakejson_get_project_property(PROPERTY CHILD_${_child}_PACKAGE_NAME)
                set(_component "${CHILD_${_child}_PACKAGE_NAME}")
                list(APPEND _available_components ${_component})
                string(APPEND _config_contents "find_dependency(${PACKAGE_NAME}_${_component}\n")
                string(APPEND _config_contents "                HINTS \${CMAKE_CURRENT_LIST_DIR}/components\n")
                string(APPEND _config_contents "                )\n\n")
                unset(CHILD_${_child}_PACKAGE_NAME)
            endforeach() 
            string(APPEND _config_contents "set(\${CMAKE_FIND_PACKAGE_NAME}_AVAILABLE_COMPONENTS ${_available_components})\n")
            string(APPEND _config_contents "check_required_components(\${CMAKE_FIND_PACKAGE_NAME})\n")
            unset(_available_components)
            unset(CHILD_PROJECTS)
        else()
            set(COMPONENT_OPTION NO_CHECK_REQUIRED_COMPONENTS_MACRO)
        endif(CHILD_PROJECTS)

        string(APPEND _config_contents "\n # Finish up \n")
        cmakejson_get_project_property(PROPERTY EXPORTED_TARGETS)
        if(EXPORTED_TARGETS)
            string(APPEND _config_contents "include(\${CMAKE_CURRENT_LIST_DIR}/${PACKAGE_NAME}Targets.cmake)\n")
        endif()

        # if(${_VAR_PREFIX}_SETUP_MODULE_PATH)
        #     string(APPEND _config_contents "set(CMAKE_MODULE_PATH \${CMAKE_FIND_PACKAGE_NAME}_CMAKE_MODULE_PATH_BACKUP)\n") # Restoring old module path
        # endif()
        # if(${PROJECT_NAME}_PUBLIC_MODULE_DIRECTORIES)
        #     set(CMAKE_PUBLIC_MODULES)
        #     foreach(_module_path IN LISTS ${PROJECT_NAME}_PUBLIC_MODULE_DIRECTORIES)
        #         list(APPEND CMAKE_PUBLIC_MODULES "\${CMAKE_CURRENT_LIST_DIR}/${_module_path}")
        #     endforeach()
        #     string(APPEND _config_contents "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} ${CMAKE_PUBLIC_MODULES})\n")
        # endif()

        string(APPEND _config_contents "find_package_handle_standard_args(\${CMAKE_FIND_PACKAGE_NAME} HANDLE_COMPONENTS\n")
        if(EXPORTED_CONFIG_VARS)
            string(APPEND _config_contents "                                  REQUIRED_VARS @${EXPORTED_CONFIG_VARS}@\n")
        endif()
        string(APPEND _config_contents "                                  )\n")
        string(APPEND _config_contents "cmake_policy (POP)\n")
        #string(APPEND _config_contents "unset(_\${CMAKE_FIND_PACKAGE_NAME}_SEARCHING)\n")

        if(CMakeJSON_PARSE_PROJECT_DESCRIPTION)
            string(APPEND _config_contents "set_package_properties(\${CMAKE_FIND_PACKAGE_NAME} PROPERTIES\n"
                                           "                       DESCRIPTION ${CMakeJSON_PARSE_PROJECT_DESCRIPTION}\n")
        endif()
        if(CMakeJSON_PARSE_PROJECT_HOMEPAGE)
            string(APPEND _config_contents "set_package_properties(\${CMAKE_FIND_PACKAGE_NAME} PROPERTIES\n"
                                           "                       URL ${CMakeJSON_PARSE_PROJECT_HOMEPAGE})\n")
        endif()

        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}Config.in.cmake" "${_config_contents}")
        set(CMAKE_INPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}Config.in.cmake")
    else()
        set(CMAKE_INPUT_FILE "${CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INPUT}")
        foreach(_opt IN LISTS OPTIONS)
            cmakejson_get_project_property(PROPERTY ${_opt}_TYPE)
            cmakejson_get_project_property(PROPERTY ${_opt}_VARIABLE)
            cmakejson_get_project_property(PROPERTY ${_opt}_EXPORT)
            set(_var ${${_opt}_VARIABLE})
            if(${_opt}_TYPE STREQUAL "PATH" AND ${_opt}_EXPORT)
                list(APPEND EXPORTED_CONFIG_PATH_VARS \${CMAKE_FIND_PACKAGE_NAME}_${_var})
            elseif(${_opt}_EXPORT)
                list(APPEND EXPORTED_CONFIG_VARS \${CMAKE_FIND_PACKAGE_NAME}_${_var})
            endif()
            unset(_var)
            unset(${_opt}_VARIABLE)
            unset(${_opt}_EXPORT)
            unset(${_opt}_TYPE)
        endforeach()
    endif(NOT DEFINED CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INPUT)

    file(RELATIVE_PATH REL_CONFIG_PATH  "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

    set(NO_SET_CHECK)
    if(NOT EXPORTED_CONFIG_PATH_VARS)
        set(NO_SET_CHECK NO_SET_AND_CHECK_MACRO)
    endif()
    set(PATH_VARS)
    if(EXPORTED_CONFIG_PATH_VARS)
        set(PATH_VARS PATH_VARS ${EXPORTED_CONFIG_PATH_VARS})
    endif()
    # Write install config file 
    configure_package_config_file(
            "${CMAKE_INPUT_FILE}"
            "${CMAKE_CONFIG_INSTALL_DESTINATION}/${PACKAGE_NAME}Config.install.cmake"
            INSTALL_DESTINATION "$<INSTALL_INTERFACE:${CMAKE_CONFIG_INSTALL_DESTINATION}>"
            ${PATH_VARS}
            ${COMPONENT_OPTION}
            ${NO_SET_CHECK}
            )
    # cmcs_get_global_property(PROPERTY ${PROJECT_NAME}_EXPORT_ON_BUILD)
    # # Config in build dir!
    # if(${PROJECT_NAME}_EXPORT_ON_BUILD)
    #     set(${PROJECT_NAME}_RELATIVE_SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
    #     set(${PROJECT_NAME}_BUILD_DIR_CONFIG TRUE)
    #     configure_package_config_file(
    #             "${${_VAR_PREFIX}_INPUT_FILE}"
    #             "${${_VAR_PREFIX}_INSTALL_DESTINATION}/${${PROJECT_NAME}_PACKAGE_NAME}Config.cmake"
    #             INSTALL_DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}"
    #             #INSTALL_DESTINATION "$<BUILD_INTERFACE:${REL_CONFIG_PATH}/${${_VAR_PREFIX}_INSTALL_DESTINATION}>"
    #             PATH_VARS ${${_VAR_PREFIX}_PATH_VARS} ${PROJECT_NAME}_RELATIVE_SOURCE_PATH 
    #             ${${_VAR_PREFIX}_NO_COMPONENTS}
    #             ${${_VAR_PREFIX}_NO_SET_CHECK}
    #             INSTALL_PREFIX "${CMAKE_SOURCE_DIR}"
    #             )
    # endif()  
    # Write ConfigVersion
    #cmcs_variable_exists_or_error(PREFIX "${_VAR_PREFIX}" VARIABLE_NAMES "")

    cmakejson_get_project_property(PROPERTY VERSION)
    cmakejson_get_project_property(PROPERTY VERSION_COMPATIBILITY)

    if(VERSION AND VERSION_COMPATIBILITY)
        write_basic_package_version_file("${CMAKE_CONFIG_INSTALL_DESTINATION}/${PACKAGE_NAME}ConfigVersion.cmake"
                                        VERSION ${VERSION} 
                                        COMPATIBILITY ${VERSION_COMPATIBILITY})
        install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CONFIG_INSTALL_DESTINATION}/${PACKAGE_NAME}ConfigVersion.cmake"
                                        DESTINATION "${CMAKE_CONFIG_INSTALL_DESTINATION}" )
    elseif(VERSION OR VERSION_COMPATIBILITY)
        message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot define VERSION or VERSION_COMPATIBILITY without setting both!")
    endif()
                                     
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CONFIG_INSTALL_DESTINATION}/${PACKAGE_NAME}Config.install.cmake"
            DESTINATION "${CMAKE_CONFIG_INSTALL_DESTINATION}"
            RENAME "${PACKAGE_NAME}Config.cmake")

    # if(${PROJECT_NAME}_PUBLIC_CMAKE_FILES)
    #     install(FILES "${${PROJECT_NAME}_PUBLIC_CMAKE_FILES}"
    #             DESTINATION "${${_VAR_PREFIX}_INSTALL_DESTINATION}/cmake")
    # endif()
    # if(${PROJECT_NAME}_PUBLIC_CMAKE_DIRS)
    #     install(DIRECTORY "${${PROJECT_NAME}_PUBLIC_CMAKE_DIRS}"
    #             DESTINATION "${${_VAR_PREFIX}_INSTALL_DESTINATION}/cmake") 
    # endif()

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_close_project)
    list(APPEND CMAKE_MESSAGE_CONTEXT "close")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(NOT DEFINED CURRENT_PROJECT OR CURRENT_PROJECT STREQUAL "")
        message(${CMakeJSON_MSG_ERROR_TYPE} "No CURRENT_PROJECT defined in the current directory scope! Cannot call 'cmakejson_close_project'!")
    endif()

    cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
    cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
    cmakejson_get_project_property(PROPERTY EXPORT_NAME)
    cmakejson_get_project_property(PROPERTY EXPORTED_TARGETS)
    cmakejson_get_project_property(PROPERTY CMAKE_CONFIG_INSTALL_DESTINATION)
    cmakejson_get_project_property(PROPERTY CHILD_PROJECTS)

    # foreach(_component IN LISTS ${PROJECT_NAME}_COMPONENTS)
    #     cmcs_get_global_property(PROPERTY ${PROJECT_NAME}_${_component}_NAMESPACE)
    #     cmcs_get_global_property(PROPERTY ${PROJECT_NAME}_${_component}_EXPORT_NAME)
    #     cmcs_get_global_property(PROPERTY ${PROJECT_NAME}_${_component}_EXPORTED_TARGETS)

    #     if(${PROJECT_NAME}_EXPORT_ON_BUILD AND ${PROJECT_NAME}_${_component}_EXPORTED_TARGETS)
    #         export(EXPORT ${${PROJECT_NAME}_${_component}_EXPORT_NAME}
    #             NAMESPACE ${${PROJECT_NAME}_${_component}_NAMESPACE}::
    #             FILE ${CMAKE_INSTALL_DATAROOTDIR}/${${PROJECT_NAME}_PACKAGE_NAME}/${${PROJECT_NAME}_PACKAGE_NAME}_${_component}Targets.cmake)
    #     endif()
    #     if(${PROJECT_NAME}_EXPORTED_TARGETS)
    #         install(EXPORT ${${PROJECT_NAME}_${_component}_EXPORT_NAME}
    #                 NAMESPACE ${${PROJECT_NAME}_${_component}_NAMESPACE}:: 
    #                 FILE ${${PROJECT_NAME}_PACKAGE_NAME}_${_component}Targets.cmake 
    #                 DESTINATION "${${PROJECT_NAME}_CONFIG_INSTALL_DESTINATION}")
    #      endif()
    #      foreach(_target IN LISTS ${PROJECT_NAME}_EXPORTED_TARGETS)
    #         get_target_property(IS_EXECUTABLE ${_target} TYPE)
    #         if(IS_EXECUTABLE STREQUAL "EXECUTABLE")
    #             add_executable(${${PROJECT_NAME}_${_component}_NAMESPACE}::${_target} ALIAS ${_target})
    #         else()
    #             add_library(${${PROJECT_NAME}_${_component}_NAMESPACE}::${_target} ALIAS ${_target})
    #         endif()
    #     endforeach()
    #     # Disable find_package for internally available packages. 
    #     set(CMAKE_DISABLE_FIND_PACKAGE_${${PROJECT_NAME}_PACKAGE_NAME}_${_component} TRUE CACHE INTERNAL "" FORCE)
    #     set(${${PROJECT_NAME}_PACKAGE_NAME}_${_component}_FOUND TRUE CACHE INTERNAL "" FORCE)
    #     set(_CMakeCS_${${PROJECT_NAME}_PACKAGE_NAME}_${_component}_FOUND TRUE)
    #     cmcs_set_global_property(PROPERTY _CMakeCS_${${PROJECT_NAME}_PACKAGE_NAME}_${_component}_FOUND)
    #     set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${${PROJECT_NAME}_PACKAGE_NAME}_${_component})

    #     cmcs_set_global_property(PROPERTY ${PROJECT_NAME}_${_component}_LOCKED)
    # endforeach()

    # In Project find_package calls never work in build and require ALIAS targets
    # This export dues export the targets into the build dir with absoulte paths.
    # It only works if the <packagename>Config.cmake has all requirements to run 
    # correctly in the build dir. This requires that all files required by the config
    # are present in the build dir. If the config only requires targets, version or
    # other generated files this works. If it additionally requires files from the 
    # SOURCE_TREE which are only installed it typically breaks and requires extra
    # code in the config to work! The only way to use those exported files is to have
    # a staged build with e.g. ExternalProject_Add followed by another ExternalProject_Add
    # which depends on the build target of the first and consumes the generated configs
    # from it. This skips the required install step but leaves the question if it is worth
    # the effort since extra care must be taken to make it findable with find_package (
    # e.g. setting <packagename>_DIR correctly) while for **all** installed librarys setting  
    # CMAKE_PREFIX_PATH would be sufficient
    # TL;DR: **This is only useful for ExternalProject_Add and skipping the install step and
    #          requires the config to work form the build dir**
    # if(${PROJECT_NAME}_EXPORT_ON_BUILD AND ${PROJECT_NAME}_EXPORTED_TARGETS)
    #     export(EXPORT ${${PROJECT_NAME}_EXPORT_NAME}
    #         NAMESPACE ${${PROJECT_NAME}_NAMESPACE}:: 
    #         FILE ${CMAKE_INSTALL_DATAROOTDIR}/${${PROJECT_NAME}_PACKAGE_NAME}/${${PROJECT_NAME}_PACKAGE_NAME}Targets.cmake)
    # endif()

    # This only exists @ install time

    if(EXPORTED_TARGETS)
        install(EXPORT ${EXPORT_NAME}
                NAMESPACE ${EXPORT_NAMESPACE}:: 
                FILE ${PACKAGE_NAME}Targets.cmake 
                DESTINATION "${CMAKE_CONFIG_INSTALL_DESTINATION}")
                
    endif()

    # Alias all exported targets into the namespace ${PROJECT_NAME}_PACKAGE_NAME 
    # just as the target file would do. Assumes that all variables are available just 
    # like if find_package is called.
    foreach(_target IN LISTS EXPORTED_TARGETS)
        get_target_property(IS_EXECUTABLE ${_target} TYPE)
        if(IS_EXECUTABLE STREQUAL "EXECUTABLE")
            add_executable(${EXPORT_NAMESPACE}::${_target} ALIAS ${_target})
        else()
            add_library(${EXPORT_NAMESPACE}::${_target} ALIAS ${_target})
        endif()
    endforeach()

    # Disable find_package for internally available packages. 
    if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        set(CMAKE_DISABLE_FIND_PACKAGE_${PACKAGE_NAME} TRUE CACHE INTERNAL "" FORCE)
        set(${PACKAGE_NAME}_FOUND TRUE CACHE INTERNAL "" FORCE)
        cmakejson_set_directory_property(PROPERTY ${PACKAGE_NAME}_FOUND TRUE)
        set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${PACKAGE_NAME})
        cmakejson_get_project_property(PROPERTY DESCRIPTION)
        cmakejson_get_project_property(PROPERTY HOMEPAGE)
        set_package_properties(${PACKAGE_NAME} PROPERTIES
                       DESCRIPTION "${DESCRIPTION}"
                       URL "${HOMEPAGE}")
    endif()
    cmakejson_get_project_property(PROPERTY PARENT_PROJECT)
    if(PARENT_PROJECT)
        cmakejson_set_directory_property(PROPERTY CURRENT_PROJECT "${PARENT_PROJECT}")
    else()
        cmakejson_set_directory_property(PROPERTY CURRENT_PROJECT "")
    endif()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(cmakejson_project _input _filename)
    list(APPEND CMAKE_MESSAGE_CONTEXT "project")
    if(CMAKE_FOLDER)
        set(CMakeJSON_CMAKE_FOLDER_BACKUP ${CMAKE_FOLDER})
    endif()
    file(RELATIVE_PATH rel_path "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
    set(CMAKE_FOLDER "${rel_path}")

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
        set(patch)
        if(DEFINED)
            set(patch ".${CMakeJSON_PARSE_PROJECT_VERSION_PATCH}")
        endif()
        set(tweak)
        if(DEFINED)
            set(tweak ".${CMakeJSON_PARSE_PROJECT_VERSION_TWEAK}")
        endif()
        cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_LANGUAGES cmakejson_gather_json_array_as_list languages)
        _project("${CMakeJSON_PARSE_PROJECT_NAME}"
                    VERSION "${CMakeJSON_PARSE_PROJECT_VERSION}${patch}${tweak}"
                    DESCRIPTION "${CMakeJSON_PARSE_PROJECT_DESCRIPTION}"
                    HOMEPAGE_URL "${CMakeJSON_PARSE_PROJECT_HOMEPAGE}"
                    LANGUAGES ${languages}
                )
    else()
        if(NOT DEFINED PROJECT_NAME)
            message(FATAL_ERROR "CMakeJSON_USE_PROJECT_OVERRIDE is false and PROJECT_NAME is not defined!\nEither manually call project() or set CMakeJSON_USE_PROJECT_OVERRIDE to true!")
        endif()
    endif()
    cmakejson_setup_project()

    #if(DEFINED "${CMakeJSON_PARSE_PROJECT_CUSTOM_STEPS}")
    #    if(${CMakeJSON_PARSE_PROJECT_CUSTOM_STEPS})
    #        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT VERBOSE "Found field 'custom_steps' in project! Don't forget to call cmakejson_close_project() if finished!")
    #        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    #        return()
    #    endif()
    #endif()
    cmakejson_generate_project_config()
    cmakejson_close_project()

    if(CMakeJSON_CMAKE_FOLDER_BACKUP)
        set(CMAKE_FOLDER "${CMakeJSON_CMAKE_FOLDER_BACKUP}")
    else()
        unset(CMAKE_FOLDER)
    endif()
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
                set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${ARGV0_PATH}")
                cmakejson_project_file("${ARGV0_PATH}")
            else() 
                message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot create project from given arguments! '${ARGN}'")
            endif()
        endif()
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    endmacro()
endif()
