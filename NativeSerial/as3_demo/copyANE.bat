set LIB_NAME=NativeSerial
set ANE_FILE=%LIB_NAME%.ane
set ANE_PATH="..\ane_src\%LIB_NAME%.ane"

mkdir lib
copy %ANE_PATH% lib\%LIB_NAME%.swc /Y


mkdir extension
mkdir extension\release
mkdir extension\debug

copy %ANE_PATH% extension\release\%ANE_FILE% /Y

copy %ANE_PATH% extension\debug\%ANE_FILE%.zip /Y

unzip -o extension\debug\%ANE_FILE%.zip -d extension\debug\%ANE_FILE% 

del extension\debug\%ANE_FILE%.zip

pause