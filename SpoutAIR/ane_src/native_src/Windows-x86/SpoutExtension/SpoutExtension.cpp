// SpoutExtension.cpp : Defines the exported functions for the DLL application.
//
#include "SpoutExtension.h"
#include <stdio.h>
#include <string>

#include "SpoutHelpers.h"
#include <pthread.h>

using namespace std;



//spoutDirectX spoutDX;
//ID3D11Device * dxDevice;
//ID3D11DeviceContext * context;

HWND hWnd;


pthread_t receiveThread;
bool doReceive;
int lastSendersCount = 0;

void * receiveThreadLoop(FREContext context)
{
	spoutInterop interop;

	printf("Unity Thread loop start !\n");

	char senderNames[32][256];

	while(doReceive)
	{
		int numSenders = getNumSenders();

		if(numSenders != lastSendersCount)
		{
			printf("Num Senders changed : %i\n",numSenders);

			char newNames[32][256];
			int i,j;
			bool found;
			
			printf("\n\n################ SENDER UPDATE ###############\n\n");
			printf("> Old senders : ");

			for(i=0;i<lastSendersCount;i++)
			{
				printf("%s | ",senderNames[i]);
			}

			printf("\n");
			printf("> New senders : ");
			for(i=0;i<numSenders;i++)
			{
				interop.getSenderNameForIndex(i,newNames[i]);

				printf("%s | ",newNames[i]);
			}

			printf("\n");

			//NEW SENDERS DETECTION
			printf("\n** Detecting new senders **\n");
			for(i=0;i<numSenders;i++)
			{
				//printf("Check for : %s  >>> ",newNames[i]);
				found = false;
				for(j = 0;j<lastSendersCount;j++)
				{
					printf(" | %s ",senderNames[j]);
					if(!found && strcmp(newNames[i],senderNames[j]) == 0) 
					{
							found = true;
							printf("(found !) ");
					}
				}

				//printf("\nFound ? %d\n");
				if(!found) FREDispatchStatusEventAsync(context,(const uint8_t *)"sharingStarted",(const uint8_t *)newNames[i]);
			}
			
			//SENDER STOP DETECTION
			printf("\n** Detecting leaving senders **\n");
			for(int i=0;i<lastSendersCount;i++)
			{
				found = false;
				printf("Check for : %s  >>> ",senderNames[i]);
				for(j = 0;j<numSenders;j++)
				{
					printf(" | %s  ",newNames[j]);
					if(!found && strcmp(senderNames[i],newNames[j]) == 0) 
					{
							found = true;
							printf("(found !) ");
					}
				}

				//printf("\nFound ? %d\n",found);
				if(!found) FREDispatchStatusEventAsync(context,(const uint8_t *)"sharingStopped",(const uint8_t *)senderNames[i]);
			}
			

			memcpy(senderNames,newNames,sizeof(newNames));
		}

		

		lastSendersCount = numSenders;
		
		Sleep(50);
	}

	printf("Receive Thread Loop Exit\n");
	return 0;
}


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

	//Receiving

	FREObject startReceiving(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		if(doReceive)
		{
			pthread_join(receiveThread, NULL);
			doReceive = false;
		}

		doReceive = true;
		int ret = pthread_create(&receiveThread,NULL, receiveThreadLoop,ctx);

		lastSendersCount = 0;

		FREObject result;
		FRENewObjectFromBool(ret == 0,&result);
		return result;
	}

	FREObject stopReceiving(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		doReceive = false;

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}


	FREObject receiveTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool shareResult = false;

		FREBitmapData bd;
		try
		{
			FREAcquireBitmapData(argv[1],&bd);
			FREReleaseBitmapData(argv[1]);

			InitReceiveTexture(bd.width,bd.height);

			bool bTextureShare = false; //see WinSpoutSDK.cpp

			shareResult = spout.InitReceiver((char *)sharingName, bd.width,bd.height, bTextureShare, false);

			printf("Receive result : %s\n",shareResult?"OK":"Error");

			if(shareResult)
			{
				shareResult = getTextureBytes((char *)sharingName, bd.bits32);
				printf("Get Texture Bytes : %s\n",shareResult?"OK":"Error");
			}

		}catch(exception e)
		{
			printf("Exception ! %s\n",e.what());
		}
		
		
		FREObject result;
		FRENewObjectFromBool(shareResult,&result);
		return result;
	}


	FREObject updateReceiveTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool shareResult = false;

		FREBitmapData bd;
		try
		{
			FREAcquireBitmapData(argv[1],&bd);
			FREReleaseBitmapData(argv[1]);

			shareResult = getTextureBytes((char *)sharingName, bd.bits32);

			//printf("Get Texture Bytes : %s\n",shareResult?"OK":"Error");

		}catch(exception e)
		{
			printf("Exception ! %s\n",e.what());
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
			{ (const uint8_t*) "updateTexture",    NULL, &updateTexture },
			{ (const uint8_t*) "startReceiving",    NULL, &startReceiving },
			{ (const uint8_t*) "stopReceiving",    NULL, &stopReceiving },
			{ (const uint8_t*) "receiveTexture",    NULL, &receiveTexture },
			{ (const uint8_t*) "updateReceiveTexture",    NULL, &updateReceiveTexture }
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