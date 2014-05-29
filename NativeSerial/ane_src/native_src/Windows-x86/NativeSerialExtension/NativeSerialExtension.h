#include <Windows.h>
#include "FlashRuntimeExtensions.h"
#using <system.management.dll>

#pragma once


extern "C"
{
	__declspec(dllexport) void NativeSerialExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void NativeSerialExtFinalizer(void* extData);

}