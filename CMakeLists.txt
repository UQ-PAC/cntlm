
cmake_minimum_required(VERSION 3.30)
project(cntlm C)

# set (CMAKE_C_FLAGS "-std=c99 -Wall -Wno-unused-but-set-variable -pedantic -O3 -D__BSD_VISIBLE -D_ALL_SOURCE -D_XOPEN_SOURCE=600 -D_POSIX_C_SOURCE=200112 -D_ISOC99_SOURCE -D_REENTRANT -D_BSD_SOURCE -DVERSION=\\\"0.92.3\\\"")

set (CMAKE_C_COMPILER aarch64-unknown-linux-musl-gcc)
execute_process(COMMAND bash "-c" "cat ${CMAKE_CURRENT_SOURCE_DIR}/VERSION" 
  OUTPUT_VARIABLE VER)
message("version ${VER}")

execute_process(COMMAND bash "-c" "cp ${CMAKE_CURRENT_SOURCE_DIR}/config/config-aarch.h ${CMAKE_CURRENT_SOURCE_DIR}/config/config.h")

set (compileoptions -std=c99 -D__BSD_VISIBLE -D_ALL_SOURCE -D_XOPEN_SOURCE=600 -D_POSIX_C_SOURCE=200112 -D_ISOC99_SOURCE -D_REENTRANT -D_BSD_SOURCE -D_DEFAULT_SOURCE -D_DARWIN_C_SOURCE -DVERSION=\"${VER}\")
set (compileoptions ${compileoptions} -Wall -Wextra -pedantic -Wshadow -Wcast-qual -Wbad-function-cast -Wstrict-prototypes -Wno-overlength-strings -v)

set(sources acl.c  auth.c  config.c  direct.c  forward.c  http.c  main.c  ntlm.c pages.c  proxy.c  scanner.c  socket.c  utils.c  xcrypt.c)

add_library(duktape duktape/duktape.c)
add_executable(cntlm-noduk)
add_executable(cntlm-duk)

target_compile_options(cntlm-duk PUBLIC ${compileoptions})
target_compile_options(cntlm-noduk PUBLIC ${compileoptions})


target_sources(cntlm-noduk PUBLIC ${sources})

target_compile_options(cntlm-duk PUBLIC "-DENABLE_PAC=1")
target_link_libraries(cntlm-duk duktape)
target_sources(cntlm-duk PUBLIC pac.c ${sources})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Dconfig_arc4random_buf=0")

