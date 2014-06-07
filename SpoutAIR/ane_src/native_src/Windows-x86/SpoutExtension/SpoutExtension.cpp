// SpoutExtension.cpp : Defines the exported functions for the DLL application.
//
#include "SpoutExtension.h"
#include <stdio.h>
#include <string>

#include "SpoutHelpers.h"

using namespace std;



//spoutDirectX spoutDX;
//ID3D11Device * dxDevice;
//ID3D11DeviceContext * context;

HWND hWnd;

extern "C"
{

	BOOL CALLBACK EnumProc(HWND hwnd, LPARAM lParam)
	{
		DWORD windowID;
		GetWindowThreadProcessId(hwnd, &windowID);

		if (windowID == lParam)
		{
			printf("Found HWND !\n");
			hWnd = hwnd;

			return false;
		}

		return true;
	}


	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("Spout Extension :: init\n");
		DWORD processID = GetCurrentProcessId();
		EnumWindows(EnumProc, processID);

		bool initResult = false;

		printf("Init Spout with hwnd : %i\n",hWnd);
		
		initResult = initSpout(hWnd);

		printf("> Spout init result : %d\n",initResult);
		
		/*
		dxDevice = spoutDX.CreateDX11device(NULL);
		dxDevice->GetImmediateContext(&context);
		*/

		FREObject result;
		FRENewObjectFromBool(initResult,&result);
		return result;

	}


	FREObject shareTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("Spout Extension :: shareTexture\n");

		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool shareResult = false;

		FREBitmapData bd;
		try
		{
			FREAcquireBitmapData(argv[1],&bd);
			printf("Bitmapdata infos : %i / %i\n",bd.width,bd.height);

			bool bTextureShare = false; //see WinSpoutSDK.cpp

			InitTexture(bd.width,bd.height);
			shareResult = spout.InitSender((char *)sharingName, bd.width,bd.height,bTextureShare,false);

			printf("InitSender result : %d, textureShare result : %d\n",shareResult,bTextureShare);

			FREReleaseBitmapData(argv[1]);

			
			shareResult = true;
		}catch(exception e)
		{
			printf("Exception ! %s",e.what());
		}
		

		
		FREObject result;
		FRENewObjectFromBool(shareResult,&result);
		return result;

	}


	FREObject updateTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("Spout Extension :: updateTexture\n");

		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool shareResult = false;

		FREBitmapData bd;
		try
		{
			FREAcquireBitmapData(argv[1],&bd);
			FREReleaseBitmapData(argv[1]);

			shareResult = updateTexture((GLvoid *)bd.bits32);
			//printf("update result : %d\n",shareResult);

			shareResult = true;
		}catch(exception e)
		{
			printf("Exception ! %s",e.what());
		}
		

		
		FREObject result;
		FRENewObjectFromBool(shareResult,&result);
		return result;

	}

	// Flash Native Extensions stuff
	void SpoutContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Spout Extension v0.1 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "shareTexture",    NULL, &shareTexture },
			{ (const uint8_t*) "updateTexture",    NULL, &updateTexture }
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;

	}


	void SpoutContextFinalizer(FREContext ctx) 
	{
		return;
	}

	void SpoutExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &SpoutContextInitializer;
		*ctxFinalizer   = &SpoutContextFinalizer;
	}

	void SpoutExtFinalizer(void* extData) 
	{
		return;
	}
}