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

	public ref class Port
	{
		public :
			String ^portName;

			SerialPort^ _serialPort;
			
			int bytesSinceLastRead;
			array<unsigned char>^ buffer;

			bool isInit;

			void openPort(String^ portName, int baudRate)
			{
				Console::WriteLine("NativeSerial :: Port :: openPort");

				this->portName = portName;

				Console::WriteLine("PortName = "+this->portName);

				string name;
				string message;

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

				
				try
				{
					_serialPort->Open();
				}catch(Exception^ e)
				{
					Console::WriteLine("Error Opening Port :"+e->Message);
				}

				//Read buffer init
				bytesSinceLastRead = 0;
				buffer = gcnew array<unsigned char>(4096); //buffer length, may need to be higher if more data are passed

				Console::WriteLine("Port is Open ? "+_serialPort->IsOpen);

				isInit = true;
			}

			void closePort()
			{
				_serialPort->Close();
				
			}

			void write(array<unsigned char>^ buffer)
			{
				//Console::WriteLine("Native Serial :: write");
				if(!_serialPort->IsOpen)
				{
					Console::WriteLine("Port write ("+portName+") :: port is not open !");
					return;
				}

				_serialPort->Write(buffer,0,buffer->Length);
			}

			void read()
			{
				if(!isInit) return;
				//Console::WriteLine("Read on Port "+portName);

				try
				{
					int readResult = _serialPort->Read(buffer,bytesSinceLastRead,_serialPort->BytesToRead);
					bytesSinceLastRead += readResult;
					//Console::WriteLine(" -> "+bytesSinceLastRead+" read");
				}
				catch (TimeoutException^) { }			
			}

			void clearBuffer()
			{
				bytesSinceLastRead = 0;
			}
			
	};

	public ref class NativeSerial
	{
		
		public:


			static List<Port ^>^ sPorts;
			static bool isInit;

			static Thread^ readThread;
			static bool doRead;

			static void init()
			{
				if(isInit) return;
				sPorts = gcnew List<Port ^>();


				ThreadStart^ start = gcnew ThreadStart(Read);

				if(readThread && readThread->IsAlive)
				{
					readThread->Abort();
				}

				readThread = gcnew Thread(start);

				doRead = true;
				readThread->Start();


			}

			static void openPort(String^ portName, int baudRate)
			{
				if(getPort(portName) == nullptr)
				{
					Port ^p = gcnew Port();
					sPorts->Add(p);
					p->openPort(portName,baudRate);
				}else
				{
					Console::WriteLine("openPort :: port already exists");
				}
			}

			static void closePort(String^ portName)
			{
				Port^ p = getPort(portName);
				if(p != nullptr)
				{
					sPorts->Remove(p);
					p->closePort();
				}else
				{
					Console::WriteLine("closePort :: port was not opened");
				}
			}

			static void write(String^ portName, array<unsigned char>^ buffer)
			{
				Port ^p = getPort(portName);
				if(p != nullptr)
				{
					p->write(buffer);
				}else
				{
					Console::WriteLine("NativeSerial :: write to "+portName+" : port not in list");
				}
			}

			static Port^ getPort(String^ portName)
			{
				//Console::WriteLine("Searching port "+portName+" in "+sPorts->Count+" opened ports");

				for each(Port^ p in sPorts)
				{
					//Console::WriteLine(portName+"< >"+p->portName);
					if(p->portName == portName)
					{
						//Console::WriteLine("Port found !");
						return p;
					}
				}

				Console::WriteLine("Port not found");
				return nullptr;
			}

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

					Console::WriteLine("List Port using WMI :");
					int i=0;
					for each(ManagementObject^ queryObj in results)
					{
						//Console::WriteLine("-----------------------------------");
						//Console::WriteLine("Win32_PnPEntity instance");
						//Console::WriteLine("-----------------------------------");
						Console::WriteLine("> Name: {0}", queryObj["Name"]);
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


			static void clean()
			{
				for each(Port^ p in sPorts)
				{
					p->closePort();
				}
				
				sPorts->Clear();

				doRead = false;
				readThread->Abort();
			}

			static void Read()
			{
				while (doRead)
				{
					for each(Port^ p in sPorts)
					{
						
						p->read();
					}
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
		printf("NativeSerial :: init\n");

		NativeSerial::init();

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject listPorts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial :: listPorts\n");


		array<String^>^ comPortsArray = NativeSerial::getCOMPorts();
		int numPorts = comPortsArray->Length;

		
		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<String>",0,NULL,&result,NULL);
		FRESetArrayLength(result,numPorts);

		printf("COM Ports found : %i\n",numPorts);

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

		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
		String^ portName = gcnew String((const char *)port);

		NativeSerial::closePort(portName);

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject update(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial Extension :: update\n");

		int numBytes = 0;

		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
		String^ portName = gcnew String((const char *)port);
		Port^ p = NativeSerial::getPort(portName);

		if(p != nullptr) 
		{
			
			try
			{
				FREByteArray bytes;
				FREAcquireByteArray(argv[1],&bytes);
		
				numBytes = p->bytesSinceLastRead;
				for(int i=0;i<numBytes;i++) bytes.bytes[i] = p->buffer[i];

				p->clearBuffer();

				FREReleaseByteArray(argv[1]);

			

			}catch(exception e)
			{
				printf("Error reading : %s\n");
			}
		}else
		{
			printf("COM Port \"%s\" not found !\n",port);
		}

		FREObject result;
		FRENewObjectFromInt32(numBytes,&result);
		return result;

	}

	FREObject write(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
		String^ portName = gcnew String((const char *)port);

		//printf("NativeSerial Extension :: write to Port : %s\n",port);

		try
		{
			FREByteArray bytes;
			FREAcquireByteArray(argv[1],&bytes);
		

			int numBytes = bytes.length;
			array<unsigned char>^ bytesToWrite = gcnew array<unsigned char>(numBytes);
			for(int i=0;i<numBytes;i++) bytesToWrite[i] = bytes.bytes[i];

			FREReleaseByteArray(argv[1]);

			

			NativeSerial::write(portName,bytesToWrite);

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
		NativeSerial::clean();
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