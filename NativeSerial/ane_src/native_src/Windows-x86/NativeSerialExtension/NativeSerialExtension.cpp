// This is the main DLL file.

//#include "stdafx.h"

#include "NativeSerialExtension.h"

#include <iostream>
#include <string>
#include <stdlib.h>
#include <msclr\marshal.h>


using namespace std;



using namespace System;
using namespace System::Collections::Generic;
using namespace System::Management;

using namespace msclr::interop;

namespace NativeSerialExtension {

	public ref class NativeSerial
	{
		
		public:
			static array<String ^>^ getCOMPorts()
			{
				array<String ^>^ ports;

				 try
				{
					ManagementObjectSearcher^ searcher = 
						gcnew ManagementObjectSearcher("root\\CIMV2", 
						"SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%(COM[0-9]%)%'"); 

					ManagementObjectCollection^ results = searcher->Get();
					
					ports = gcnew array<String^>(results->Count);

					Console::WriteLine("List Port using WMI");
					int i=0;
					for each(ManagementObject^ queryObj in results)
					{
						//Console::WriteLine("-----------------------------------");
						//Console::WriteLine("Win32_PnPEntity instance");
						//Console::WriteLine("-----------------------------------");
						Console::WriteLine("Name: {0}", queryObj["Name"]);
						ports[i] = queryObj["Name"]->ToString();
						i++;
					}
				}
				catch (ManagementException^ e)
				{
					Console::WriteLine("An error occurred while querying for WMI data: " + e->Message);
					//return gcnew array<String ^>(0);
				}

				return ports;
			}

	};
}

using namespace NativeSerialExtension;


extern "C"
{

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: init\n");

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject listPorts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: listPorts\n");

		array<String^>^ comPortsArray = NativeSerial::getCOMPorts();
		int numPorts = comPortsArray->Length;

		
		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<String>",0,NULL,&result,NULL);
		FRESetArrayLength(result,numPorts);

		printf("COM Ports found : %i",numPorts);

		marshal_context ^ context = gcnew marshal_context();

		for(int i=0;i<numPorts;i++)
		{
			
			const char* cstr = context->marshal_as<const char*>(comPortsArray[i]);

			FREObject curPort = NULL;

			FRENewObjectFromUTF8(comPortsArray[i]->Length,(const uint8_t*)cstr,&curPort);
			FRESetArrayElementAt(result,i,curPort);
			
		}

		delete context;
		

		return result;

	}

	FREObject openPort(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: openPort\n");

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject closePort(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: closePort\n");

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject update(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: update\n");

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject write(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial Extension :: write\n");

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	// Flash Native Extensions stuff
	void NativeSerialContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Native Serial Extension v0.1 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "listPorts",    NULL, &listPorts },
			{ (const uint8_t*) "openPort",        NULL, &openPort },
			{ (const uint8_t*) "closePort", NULL, &closePort },
			{ (const uint8_t*) "update", NULL, &update },
			{ (const uint8_t*) "write", NULL, &write }
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;

	}


	void NativeSerialContextFinalizer(FREContext ctx) 
	{
		return;
	}

	void NativeSerialExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &NativeSerialContextInitializer;
		*ctxFinalizer   = &NativeSerialContextFinalizer;
	}

	void NativeSerialExtFinalizer(void* extData) 
	{
		return;
	}
}