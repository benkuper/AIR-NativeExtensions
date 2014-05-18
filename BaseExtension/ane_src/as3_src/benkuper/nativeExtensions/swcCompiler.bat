call acompc -source-path as3_src -include-classes benkuper.nativeExtensions.MyoController -swf-version=14 -output MyoController.swc

unzip -o MyoController.swc -x catalog.xml

call adt -package -target ane MyoController.ane extension-descriptor.xml -swc MyoController.swc -platform Windows-x86 -C native_src\Windows-x86\MyoController\Release MyoController.dll -C ./ library.swf

del library.swf
del MyoController.swc

echo "ok"
pause