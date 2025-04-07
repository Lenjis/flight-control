# 设置最低 CMake 版本
cmake_minimum_required(VERSION 3.10)

# 设置项目名称
project(flight_sim)

# 设置 C 标准
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_FLAGS /source-charset:utf-8)

# 添加源文件
set(SOURCES
    src/main.c
    src/RK4.c
    src/model.c
)

# 添加可执行文件
add_executable(flight_sim ${SOURCES})

# # 链接库（如 winmm.lib）
# if(WIN32)
#     target_link_libraries(flight_sim winmm)
# endif()
