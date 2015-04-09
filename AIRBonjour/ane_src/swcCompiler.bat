call %FLEX_SDK_PATH%/bin/acompc -source-path as3_src -include-classes benkuper.nativeExtensions.airBonjour.Bonjour -swf-version=14 -output airBonjour.swc

unzip -o airBonjour.swc -x catalog.xml

call %FLEX_SDK_PATH%/bin/adt -package -target ane airBonjour.ane extension-descriptor.xml -swc airBonjour.swc -platform Windows-x86 -C native_src\Windows-x86 airBonjour-win.dll -C ./ library.swf -platform MacOS-x86 -C ane_build airBonjour.framework -C ./ library.swf

del library.swf
del airBonjour.swc

echo "ok"
#pause