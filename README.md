# CMakeJSON
CMakeJSON provides a way to declare CMake projects and targets via `*.json` files. Furthermore, it also automatically export your targets and keeps track of your dependencies to generate correct `<PackageName>Config.cmake` files for `find_package` to simply work for your project/package. <br>
CMake is the defactor standard for a cross platform (meta) buildsystem but some people do not like it due to its syntax and/or complexity. CMakeJSON gives those people another (maybe simpler&cleaner) approach to CMake. <br>
In the current state, CMakeJSON is mainly targeted at smaller projects which have a not too complicated CMakeLists.txt. Bigger projects are also possible due to the possibility to mix normal CMake with CMakeJSON but further functionallity might be needed to ease the usage with CMakeJSON. <br>

### Usage
The recommended way to use CMakeJSON is to include it as a submodule in your project and use `include(<submodulepath>/CMakeJSON/CMakeJSON.cmake)`.
CMakeJSON is based on the experince with [CMakeCS](https://github.com/Neumann-A/CMakeCommonSetup/) and the newly added JSON parser to CMake. Due to that a CMake version of at least 3.19 is required.


---
## Documentation
List of json members allowed for:
 - [project](docs/project.md)
 - [target](docs/target.md)
 - To implement: [`Find<PackageName>.cmake`](docs/find.md)

Other questions might be answered in the [FAQ](docs/faq.md) 
[Parsing logic](docs/parsing.md)

Note: Currently no validation is done on the passed in `*.json` files. So make sure your field/members names are correctly spelled and have the correct type.

---
## Quickstart

Examples for using CMakeJSON can be found in [examples](examples).
The simplest CMakeJSON project looks like this:


1. CMakeLists.txt:
    ```
    cmake_minimum_required(VERSION 3.19)
    set(CMakeJSON_ENABLE_PROJECT_OVERRIDE ON) # defines a macro called project() to silence a CMake Warning
    include("${CMAKE_CURRENT_SOURCE_DIR}/CMakeJSON/CMakeJSON.cmake")
    project("<projectname>.json")
    # alternativly: if you don't want to use CMakeJSON_ENABLE_PROJECT_OVERRIDE
    # project(something) # this project call is mandatory since CMake throws a dev warning otherwise
    # cmakejson_project_file("<projectname>.json")
    ```
2. \<projectname\>.json read via `cmakejson_project_file(<filename>)`:
    ```
    {
        "homepage" : "<someurl>",
        "description" : "<somedescription>",
        "version" : "0.1.0",
        "languages" : ["CXX"],
        "list" : [
            "<libname>.target.json"
        ]
    }
    ```

3. \<libname\>.target.json read via `cmakejson_target_file(<filename>)`:
    ```
    {
        "target_type" : "library",
        "sources" : [
            "src/somesource.cpp"
        ]
    }
    ```
---

## Key features
 - JSON based project/target definitions
 - CMake variable expansion in JSON members
 - Getting target/project name from JSON file.
 - Mixing of JSON files and normal CMake. 
 - Automatic target export for library targets (except `OBJECT` libraries).
 - Automatic `<PackageName>Config(Version).cmake` generation
 - Automatic `FOLDER` property according to filesystem structure
 - Automatic `source_group(TREE)` setting according to filesystem structure
 - Support for [`feature_summary()`](https://cmake.org/cmake/help/latest/module/FeatureSummary.html)
 - Automatic namespaced `ALIAS` targets and deactivation of `find_package` for CMakeJSON defined targets/packages for easier superbuild setups using `add_subdirectory` of projects

In the future:
 - Automatic pc file generation. (Difficult since this a target based not package based. Needs some extra introspection from where an imported target originated)
 - CTest/CDash/CPack stuff (missing experience for proper setup)
 - More awesome stuff
 - Things from the [ToDo List](docs/todo.md)
 - Automatic `VS_DEBUGGER_ENVIRONMENT` for VS Generator + VCPKG toolchain?
 - Automatic `vcpkg.json` generation? (The way the code is executed probably doesn't allow this. Since the manifest must be created before the first `project()` call. Probably can only create a `vcpkg.json.new` after everything has run)
 - automatic Conan stuff? (don't know enough about conan to generate something)
 - Installation of runtime deps. 


---
### Examples
Different Examples for using CMakeJSON can be found in [examples](examples).

---
### Internals
