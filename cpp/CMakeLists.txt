cmake_minimum_required(VERSION 3.16)
project(hello_cpp)

set(CMAKE_CXX_STANDARD 17)

add_executable(hello_cpp main.cpp)
find_package(Threads REQUIRED)
target_link_libraries(hello_cpp PRIVATE Threads::Threads)

# Crow (crow_all.h) depends on standalone Asio headers (asio.hpp).
include(FetchContent)
FetchContent_Declare(
  asio
  URL https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-1-30-2.tar.gz
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(asio)
target_include_directories(hello_cpp PRIVATE ${asio_SOURCE_DIR}/asio/include)

