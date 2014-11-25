call acompc -source-path as3_src -include-classes benkuper.nativeExtensions.ExtendedMouse -swf-version=14 -output ExtendedMouse.swc

unzip -o ExtendedMouse.swc -x catalog.xml

call adt -package -target ane ExtendedMouse.ane extension-descriptor.xml -swc ExtendedMouse.swc -platform Windows-x86 -C native_src\Windows-x86\MouseExtension\Debug MouseExtension.dll -C ./ library.swf -platform MacOS-x86 -C native_src\MacOS-x86 ExtendedMouse.framework -C ./ library.swf

del library.swf
del ExtendedMouse.swc

echo "ok"
pause