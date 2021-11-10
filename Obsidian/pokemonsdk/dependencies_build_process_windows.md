# Windows dependencies build process
## Step1 - Setup PSDK Project

The PSDK project has several dependencies comming from RubyInstaller, in order to be independent from any Ruby Installation (on player side) you need to perform the following steps:
1. In root delete all `.dll` and `.exe` files
2. In `<PROJECT>/lib/` delete the ruby folder, delete all `.so` files.
3. Copy the folder `<RUBY>/lib/ruby` to `<PROJECT>/lib/`
4. In `<PROJECT>/ruby_builtin_dlls/` delete all `.dll` files.
5. Copy all the `.dll` files from `<RUBY>/bin/ruby_builtin_dlls` to `<PROJECT>/ruby_builtin_dlls/`
6. Update `<PROJECT>/ruby_builtin_dlls/ruby_builtin_dlls.manifest` with information commin from `<RUBY>/bin/ruby_builtin_dlls/ruby_builtin_dlls.manifest`
7. Copy the `msvcrt-ruby<VER>.dll` from `<RUBY>/bin` to your project root.
8. Copy the file `<RUBY>/msys32/mingw32/bin/libstdc++-6.dll` to `<PROJECT>/ruby_builtin_dlls/`
9. `[Optional]` Compress all the DLL (putting aside `libcrypto-<VER>.dll`, `libgcc_s_dw2-1.dll`) with `upx`

Note: In the futur those steps won't apply to PSDK, we'll write a universal launcher that will need those steps but that will be able to run mostly all PSDK games.

## Step2 - Build Game.exe

1. Outside of the project, pull `https://github.com/NuriYuri/Windows-PSDK-Game.exe.git`
2. Setup a Visual Studio 20XX solution from that (if you're using Windows you should know how to do that, I'm not your mother)
3. Convert the file `<RUBY>/lib/libmsvcrt-ruby300.dll.a` to `ruby.lib` with `objconv`. Copy this file to the folder containing `Game.cpp`.
4. Grab the configuration file of Ruby for your MSVC installation. (See ruby/ruby git)
5. Give the configuration folder path without including the `ruby` parent folder of `config.h` to Visual Studio 20XX
6. Give the header path to Visual Studio 20XX, it should be `<RUBY>/include/ruby-<VER>/`
7. Build `Game.exe` (with MT) and copy it to the project
8. Build `Game-noconsole.exe` (with MT, & NO_CONSOLE)  and copy it to the project

## Step3 - Build SFML

1. Download the source code from https://www.sfml-dev.org/download/sfml/2.5.1/index.php
2. **Extract it somewhere, set the `SFML_DIR` environment variable as the folder containing the file `CONTRIBUTING.md`**
3. Go to the `SFML_DIR` folder, open `cmd` and execute the command `ridk enable`
4. Run the command `cmake -G "MinGW Makefiles" -DSFML_BUILD_EXAMPLES=False .`
5. Run the command `mingw32-make`
6. Copy all the `.dll` files from `<SFML_DIR>/lib/` to `<PROJECT>/ruby_builtin_dlls/`
7. Copy all the `.dll` files from `<SFML_DIR>/lib/` to `<RUBY>/msys32/mingw32/bin/`
8. Copy all the `.a` files from `<SFML_DIR>/lib/` to `<RUBY>/msys32/mingw32/lib/`
9. Copy the folder `include/SFML` to `<RUBY>/msys32/mingw32/include/`
10. Copy the file `extlibs/bin/x86/openal32.dll` to `<PROJECT>/ruby_builtin_dlls/`

## Step4 - Build LiteRGSS2

This part is still a bit experimental and subject to change.
1. Outside of the project, pull `git@gitlab.com:pokemonsdk/litergss2.git`
2. Run the command `git submodule update --init --recursive`
3. Run the command `depclean`
4. You should be in the litecgss folder
5. Run the command `ruby -e"Dir.mkdir('generated') rescue nil;File.write('generated/build.cache','')"`
6. Run the command `cd ../..`
7. Run the command `rake release`
8. You should be in the litcgss folder
9.  copy all the `.a` files from `lib/` to `<RUBY>/msys32/mingw32/lib/`
10. Copy all the `bin/libLiteCGSS_engine.dll` to `<RUBY>/msys32/mingw32/bin/`
11. Copy all the `bin/libLiteCGSS_engine.dll` to `<PROJECT>/ruby_builtin_dlls/`
12. If the compilation of liteRGSS2 failed
    1.  Go back to the LiteRGSS2 project (`cd ../..`)
    2.  Run the `rake clean` command
    3.  Run the `rake release` command
13. Copy the `lib/LiteRGSS.so` file to `<PROJECT>/lib`

## Step 5 - Build Ruby-Fmod

1. Download FMOD 2.x and Install it on your system
2. Copy the file `<FMOD>/api/code/lib/x86/libfmod.a` to `<RUBY>/msys32/mingw32/lib/`
3. Copy the file `<FMOD>/api/code/lib/x86/fmod.dll` to `<RUBY>/msys32/mingw32/bin/`
4. Copy the file `<FMOD>/api/code/lib/x86/fmod.dll` to `<PROJECT>/ruby_builtin_dlls/`
5. Copy all the headers from `<FMOD>/api/code/inc` to `<RUBY>/msys32/mingw32/include/`
6. Outside of the project, pull `https://github.com/NuriYuri/Ruby-Fmod.git`
7. Run the command `rake clean`
8. Run the command `rake compile`
9. Copy the file `lib/RubyFmod.so` to `<PROJECT>/lib/`

## Step 6 - Build sfeMovie (hacky)

1. Outside of the project, pull `https://github.com/Yalir/sfeMovie`
2. Run the command `pacman -S tar yasm make`
3. Run the command `pacman -S mingw32/mingw-w64-i686-ffmpeg` (x86, you can add yyu after S if some package doesn't download)
4. Run the command `cmake -G "MSYS Makefiles" .`
   1. You'll see the error message "Only Visual Studio (2013 and later) is supported on Windows"
   2. Open CMakeLists.txt and comment the condition showing this error message (line 42 to 44)
5. Run the command `cmake .` (it'll fail)
6. Run the command `cmake -DSFEMOVIE_BUILD_FFMPEG=FALSE -DSFML_INCLUDE_DIR=<SFML_DIR>/include`
7. Run the command `make` (it'll fail because of some avutil stuff)
8. Delete the folder `FFmpeg/include/libavutil`
9. Copy the folder `<RUBY>/msys32/mingw32/include/libavutil` to `FFmpeg/include/`
10. Open the file `src/Stream.cpp` and replace the missing constants to `AV_<constant_name>`
10. Open the file `src/VideoStream.cpp` and replace the missing constants to `AV_<constant_name>` (line 63 & 280)
11. Copy the file `bin/libsfeMovie.dll.a` to `<RUBY>/msys32/mingw32/lib/`
12. Copy the file `bin/libsfeMovie.dll` to `<RUBY>/msys32/mingw32/bin/`
13. Copy the file `bin/libsfeMovie.dll` to `<PROJECT>/ruby_builtin_dlls/`
14. Copy the folder `include/sfeMovie` to `<RUBY>/msys32/mingw32/include/`

Source: Build sfeMovie by following this tutorial: https://mightynotes.wordpress.com/2017/05/11/building-sfemovie-on-msys2-a-hacky-way/

## Step 7 - Build SFEMovie (the ruby library)

1. Outside of the project, pull `git@gitlab.com:NuriYuri/sfemovie.git`
2. Run the command `rake clean`
3. Run the command `rake compile`
4. Copy the file `lib/SFEMovie.so` to `<PROJECT>/lib`
5. Go to the folder `<RUBY>/msys32/mingw32/bin/` and copy the following files to `<PROJECT>/ruby_builtin_dlls/`
   * libmfx-1.dll
   * libgsm.dll
   * libcelt0-2.dll
   * libgnutls-30.dll
   * libbz2-1.dll
   * libmodplug-1.dll
   * librtmp-1.dll
   * libsrt.dll
   * liblzma-5.dll
   * libmp3lame-0.dll
   * libopencore-amrnb-0.dll
   * libopencore-amrwb-0.dll
   * libopenjp2-7.dll
   * libopus-0.dll
   * libspeex-1.dll
   * libtheoradec-1.dll
   * libtheoraenc-1.dll
   * libvorbis-0.dll
   * libvorbisenc-2.dll
   * libvpx-1.dll
   * libwebp-7.dll
   * libwavpack-1.dll
   * libwebpmux-3.dll
   * libx264-159.dll
   * libx265.dll
   * xvidcore.dll
   * libxml2-2.dll
   * libfreetype-6.dll
   * libhogweed-6.dll
   * libogg-0.dll
   * libnettle-8.dll
   * libpng16-16.dll
   * libharfbuzz-0.dll
   * libglib-2.0-0.dll
   * libgraphite2.dll
   * libidn2-0.dll
   * libp11-kit-0.dll
   * libtasn1-6.dll
   * libunistring-2.dll
   * libpcre-1.dll
   * avcodec-58.dll
   * avformat-58.dll
   * avutil-56.dll
   * libbluray-2.dll
   * swresample-3.dll
   * swscale-5.dll
   * libaom.dll
   * libbrotlicommon.dll
   * libbrotlidec.dll
   * libdav1d.dll
   * libvulkan-1.dll

