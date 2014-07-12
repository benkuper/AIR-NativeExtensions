// SpoutExtension.cpp : Defines the exported functions for the DLL application.
//

#pragma once



#include "SpoutExtension.h"
#include "Spout2Helper.h"

#include <stdio.h>
#include <string>



//#include <pthread.h>

using namespace std;


//HWND hWnd;

//Sender
SpoutSender * spoutSender;
//Receiver
SpoutReceiver * spoutReceiver;
//Common
GLuint currentTexID = 1;

extern "C"
{

	
	

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("Spout Extension :: init\n");
		
		InitGL();

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}


	FREObject createSender(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("Spout Extension :: createSender\n");

		bool res = true;

		const uint8_t * senderName = NULL;
		uint32_t len;

		int texWidth = 0;
		int texHeight = 0;

		FREGetObjectAsUTF8(argv[0],&len, &senderName);
		FREGetObjectAsInt32(argv[1],&texWidth);
		FREGetObjectAsInt32(argv[2],&texHeight);

		if(texWidth == 0 || texHeight == 0 || len == 0)
		{
			res = false;
		}else
		{
			printf("> create sender %s : %i*%i",senderName,texWidth,texHeight);

			spoutSender = new SpoutSender();						// Create a new Spout sender
			currentTexID = 0;									// Initially there is no local OpenGL texture ID
			InitGLtexture(currentTexID,texWidth,texHeight);	// Create an OpenGL texture for data transfers

			res = spoutSender->CreateSender((char *)senderName,texWidth,texHeight);
		}

		FREObject result;
		FRENewObjectFromBool(res,&result);
		return result;

	}


	FREObject sendTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("Spout Extension :: sendTexture\n");

		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool shareResult = false;

		FREBitmapData bd;
		try
		{
			FREAcquireBitmapData(argv[1],&bd);
			FREReleaseBitmapData(argv[1]);

			//printf("BitmapDataToGL\n");
			bitmapDataToGL(currentTexID, bd.width,bd.height,(GLvoid *)bd.bits32);

			shareResult = spoutSender->SendTexture(currentTexID,GL_TEXTURE_2D,bd.width,bd.height);
			//printf("sendTexture result : %i\n",shareResult);

		}catch(exception e)
		{
			printf("Exception ! %s",e.what());
		}		

		FREObject result;
		FRENewObjectFromBool(shareResult,&result);
		return result; 

	}

	//Receiving

	FREObject createReceiver(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("Spout Extension :: createReceiver\n");

		if(spoutReceiver == NULL)
		{
			printf("> Create SpoutReceiver instance\n");
			spoutReceiver = new SpoutReceiver();
		}
		  
		 
		
		bool res = true;


		unsigned int rW = 1;
		unsigned int rH = 1;  

		const uint8_t * name;
		uint32_t len = 0;
		FREGetObjectAsUTF8(argv[0],&len,&name);


		char senderName[256];
		strcpy_s(senderName,256,(char *)name);
		res = spoutReceiver->CreateReceiver(senderName, rW, rH);
		
		FREObject result = NULL; 

		if(res) 
		{
			printf("SpoutExtension2 :: found receiver : %s :: %i*%i\n",senderName,rW,rH);
			 
			//currentTexID = 0;									// Initially there is no local OpenGL texture ID
			//InitGLtexture(currentTexID,rW,rH);	// Create an OpenGL texture for data transfers


			FREObject args[3];
			FRENewObjectFromUTF8(strlen(senderName),(const uint8_t*)senderName,&args[0]);
			FRENewObjectFromInt32(rW,&args[1]);
			FRENewObjectFromInt32(rH,&args[2]);
			
			FREResult fre = FRENewObject((const uint8_t *)"benkuper.nativeExtensions.SpoutReceiver",3,args,&result,NULL);
			printf("SpoutReceiver creation result : %s\n",fre == 0?"OK":"Error");
		}

		//printf("SpoutReceiver result %i : %i*%i\n",res,rW,rH);

		return result;
	}

	

	FREObject receiveTexture(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * sharingName;
		uint32_t sharingNameLength;
		FREGetObjectAsUTF8(argv[0],&sharingNameLength,&sharingName);

		bool res = false;

		FREBitmapData bd;
		try
		{
			FREObject receiver = NULL;
			FREAcquireBitmapData(argv[1],&bd);
			

			FREObject methodResult = NULL;

			unsigned int w = bd.width;
			unsigned int h = bd.height;

			bool memoryMode = false;//unused
			char safeName[256];
			strcpy_s(safeName,256,(char *)sharingName);

			if(spoutReceiver->GetImageSize(safeName, w, h,memoryMode));

			//printf("Extension GetImageSize check %i / %i\n",w,h);

			if(w != bd.width || h != bd.height)
			{

				FREObject args[2];
				FRENewObjectFromInt32(w,&args[0]);
				FRENewObjectFromInt32(h,&args[1]);

				FREReleaseBitmapData(argv[1]);

				FREResult f = FRECallObjectMethod(argv[2],(const uint8_t *)"setSize",2,args,&methodResult,NULL);
				//printf("Set size result : %i, will skip receiveImage this time\n",f);

			}else
			{
				res = spoutReceiver->ReceiveImage(safeName, w, h,(unsigned char *)bd.bits32,GL_BGRA_EXT);
				//printf("SpoutExtension ReceiveImage Result : %i (%i %i)\n",res,w,h);
				FREReleaseBitmapData(argv[1]);
			}

			
			

			if(res)
			{				
				if(w != bd.width || h != bd.height)
				{
					printf("BitmapData & Receive Texture different size !!\n");
				}else
				{
					
					FREResult f = FRECallObjectMethod(argv[2],(const uint8_t *)"update",0,NULL,&methodResult,NULL);
				}
			}else
			{
				printf("SpoutExtension :: ReceiveImage failed. \n");
				/*
				spoutReceiver->ReleaseReceiver();
				spoutReceiver->CreateReceiver((char *)sharingName, w, h);
				*/
			}
			
			FREReleaseBitmapData(argv[1]);
		

			//printf("Call method result : %i\n",f);
		}catch(exception e)
		{
			printf("Exception ! %s\n",e.what());
		}

		FREObject result;
		FRENewObjectFromBool(res,&result);
		return result;
	}


	FREObject showPanel(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		if(spoutReceiver != NULL) spoutReceiver->SelectSenderPanel();

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	// Flash Native Extensions stuff
	void SpoutContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Spout2 Extension v0.2 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "createSender",    NULL, &createSender },
			{ (const uint8_t*) "sendTexture",    NULL, &sendTexture },
			{ (const uint8_t*) "createReceiver",    NULL, &createReceiver },
			{ (const uint8_t*) "receiveTexture",    NULL, &receiveTexture },
			{ (const uint8_t*) "showPanel",    NULL, &showPanel }
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