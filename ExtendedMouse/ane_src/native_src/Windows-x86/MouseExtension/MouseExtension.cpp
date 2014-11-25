// BaseExtension.cpp : Defines the exported functions for the DLL application.
//

#include "MouseExtension.h"
#include <iostream>

using namespace std;

extern "C"
{

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject setCursorPos(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int tx = 0;
		int ty = 0;
		FREGetObjectAsInt32(argv[0], &tx);
		FREGetObjectAsInt32(argv[1], &ty);

		//printf("[Mouse Extension] Set cursor pos : %i / %i\n",tx,ty);

		SetCursorPos(tx,ty);

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	// Flash Native Extensions stuff
	void MouseContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Extended Mouse Native Extension v0.1 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "setCursorPos",    NULL, &setCursorPos },
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;
	}


	void MouseContextFinalizer(FREContext ctx) 
	{
		return;
	}

	void MouseExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &MouseContextInitializer;
		*ctxFinalizer   = &MouseContextFinalizer;
	}

	void MouseExtFinalizer(void* extData) 
	{
		return;
	}
}