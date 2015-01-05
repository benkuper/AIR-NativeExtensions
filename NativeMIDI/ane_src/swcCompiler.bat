call %FLEX_SDK_PATH%/bin/acompc -source-path as3_src -include-classes benkuper.nativeExtensions.NativeMIDI -swf-version=14 -output NativeMIDI.swc

unzip -o NativeMIDI.swc -x catalog.xml

call %FLEX_SDK_PATH%/bin/adt -package -target ane NativeMIDI.ane extension-descriptor.xml -swc NativeMIDI.swc -platform Windows-x86 -C native_src\Windows-x86 NativeMIDI.dll -C ./ library.swf -platform MacOS-x86 -C native_src\MacOS\NativeMIDI\Build\Products\Debug ./ -C ./ library.swf

del library.swf
del NativeMIDI.swc

echo "ok"
#pause