## Supported/Used JSON members in project JSON
Everything with a default is optional <br> 
(reformat into table?) <br>
 - `condition` : Condition to include/parse/setup the project 
 - `name` (default: `get_filename_component(NAME_WE)` : Name of the project
 - `description` : Description of the project
 - `homepage` : Homepage/URL of the project
 - `languages` \<array\> : Languages used within the [project](https://cmake.org/cmake/help/latest/command/project.html)
 - `package_name` (default: `(parrent_package_name_)name` : Name used for `find_package()`
 - `export_name` (default: `package_name`| remove? ) : Name of the target export group
 - `export_namespace` (default: `(parent_export_namespace::)package_name`) : Export namespace for targets
 - `version` (default: `0.1`) : Version of the project
 - `version_compatibility` (default: `AnyNewerVersion`) : According to [this](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html#command:write_basic_package_version_file)
 - `options` \<array of objects\>: Options to define for the project. Details [here](#options-member)
 - `dependencies` \<array of objects|string\>: Required dependencies for the project. Details [here](#dependencies-member)
 - `list` \<array of string\>: Required dependencies for the project. Details [here](#list-member)
 - `cmake_config_install_destination` (default: `${CMAKE_INSTALL_DATAROOTDIR}/package_name`) : Installation directory of the `<PackageName>Config.cmake`
 - `versioned_installed` (experimental): Use an extra directory `package_name-version_major` for installed includes. 
 - `usage_include_directory` (experimental|default: `${CMAKE_INSTALL_INCLUDEDIR}/(package_name-version)`) : usage (INTERFACE) include directory to add to the exported targets 
 - `public_header_install_destination` (experimental|default: `${CMAKE_INSTALL_INCLUDEDIR}/(package_name-version/)package_name`) : Installation directory for public headers
 - `component_name` (experimental) : Name of the subcomponent
 - `public_cmake_module_path` : Public CMake module path. This directory will be installed alongside the generated targets/configs
 
 ### `options` member:
 Note: Either `name`, `variable` or both need to be defined.
 - `name` (default: lowercaser `variable` without `WITH_` ) : Name of option displayed by [`feature_summary`](https://cmake.org/cmake/help/latest/module/FeatureSummary.html)
 - `variable` (default: Uppercase `package_name`\_WITH\_`name`) : Variable used by the option
 - `description` : Description for the option
 - `type` (default: BOOL) : Valid CMake variable type
 - `default_value` (default: BOOL->OFF | "") : Default value of the option variable
 - `condition` : Conditional Option. See [here](https://cmake.org/cmake/help/latest/module/CMakeDependentOption.html) for details
 - `export` : Export the variable into the generated `<PackeName>Config.cmake` and make it visible to `find_package()` callers
 - `no_feature_info` : disable call to `add_feature_info` (only for type BOOL)
 - `valid_values` (only type STRING): Valid values for the option (via [STRINGS](https://cmake.org/cmake/help/latest/prop_cache/STRINGS.html) property)
 - `dependencies` \<array of objects|string\>: Optional dependencies for the project. Details [here](#dependencies-member)

 ### `dependencies` member:
 Either simply a string with the `<PackageName>` for the `find_package(<PackageName>)` call or an JSON object with the following fields:
 - `name` : Name of the dependency
 - `pkg_config_name` (unused) : Alternative pkg-config name
 - `version` : Version of the dependency `find_package(<PackageName> <version>)`
 - `description` (unused) : Description for the dependency. 
 - `purpose` : Purpose of the dependency within the project. See [`feature_summary`](https://cmake.org/cmake/help/latest/module/FeatureSummary.html)
 - `components` : Components to add to `find_package(<PackageName> COMPONENTS <components>)`
 - `find_options` : Additional options to add to `find_package(<PackageName> <find_options>)`
 - `condition` : Condition to perform the `find_package()` call (Note: **Only** use this for platform based conditions. Option based conditions should list their dependencies under the relevant option!)

Please also refer to CMake [`find_package(<PackageName>)`](https://cmake.org/cmake/help/latest/command/find_package.html)

 ### `list` member:
Strings to either:
 - A `*.target.json` to generate a new target calling `cmakejson_target_file`
 - A `*.project.json` to parse a new project calling `cmakejson_project_file`
 - A `*.cmake` file to `include`
 - A relative path to a subdirectory for `add_subdiretory`
 