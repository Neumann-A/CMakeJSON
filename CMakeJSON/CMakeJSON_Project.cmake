function(cmakejson_validate_project_json _jsoninput)
    list(APPEND CMAKE_MESSAGE_CONTEXT "validate")
    #TODO: Validate all fields in the input
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

macro(cmakejson_set_project_parse_defaults_after_project)
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION)
        if(DEFINED CMAKE_INSTALL_DATAROOTDIR)
            set(CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
        else()
            set(CMakeJSON_PARSE_PROJECT_CMAKE_CONFIG_INSTALL_DESTINATION "share/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
        endif()
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION)
        if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
            set(CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
        else()
            set(CMakeJSON_PARSE_PROJECT_PKGCONFIG_INSTALL_DESTINATION "lib/pkgconfig")
        endif()
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY)
        if(CMakeJSON_PARSE_PROJECT_VERSIONED_INSTALLED)
            set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${CMAKE_INSTALL_INCLUDEDIR}/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}-${PROJECT_VERSION_MAJOR}")
        else()
            set(CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY "${CMAKE_INSTALL_INCLUDEDIR}")
        endif()
    endif()
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION)
        set(CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION "${CMakeJSON_PARSE_PROJECT_USAGE_INCLUDE_DIRECTORY}/${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
    endif()
endmacro()

function(cmakejson_set_project_parse_defaults _filename)
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_NAME)
        set(CMakeJSON_PARSE_PROJECT_NAME "${_filename}")
        set(CMakeJSON_PARSE_PROJECT_NAME "${_filename}" PARENT_SCOPE)
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
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PACKAGE_NAME AND NOT DEFINED CMakeJSON_PARSE_PROJECT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_NAME}" PARENT_SCOPE)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_NAME}")
            set(CMakeJSON_PARSE_PROJECT_COMPONENT_NAME "${CMakeJSON_PARSE_PROJECT_NAME}" PARENT_SCOPE)
            set(CMakeJSON_PARSE_PROJECT_COMPONENT_NAME "${CMakeJSON_PARSE_PROJECT_NAME}")
            set(component_include "${CMakeJSON_PARSE_PROJECT_NAME}")
        elseif(DEFINED CMakeJSON_PARSE_PROJECT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}" PARENT_SCOPE)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${PACKAGE_NAME}_${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}")
            set(component_include "${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}")
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE AND NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
            set(CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE "${EXPORT_NAMESPACE}::${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}" PARENT_SCOPE)
        elseif(DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_COMPONENT_NAME)
            cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${EXPORT_NAMESPACE}::${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}" PARENT_SCOPE)
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
            set(CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION "${PUBLIC_HEADER_INSTALL_DESTINATION}/${component_include}" PARENT_SCOPE)
        endif()
    else()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION)
            set(CMakeJSON_PARSE_PROJECT_VERSION "0.1" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY)
            set(CMakeJSON_PARSE_PROJECT_VERSION_COMPATIBILITY "AnyNewerVersion" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_PACKAGE_NAME)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${CMakeJSON_PARSE_PROJECT_NAME}" PARENT_SCOPE)
            set(CMakeJSON_PARSE_PROJECT_PACKAGE_NAME "${CMakeJSON_PARSE_PROJECT_NAME}")
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAME)
            set(CMakeJSON_PARSE_PROJECT_EXPORT_NAME "${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}" PARENT_SCOPE)
        endif()
        if(NOT DEFINED CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE)
            set(CMakeJSON_PARSE_PROJECT_EXPORT_NAMESPACE "${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

function(cmakejson_project_option_setup _optprefix _out_find_package_code)
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

        #Optional Dependencies
        cmakejson_run_func_over_parsed_range(${_optprefix}_DEPENDENCIES cmakejson_add_optional_dependency ${${_optprefix}_NAME} ${_out_find_package_code})
        cmakejson_return_to_parent_scope(${_out_find_package_code})

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

macro(cmakejson_project_options)
    list(APPEND CMAKE_MESSAGE_CONTEXT "options")
    cmakejson_print_variables_if(CMakeJSON_DEBUG_PROJECT_OPTIONS CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH)
    if(NOT DEFINED CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH OR CMakeJSON_PARSE_PROJECT_OPTIONS_LENGTH LESS_EQUAL 0)
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT_OPTIONS "No project options found!")
    else()
        unset(cmakejson_optional_find_package_code)
        cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_OPTIONS cmakejson_project_option_setup cmakejson_optional_find_package_code)
        if(DEFINED cmakejson_optional_find_package_code)
            #message(STATUS "Executing (optional deps):\n '${cmakejson_optional_find_package_code}'")
            cmake_language(EVAL CODE "${cmakejson_optional_find_package_code}")
        endif()
        unset(cmakejson_optional_find_package_code)
    endif()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()

function(cmakejson_get_list_element_function _out_func _element)
    if(_element MATCHES "target\\\.json$")
        set(${_out_func} "CALL;cmakejson_target_file")
    elseif(_element MATCHES "project\\\.json$")
        set(${_out_func} "CALL;cmakejson_project_file")
    elseif(_element MATCHES "\\\.cmake$")
        set(${_out_func} "CALL;include")
    elseif(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_element}")
        set(${_out_func} "CALL;add_subdirectory")
    else()
        set(${_out_func} "EVAL;CODE") # Assume plain CMake Code;
    endif()
    set(${_out_func} ${${_out_func}} PARENT_SCOPE)
endfunction()

macro(cmakejson_analyze_list _listprefix)
    set(cmakejson_analyze_list_call_func "")
    set(cmakejson_analyze_list_element "")
    if(DEFINED ${_listprefix})
        set(cmakejson_analyze_list_element "${${_listprefix}}")
        cmakejson_get_list_element_function(cmakejson_analyze_list_call_func "${cmakejson_analyze_list_element}")
        cmake_language(${cmakejson_analyze_list_call_func} "${cmakejson_analyze_list_element}")
    elseif(DEFINED ${_listprefix}_MODULE)
        cmake_language(CALL include "${${_listprefix}_MODULE}")
    elseif(DEFINED ${_listprefix}_INCLUDE)
        cmake_language(CALL include "${${_listprefix}_INCLUDE}")
    elseif(DEFINED ${_listprefix}_SUBDIRECTORY)
        cmake_language(CALL add_subdirectory "${${_listprefix}_SUBDIRECTORY}")
    else()
        message(${CMakeJSON_MSG_ERROR_TYPE} "Empty element in json member 'list'!")
    endif()
    unset(cmakejson_analyze_list_call_func)
    unset(cmakejson_analyze_list_element)
endmacro()

function(cmakejson_setup_project)
    list(APPEND CMAKE_MESSAGE_CONTEXT "setup")

    list(APPEND CMAKE_MESSAGE_CONTEXT "general")
    # TODO: More Parent project handling!
    set(PARENT_PROJECT)
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(CURRENT_PROJECT)
        set(PARENT_PROJECT "${CURRENT_PROJECT}")
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT VERBOSE "Adding '${CMakeJSON_PARSE_PROJECT_NAME}' as a subproject to '${CURRENT_PROJECT}'")
        cmakejson_set_project_property(APPEND_OPTION APPEND PROPERTY CHILD_PROJECTS "${CMakeJSON_PARSE_PROJECT_NAME}")
        cmakejson_set_project_property(PROPERTY CHILD_${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
        cmakejson_set_project_property(PROPERTY CHILD_${CMakeJSON_PARSE_PROJECT_NAME}_PACKAGE_NAME "${CMakeJSON_PARSE_PROJECT_PACKAGE_NAME}")
        cmakejson_set_project_property(PROPERTY CHILD_${CMakeJSON_PARSE_PROJECT_NAME}_COMPONENT_NAME "${CMakeJSON_PARSE_PROJECT_COMPONENT_NAME}")
    endif()

    cmakejson_set_directory_property(PROPERTY CURRENT_PROJECT "${CMakeJSON_PARSE_PROJECT_NAME}")
    cmakejson_define_directory_property(INHERITED PROPERTY ${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY 
                                    BRIEF_DOCS "Defines the directory where the project ${CMakeJSON_PARSE_PROJECT_NAME} is defined" 
                                    FULL_DOCS "Defines the directory where the project ${CMakeJSON_PARSE_PROJECT_NAME} is defined")
    cmakejson_set_directory_property(PROPERTY ${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(NOT CURRENT_PROJECT STREQUAL "${CMakeJSON_PARSE_PROJECT_NAME}")
        message(FATAL_ERROR "'${CURRENT_PROJECT}' does not match '${CMakeJSON_PARSE_PROJECT_NAME}'")
    endif()
    cmakejson_set_directory_property(PROPERTY "${CMakeJSON_PARSE_PROJECT_NAME}_DIRECTORY" "${CMAKE_CURRENT_SOURCE_DIR}")
    if(PARENT_PROJECT)
        cmakejson_set_project_property(PROPERTY PARENT_PROJECT "${PARENT_PROJECT}")
    endif()
    set(project_properties DESCRIPTION
                           HOMEPAGE
                           PACKAGE_NAME
                           COMPONENT_NAME
                           EXPORT_NAME
                           EXPORT_NAMESPACE
                           VERSION
                           VERSION_COMPATIBILITY
                           CMAKE_CONFIG_INSTALL_DESTINATION
                           PKGCONFIG_INSTALL_DESTINATION
                           USAGE_INCLUDE_DIRECTORY
                           PUBLIC_HEADER_INSTALL_DESTINATION
                           PUBLIC_CMAKE_MODULE_PATH
                           CONFIG_MODULES)
    foreach(_prop IN LISTS project_properties)
        if(DEFINED CMakeJSON_PARSE_PROJECT_${_prop})
            cmakejson_set_project_property(PROPERTY ${_prop} "${CMakeJSON_PARSE_PROJECT_${_prop}}")
        endif()
    endforeach()
    unset(CMakeJSON_PARSE_PROJECT_PUBLIC_HEADER_INSTALL_DESTINATION)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    if(CMakeJSON_PARSE_PROJECT_PUBLIC_CMAKE_MODULE_PATH)
        file(REAL_PATH "${CMakeJSON_PARSE_PROJECT_PUBLIC_CMAKE_MODULE_PATH}" module_path)
        list(APPEND CMAKE_MODULE_PATH "${module_path}")
        unset(module_path)
    endif()

    # Adding dependencies
    list(APPEND CMAKE_MESSAGE_CONTEXT "deps")
    unset(cmakejson_find_package_code)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_DEPENDENCIES cmakejson_add_dependency cmakejson_find_package_code)
    if(DEFINED cmakejson_find_package_code)
        #message(STATUS "Executing (add_dependency):\n '${cmakejson_find_package_code}'")
        cmake_language(EVAL CODE "${cmakejson_find_package_code}")
    endif()
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
    list(APPEND CMAKE_MESSAGE_CONTEXT "close")
    cmakejson_get_directory_property(PROPERTY CURRENT_PROJECT)
    if(NOT DEFINED CURRENT_PROJECT OR CURRENT_PROJECT STREQUAL "")
        message(${CMakeJSON_MSG_ERROR_TYPE} "No CURRENT_PROJECT defined in the current directory scope! Cannot call 'cmakejson_close_project'!")
    endif()

    cmakejson_get_project_property(PROPERTY PACKAGE_NAME)
    cmakejson_get_project_property(PROPERTY EXPORT_NAMESPACE)
    cmakejson_get_project_property(PROPERTY EXPORT_NAME)
    cmakejson_get_project_property(PROPERTY CMAKE_CONFIG_INSTALL_DESTINATION)
    cmakejson_get_project_property(PROPERTY CHILD_PROJECTS)

    # In Project find_package calls never work in build and require ALIAS targets
    # This export does export the targets into the build dir with absoulte paths.
    # It only works if the <packagename>Config.cmake has all requirements to run 
    # correctly in the build dir. This requires that all files required by the config
    # are present in the build dir. If the config only requires targets, version or
    # other generated files this works. If it additionally requires files from the 
    # SOURCE_TREE which are only installed, it typically breaks and requires extra
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

macro(cmakejson_project _input _filename)
    # IMPORTANT: This needs to be a macro! Otherwise CMake will have an access violation on configure without a prior project() call
    list(APPEND CMAKE_MESSAGE_CONTEXT "project")
    if(CMAKE_FOLDER)
        set(CMakeJSON_CMAKE_FOLDER_BACKUP ${CMAKE_FOLDER})
    endif()
    file(RELATIVE_PATH rel_path "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
    set(CMAKE_FOLDER "${rel_path}")
    unset(rel_path)

    foreach(_var IN LISTS PROJECT_PARSED_VARIABLES)
        set(${_var}) # set all the variables!
    endforeach()
    set(PROJECT_PARSED_VARIABLES)

    cmakejson_validate_project_json("${_input}")

    list(APPEND CMAKE_MESSAGE_CONTEXT "parse")
    cmakejson_parse_json(JSON_FILE  "${_filename}.json" # Not required
                         JSON_INPUT "${_input}"
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

    set(patch)
    if(DEFINED)
        set(patch ".${CMakeJSON_PARSE_PROJECT_VERSION_PATCH}")
    endif()
    set(tweak)
    if(DEFINED)
        set(tweak ".${CMakeJSON_PARSE_PROJECT_VERSION_TWEAK}")
    endif()

    unset(languages)
    cmakejson_run_func_over_parsed_range(CMakeJSON_PARSE_PROJECT_LANGUAGES cmakejson_gather_json_array_as_list languages)

    if(CMakeJSON_ENABLE_PROJECT_OVERRIDE) # Assume manual setup otherwise. 
        set(project_func _${CMAKEJSON_PROJECT_MACRO})
    else()
        set(project_func ${CMAKEJSON_PROJECT_MACRO})
    endif()
    if(NOT CURRENT_PROJECT OR CMakeJSON_PARSE_PROJECT_IS_SUPERBUILD OR CMakeJSON_PARSE_PROJECT_IS_EXTERNAL)
        cmake_language(CALL ${project_func} "${CMakeJSON_PARSE_PROJECT_NAME}"
                                            VERSION "${CMakeJSON_PARSE_PROJECT_VERSION}${patch}${tweak}"
                                            DESCRIPTION "${CMakeJSON_PARSE_PROJECT_DESCRIPTION}"
                                            HOMEPAGE_URL "${CMakeJSON_PARSE_PROJECT_HOMEPAGE}"
                                            LANGUAGES ${languages})
    endif()
    unset(project_func)
    unset(patch)
    unset(tweak)

    if(NOT languages STREQUAL "NONE")
        include(GNUInstallDirs)
    endif()
    unset(languages)
    cmakejson_set_project_parse_defaults_after_project()
    cmakejson_setup_project()
    cmakejson_generate_project_config()
    cmakejson_close_project()

    if(CMakeJSON_CMAKE_FOLDER_BACKUP)
        set(CMAKE_FOLDER "${CMakeJSON_CMAKE_FOLDER_BACKUP}")
    else()
        unset(CMAKE_FOLDER)
    endif()
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    foreach(_var IN LISTS PROJECT_PARSED_VARIABLES)
        unset(${_var}) # unset all the variables!
    endforeach()
endmacro()

# Simply load a file and pass contents further to cmakejson_project
macro(cmakejson_project_file _file)
    # IMPORTANT: This needs to be a macro! Otherwise CMake will have an access violation on configure without a prior project() call
    #TODO: Decide wether to check for *.json extension or special project filename
    file(TO_CMAKE_PATH "${_file}" _file)
    get_filename_component(file "${_file}" ABSOLUTE)
    if(NOT EXISTS "${file}")
        message(FATAL_ERROR "File '${_file}' does not exists!")
    endif()
    get_filename_component(_filename "${_file}" NAME_WE)
    file(READ "${_file}" _contents)
    cmakejson_project("${_contents}" "${_filename}")
    unset(_contents)
    unset(_filename)
    unset(file)
endmacro()

# This function checks if there is a function override in play. 
# CMakeJSON will overwrite the very last (_)*<function> it finds and append itself to it.
# This should be save in all cases

cmakejson_get_required_underscores(CMAKEJSON_PROJECT_UNDERSCORES project)
# CMAKEJSON_PROJECT_MACRO is a CACHE variable because the backup function (_)+<function>
# seems to be global in scope instead of having directory scope like the macro function
# or maybe function overriding builtin functions get the scope of the function they are
# overwriting?
set(CMAKEJSON_PROJECT_MACRO ${CMAKEJSON_PROJECT_UNDERSCORES}project CACHE INTERNAL "")
#cmake_print_variables(CMAKEJSON_PROJECT_UNDERSCORES CMAKEJSON_PROJECT_MACRO)
### project() override
macro(${CMAKEJSON_PROJECT_MACRO})
    if("${ARGV0}" MATCHES "\.json$")
        set(CMakeJSON_USE_PROJECT_OVERRIDE ON)
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT ${CMakeJSON_MSG_VERBOSE_TYPE} "Detected json file: '${ARGV0}'")
    else()
        cmakejson_message_if(CMakeJSON_DEBUG_PROJECT ${CMakeJSON_MSG_VERBOSE_TYPE} "Normal cmake project call! (${ARGV0})")
        set(CMakeJSON_USE_PROJECT_OVERRIDE OFF)
    endif()
    if(NOT CMakeJSON_USE_PROJECT_OVERRIDE)
        unset(CMakeJSON_USE_PROJECT_OVERRIDE)
        cmake_language(CALL _${CMAKEJSON_PROJECT_MACRO} ${ARGN})
    else()
        unset(CMakeJSON_USE_PROJECT_OVERRIDE)
        get_filename_component(ARGV0_PATH "${ARGV0}" ABSOLUTE)
        if(EXISTS "${ARGV0_PATH}")
            message(${CMakeJSON_MSG_VERBOSE_TYPE} "Reading project JSON: '${ARGV0}'")
            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${ARGV0_PATH}")
            list(APPEND CMAKE_MESSAGE_CONTEXT "CMakeJSON(${ARGV0})")
            cmakejson_project_file("${ARGV0_PATH}")
            list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        else() 
            message(${CMakeJSON_MSG_ERROR_TYPE} "Cannot create project from given arguments! '${ARGN}'")
        endif()
    endif()
endmacro()

