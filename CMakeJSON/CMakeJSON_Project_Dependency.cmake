# Code which generates the find_package calls.
# The find_package call needs to be in the same scope as the project 

function(cmakejson_setup_project_common_dependency_properties _depprefix _out_depname)
    if(DEFINED ${_depprefix})
        set(dep_name ${${_depprefix}})
    elseif(DEFINED ${_depprefix}_NAME)
        set(dep_name ${${_depprefix}_NAME})
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Dependency parsed as '${_depprefix}' is missing a name!")
    endif()
    set(dep_infos PKG_CONFIG_NAME DESCRIPTION PURPOSE COMPONENTS VERSION FIND_OPTIONS CONDITION)
    foreach(dep_info IN LISTS dep_infos)
        if(DEFINED ${_depprefix}_${dep_info})
            cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_${dep_info} "${${_depprefix}_${dep_info}}")
        endif()
    endforeach()
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY DEPENDENCIES "${dep_name}")

    set(${_out_depname} "${dep_name}" PARENT_SCOPE)
endfunction()

function(cmakejson_generate_find_package_string _depprefix _out_string) # unused?
    if(DEFINED ${_depprefix})
        set(dep_name ${${_depprefix}})
    elseif(DEFINED ${_depprefix}_NAME)
        set(dep_name ${${_depprefix}_NAME})
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Dependency parsed as '${_depprefix}' is missing a name!")
    endif()
    set(dep_infos PKG_CONFIG_NAME DESCRIPTION PURPOSE COMPONENTS VERSION FIND_OPTIONS CONDITION)
    foreach(dep_info IN LISTS dep_infos)
        if(DEFINED ${_depprefix}_${dep_info})
            cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_${dep_info} "${${_depprefix}_${dep_info}}")
        endif()
    endforeach()
    if(DEFINED ${_depprefix}_CONDITION)
        if(${${_depprefix}_CONDITION})
            cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY DEPENDENCIES "${dep_name}")
        endif()
    else()
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY DEPENDENCIES "${dep_name}")
    endif()

    set(${_out_depname} "${dep_name}" PARENT_SCOPE)
endfunction()

function(cmakejson_add_dependency _depprefix _out_find_package_code)
    cmakejson_setup_project_common_dependency_properties(${_depprefix} dep_name)
    if(DEFINED ${_depprefix}_CONDITION)
        if(NOT ${${_depprefix}_CONDITION})
            return()
        endif()
    endif()
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY REQUIRED_DEPENDENCIES "${dep_name}") # Just in case
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "Adding required dependency: ${dep_name}!")
    cmakejson_get_directory_property(PROPERTY ${dep_name}_FOUND)

    cmakejson_run_func_over_parsed_range(${_depprefix}_COMPONENTS cmakejson_gather_json_array_as_list components)
    cmakejson_run_func_over_parsed_range(${_depprefix}_FIND_PARAMETERS cmakejson_gather_json_array_as_list params)

    set(find_package_params "${dep_name}")
    if(DEFINED ${_depprefix}_VERSION)
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
    string(APPEND ${_out_find_package_code} 
            "
            find_package(${find_package_str} ${disable_package})
            set_package_properties(${dep_name} PROPERTIES TYPE REQUIRED)")
    if(DEFINED ${_depprefix}_PURPOSE)
        string(APPEND ${_out_find_package_code} "
            set_package_properties(${dep_name} PROPERTIES PURPOSE \"${${_depprefix}_PURPOSE}\")")
    endif()
    cmakejson_return_to_parent_scope(${_out_find_package_code})
endfunction()

function(cmakejson_add_optional_dependency _depprefix _optname _out_find_package_code)
    cmakejson_setup_project_common_dependency_properties(${_depprefix} dep_name)
    if(DEFINED ${_depprefix}_CONDITION)
        if(NOT ${${_depprefix}_CONDITION})
            return()
        endif()
    endif()
    cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY OPTIONAL_DEPENDENCIES "${dep_name}") # Just in case
    cmakejson_set_project_property(PROPERTY DEPENDENCY_${dep_name}_OPTION "${_optname}")
    cmakejson_get_project_property(PROPERTY OPTION_${_optname}_VARIABLE)
    cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_DEPENDENCIES "Adding optional dependency: ${dep_name}!")

    cmakejson_get_directory_property(PROPERTY ${dep_name}_FOUND)
    cmakejson_run_func_over_parsed_range(${_depprefix}_COMPONENTS cmakejson_gather_json_array_as_list components)
    cmakejson_run_func_over_parsed_range(${_depprefix}_FIND_PARAMETERS cmakejson_gather_json_array_as_list params)

    set(find_package_params "${dep_name}")
    if(DEFINED ${_depprefix}_VERSION)
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
            # So NO_DEFAULT_PATH is used here so that a package is not found.
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

    string(APPEND ${_out_find_package_code} 
            "
            find_package(${find_package_str} ${disable_package})
            set_package_properties(${dep_name} PROPERTIES TYPE OPTIONAL)")
    if(DEFINED ${_depprefix}_PURPOSE)
        string(APPEND ${_out_find_package_code} "
            set_package_properties(${dep_name} PROPERTIES PURPOSE \"${${_depprefix}_PURPOSE}\")")
    endif()
    cmakejson_return_to_parent_scope(${_out_find_package_code})
endfunction()