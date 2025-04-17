cmake ..   -DCMAKE_BUILD_TYPE=Release   -DCMAKE_TOOLCHAIN_FILE=../arm.cmake   -DENABLE_MMAL=OFF   -DENABLE_PULSEAUDIO=OFF   -DENABLE_X11=OFF   -DENABLE_OPENGL=OFF   -DThreads_FOUND=TRUE   -DCURL_LIBRARY=/usr/lib/aarch64-linux-gnu/libcurl.so   -DCURL_INCLUDE_DIR=/usr/include/aarch64-linux-gnu  -DCMAKE_EXE_LINKER_FLAGS="\
    /usr/lib/aarch64-linux-gnu/libssl.so.1.1 \
    /usr/lib/aarch64-linux-gnu/libcrypto.so.1.1 \
    /usr/lib/aarch64-linux-gnu/libcurl.so \
    -L/usr/lib/aarch64-linux-gnu \
    -Wl,-rpath-link,/usr/lib/aarch64-linux-gnu \
    -L/usr/lib/aarch64-linux-gnu/pulseaudio \
    -Wl,-rpath-link,/usr/lib/aarch64-linux-gnu/pulseaudio"
