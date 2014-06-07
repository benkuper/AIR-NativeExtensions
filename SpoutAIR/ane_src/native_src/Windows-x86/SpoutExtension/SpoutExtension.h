#include <Windows.h>
#include "FlashRuntimeExtensions.h"

#pragma once


extern "C"
{
	__declspec(dllexport) void SpoutExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void SpoutExtFinalizer(void* extData);

}