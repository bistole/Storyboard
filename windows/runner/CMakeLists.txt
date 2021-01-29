cmake_minimum_required(VERSION 3.15)
project(runner LANGUAGES CXX)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "run_loop.cpp"
  "utils.cpp"
  "commands.cpp"
  "menu_events.cpp"
  "package_info.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)
apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "/Src/Storyboard/windows/runner/backend/libBackend.lib")
if(MSVC AND NOT (MSVC_VERSION LESS 1900))
  # prevent error LNK2019: unresolved external symbol _sprintf referenced in function __bdf_parse_properties
  # see http://stackoverflow.com/a/32418900/469659
  target_link_libraries(${BINARY_NAME} PRIVATE "legacy_stdio_definitions.lib")
endif()
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
add_dependencies(${BINARY_NAME} flutter_assemble)
