cmake_minimum_required(VERSION 3.5)

project(protobuf-delphi-plugin LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(protoc-gen-delphi
    src/main.cpp
    src/delphiutils.h
    src/delphiutils.cpp
    src/delphicodegenerator.h
    src/delphicodegenerator.cpp
    src/delphiunitgenerator.h
    src/delphiunitgenerator.cpp)

add_executable(pbjson-addressbook
    src/schema/main.cpp
    src/schema/addressbook.pb.h
    src/schema/addressbook.pb.cc)

find_package(Protobuf REQUIRED)

target_link_libraries(protoc-gen-delphi
    ${Protobuf_LIBRARIES}
    ${Protobuf_PROTOC_LIBRARIES})

target_link_libraries(pbjson-addressbook
    ${Protobuf_LIBRARIES}
    ${Protobuf_PROTOC_LIBRARIES})

target_include_directories(pbjson-addressbook
    PRIVATE "${CMAKE_SOURCE_DIR}/src")
