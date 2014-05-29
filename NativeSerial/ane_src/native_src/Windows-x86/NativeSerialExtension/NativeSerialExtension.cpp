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

using namespace System::IO::Ports;
using namespace System::Threading;

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

			static SerialPort^ _serialPort;
			static Thread^ readThread;
			static int bytesSinceLastRead;
			static array<unsigned char>^ buffer;

			static void openPort(String^ portName, int baudRate)
			{
				Console::WriteLine("NativeSerial :: openPort");

				string name;
				string message;

				ThreadStart^ start = gcnew ThreadStart(Read);
				if(readThread && readThread->IsAlive)
				{
					readThread->Abort();
				}

				readThread = gcnew Thread(start);

				// Create a new SerialPort object with default settings.
				_serialPort = gcnew SerialPort();

				// Allow the user to set the appropriate properties.
				_serialPort->PortName = portName;
				_serialPort->BaudRate = baudRate;
				
				/*
				_serialPort->Parity = SetPortParity(_serialPort.Parity);
				_serialPort->DataBits = SetPortDataBits(_serialPort.DataBits);
				_serialPort->StopBits = SetPortStopBits(_serialPort.StopBits);
				_serialPort->Handshake = SetPortHandshake(_serialPort.Handshake);
				*/

				// Set the read/write timeouts
				_serialPort->ReadTimeout = 500;
				_serialPort->WriteTimeout = 500;

				_serialPort->Open();
				readThread->Start();

				Console::WriteLine("Port is Open ? "+_serialPort->IsOpen);
			}

			static void closePort()
			{
				_serialPort->Close();
			}

			static void write(array<unsigned char>^ buffer)
			{
				//Console::WriteLine("Native Serial :: write");
				_serialPort->Write(buffer,0,buffer->Length);
			}

			static void clearBuffer()
			{
				bytesSinceLastRead = 0;
			}

			static void Read()
			{
				bytesSinceLastRead = 0;
				buffer = gcnew array<unsigned char>(4096); //buffer length, may need to be higher if more data are passed

				while (true)
				{
					try
					{
						int readResult = _serialPort->Read(buffer,bytesSinceLastRead,_serialPort->BytesToRead);
						bytesSinceLastRead += readResult;
					}
					catch (TimeoutException^) { }

					Sleep(3); // avoid CPU explosion
				}
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

		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);

		int baud = 0;
		FREGetObjectAsInt32(argv[1],&baud);

		String^ portName = gcnew String((const char *)port);

		NativeSerial::openPort(portName,baud);

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
		//printf("NativeSerial Extension :: update\n");

		int numBytes = 0;
		try
		{
			FREByteArray bytes;
			FREAcquireByteArray(argv[0],&bytes);
		
			numBytes = NativeSerial::bytesSinceLastRead;
			for(int i=0;i<numBytes;i++) bytes.bytes[i] = NativeSerial::buffer[i];

			NativeSerial::clearBuffer();

			FREReleaseByteArray(argv[0]);

			

		}catch(exception e)
		{
			printf("Error reading : %s\n");
		}

		FREObject result;
		FRENewObjectFromInt32(numBytes,&result);
		return result;

	}

	FREObject write(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial Extension :: write\n");

		
		try
		{
			FREByteArray bytes;
			FREAcquireByteArray(argv[0],&bytes);
		

			int numBytes = bytes.length;
			array<unsigned char>^ bytesToWrite = gcnew array<unsigned char>(numBytes);
			for(int i=0;i<numBytes;i++) bytesToWrite[i] = bytes.bytes[i];

			FREReleaseByteArray(argv[0]);

			NativeSerial::write(bytesToWrite);

		}catch(exception e)
		{
			printf("Error writing\n");
		}

		

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