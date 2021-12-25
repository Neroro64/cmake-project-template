cmake_minimum_required(VERSION 3.2)
# Project config
set(PROJECT_NAME "cmake-project-template")
set(PROJECT_VERSION 0.1)
set(PROJECT_DESCRIPTION "A C++ project template")
set(PROJECT_LANGUAGE "CXX")

# Options
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# Setup
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} DESCRIPTION ${PROJECT_DESCRIPTION} LANGUAGES ${PROJECT_LANGUAGE})


project(cmake-project-template VERSION 0.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -O3")
if (MSVC)
    # warning level 4 and all warnings as errors
    add_compile_options(/W4 /WX)
else()
    # lots of warnings and all warnings as errors
    add_compile_options(-Wall -Wextra -pedantic -Werror)
endif()

set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})

set(DIVISIBLE_INSTALL_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(DIVISIBLE_INSTALL_BIN_DIR ${PROJECT_SOURCE_DIR}/bin)
set(DIVISIBLE_INSTALL_LIB_DIR ${PROJECT_SOURCE_DIR}/lib)

set(DIVISION_HEADERS_DIR ${PROJECT_SOURCE_DIR}/src/division)

include_directories(${DIVISIBLE_INSTALL_INCLUDE_DIR})
include_directories(${DIVISION_HEADERS_DIR})

add_subdirectory(src)
add_subdirectory(test)


