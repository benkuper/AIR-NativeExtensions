#include <Windows.h>
#include "FlashRuntimeExtensions.h"


extern "C"
{
	__declspec(dllexport) void MouseExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void MouseExtFinalizer(void* extData);

}