# CMakeJSON
CMakeJSON is a collection of scripts to setup projects, tests, dependencies (via package managers) and other stuff The aim of CMakeJSON is to reduce the mental burden to setup CMake projects by providing a declarative project/component/target setup which automatically deals with correctly exporting and installing targets without too much effort. It can be used either from a build, install or even droped into your project. The recommended way to use CMakeJSON is to install it and use `find_package(CMakeJSON)` with `CMakeJSON_DIR` set to the directory containing the installed `CMakeJSONConfig.cmake` file.   
CMakeJSON is based on the experince with CMakeCS and the newly added json parser in CMake. 

### Key features


### Future possible features

 
### Features to probably never to be included
 - automatic download of third party dependencies. 3rd party dependencies should be handled by a package manager and not by the build system itself

## Examples

## Internals

## The anatomy of every CMake project
 1) Define toplevel project
 3) (Define subprojects)
 4) Import some (optional) dependencies (via find_package)
 5) Define 'buildable' targets (libraries, executables, others [including code generators] )
 6) Add something to those targets dependendent on some options or the found dependencies (sources,definitions,linkage,etc.)
 ---
 7) install some (not necessary all) targets (sometimes forgotten)
 8) export the installed targets of the project into a cmake file. (probably forgotten)
 9) generate a config including the file from 8) with a find_dependency call for all required dependencies and write a version file (probably forgotten)
 10) maybe restart with 1)

 ### Common problems from the view of package manager
 
 To point 4)
 - having optional dependencies without an explicit option to enable disable the option.
 Observed Problems:
 - Link errors in static builds due to missing dependencies; Builds on different machine not reproduciable due to different system libraries.  
 Solution:
 - Have an explicit named option `<ProjectName>_ENABLE_<PackageName>` which is defaulted to `OFF`
   (Yes there is `CMAKE_DISABLE_FIND_PACKAGE_<PackageName>` but this requires implicit knowledge that the project uses `<PackageName>`)
 - Define `find_package` dependencies on the project levels. Helps integrating those information into the later generated config file. 

### Common problems from the view of the author
 To point 6)
  - linking imported targets without knowledge where they came from. 
 Observed Problems:
  - missing find_dependency call in `<PackageName>Config.cmake` (if it even exits)
 Solution: 
  - 

--- 
 TODO
 Improve README.md
 
 (things to check)
 Check global property ENABLED_FEATURES and file FeatureSummary.cmake
 GLOBAL_DEPENDS_NO_CYCLES
 TARGETS:
 EXPORT_PROPERTIES
 WINDOWS_EXPORT_ALL_SYMBOLS
 FOLDERS

 Global:
 PACKAGES_FOUND
 PACKAGES_NOT_FOUND

 Directory properties:
 BUILDSYSTEM_TARGETS
 VARIABLES
 CMAKE_CONFIGURE_DEPENDS

 - Add Target/Project options and register them to add them into the generated config
 - Add the possibility to create instantiations of C++ templates in a common way