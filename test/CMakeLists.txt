cmake_minimum_required(VERSION 3.2)
project(divider_tests)

add_subdirectory(lib/googletest)

include_directories(${DIVISION_HEADERS_DIR})
include_directories(lib/googletest/googletest/include)

set(SOURCE_FILES main.cpp src/divider_tests.cpp)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -O3")
if (MSVC)
    # warning level 4 and all warnings as errors
	add_compile_options("/W0")
else()
    # lots of warnings and all warnings as errors
    add_compile_options("-Wno-everything")
endif()


add_executable(divider_tests ${SOURCE_FILES})
target_link_libraries(divider_tests division gtest)
install(TARGETS divider_tests DESTINATION bin)

