// BaseExtension.cpp : Defines the exported functions for the DLL application.
//

#include "DMXExtension.h"

using namespace std;

extern "C"
{

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	// Flash Native Extensions stuff
	void DMXContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		*numFunctionsToSet = 1; 
 
		FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)*2); 

		func[0].name = (const uint8_t*)"init"; 
		func[0].functionData = NULL; 
		func[0].function = &init; 
		

		*functionsToSet = func; 
	}


	void DMXContextFinalizer(FREContext ctx) 
	{
		return;
	}

	void DMXExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &DMXContextInitializer;
		*ctxFinalizer   = &DMXContextFinalizer;
	}

	void DMXExtFinalizer(void* extData) 
	{
		return;
	}
}