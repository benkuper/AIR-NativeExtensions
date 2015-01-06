call %FLEX_SDK_PATH%/bin/acompc -source-path as3_src -include-classes org.opentekhnia.as3Bonjour.Bonjour -swf-version=14 -output as3Bonjour.swc

unzip -o as3Bonjour.swc -x catalog.xml

call %FLEX_SDK_PATH%/bin/adt -package -target ane as3Bonjour.ane extension-descriptor.xml -swc as3Bonjour.swc -platform Windows-x86 -C native_src\Windows-x86 airBonjour-win.dll -C ./ library.swf

del library.swf
del as3Bonjour.swc

echo "ok"
#pause