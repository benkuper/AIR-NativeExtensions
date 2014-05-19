// BaseExtension.cpp : Defines the exported functions for the DLL application.
//

#include <iostream>

#include "DMXExtension.h"

#define DMX_DATA_LENGTH 513 // Includes the start code

//include different devices
#include "EnttecDMXPro.h"


using namespace std;

extern "C"
{

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	} 

	FREObject listDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{

		const int maxDevices = 8;
		char * descriptions[maxDevices];
		char * serials[maxDevices];

		int numDevices = FTDI_GetDevices(descriptions,serials,maxDevices); 
		
		int numGoodDevices = 0;

		/*
		for(int i=0;i<numDevices;i++)
		{
			bool deviceIsDMX = strstr(descriptions[i],"DMX") != NULL;
			printf(" #%d > Description : %s | S/N : %s | isDMX ? %i\n",i,descriptions[i],serials[i],deviceIsDMX);


			if(deviceIsDMX) numGoodDevices++;
		}
		*/
		
		FREObject as3Devices = NULL;
		FRENewObject((const uint8_t*)"Vector.<benkuper.nativeExtensions.DMXDevice>",0,NULL,&as3Devices,NULL);
		//FRESetArrayLength(as3Devices,numGoodDevices);

		int pushIndex = 0;

		for(int i=0;i<numDevices;i++)
		{
			bool deviceIsDMX = strstr(descriptions[i],"DMX") != NULL;
			
			if(deviceIsDMX)
			{
				FREObject index;
				FRENewObjectFromInt32(i,&index);

				FREObject desc;
				FRENewObjectFromUTF8(64,(const uint8_t *)descriptions[i],&desc);

				FREObject serial;
				FRENewObjectFromUTF8(64,(const uint8_t *)serials[i],&serial);

				FREObject constructorProps[3];
				constructorProps[0] = index;
				constructorProps[1] = desc;
				constructorProps[2] = serial;

				FREObject as3Device = NULL;
				FRENewObject((const uint8_t *)"benkuper.nativeExtensions.DMXDevice",3,constructorProps,&as3Device,NULL);

				FRESetArrayElementAt(as3Devices,pushIndex,as3Device);
				pushIndex++;
			}
		}

		printf("[DMXExtension] Looking for Devices... Found %i DMX devices\n",pushIndex);

		
		return as3Devices;

	}

	FREObject openDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{

		int deviceIndex = 0;
		FREGetObjectAsInt32(argv[0],&deviceIndex);
		uint16_t openResult = FTDI_OpenDevice(deviceIndex);
		
		FREObject result;
		FRENewObjectFromBool(openResult == 0,&result);

		return result;

	}

	FREObject sendValue(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		unsigned char myDmx[DMX_DATA_LENGTH];
			// Looping to Send DMX data
			for (int i = 0; i < 1000 ; i++)
			{
				// initialize with data to send
				memset(myDmx,i,DMX_DATA_LENGTH);
				// Start Code = 0
				myDmx[0] = 0;
				// actual send function called 
				int res = FTDI_SendData(SET_DMX_TX_MODE, myDmx, DMX_DATA_LENGTH);
				// check response from Send function
				if (res < 0)
				{
					printf("FAILED: Sending DMX to PRO \n");
					FTDI_ClosePort();
					break;
					//return -1;
				}
				// output debug
				printf("Iteration: %d\n", i);
				printf("DMX Data SENT from 0 to 10: ");
				for (int j = 0; j <= 8; j++)
					printf (" %d ",myDmx[j]);				
			}

		FREObject result;
		FRENewObjectFromBool(true,&result);

		return result;
	}

	FREObject sendValues(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		unsigned char myDmx[DMX_DATA_LENGTH];

			// Looping to Send DMX data
			for (int i = 0; i < 1000 ; i++)
			{
				// initialize with data to send
				memset(myDmx,i,DMX_DATA_LENGTH);
				// Start Code = 0
				myDmx[0] = 0;
				// actual send function called 
				int res = FTDI_SendData(SET_DMX_TX_MODE, myDmx, DMX_DATA_LENGTH);
				// check response from Send function
				if (res < 0)
				{
					printf("FAILED: Sending DMX to PRO \n");
					FTDI_ClosePort();
					break;
					//return -1;
				}
				// output debug
				printf("Iteration: %d\n", i);
				printf("DMX Data SENT from 0 to 10: ");
				for (int j = 0; j <= 8; j++)
					printf (" %d ",myDmx[j]);				
			}

		FREObject result;
		FRENewObjectFromBool(true,&result);

		return result;
	}
	


	// Flash Native Extensions stuff
	void DMXContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 


		printf("*** DMX Extension v0.1 by Ben Kuper ***\n");

 
		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "listDevices",    NULL, &listDevices },
			{ (const uint8_t*) "openDevice",        NULL, &openDevice },
			{ (const uint8_t*) "sendValue", NULL, &sendValue },
			{ (const uint8_t*) "sendValues", NULL, &sendValues}
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;
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