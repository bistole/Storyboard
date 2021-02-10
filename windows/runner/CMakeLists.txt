cmake_minimum_required(VERSION 3.15)
project(runner LANGUAGES CXX)

set(BACKEND_DIR "${CMAKE_CURRENT_SOURCE_DIR}/backend")
set(BACKEND_LIB "${BACKEND_DIR}/libBackend.lib")

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "run_loop.cpp"
  "utils.cpp"
  "commands.cpp"
  "backends.cpp"
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
target_link_libraries(${BINARY_NAME} PRIVATE "${BACKEND_LIB}")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
add_dependencies(${BINARY_NAME} flutter_assemble)
