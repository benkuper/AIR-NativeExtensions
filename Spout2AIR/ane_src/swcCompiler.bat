call %FLEX_SDK_PATH%\bin\acompc -source-path as3_src -include-classes benkuper.nativeExtensions.Spout -swf-version=14 -output Spout.swc

unzip -o Spout.swc -x catalog.xml

call %FLEX_SDK_PATH%\bin\adt -package -target ane Spout.ane extension-descriptor.xml -swc Spout.swc -platform Windows-x86 -C native_src\Windows-x86 SpoutExtension.dll -C ./ library.swf

del library.swf
del Spout.swc

echo "ok"
pause