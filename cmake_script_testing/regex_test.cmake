
include(CMakePrintHelpers)
set(INPUT "-arg=bla -arch arm64 -arg2=C:\Windows\Path\ --target=semi;colon -I\"/spaaa  ccccee/ es\\\"quote \\ asdasda\" -L/escapespace\\ and\\\"quote/ morestuff")
set(FLAGS_REGEX [=[( +|^)((\"(\\\"|[^"])+\"|\\\"|\\ |[^ ])+)]=])
string(REGEX REPLACE ";" "\\\;" OUTPUT_RES "${INPUT}")
string(REGEX REPLACE ${FLAGS_REGEX} ";\\2" OUTPUT "${OUTPUT_RES}")
cmake_print_variables(INPUT)
cmake_print_variables(OUTPUT)
# [=[( +|^)([^"]*("([^\"]|\\|\")*")?)]=]