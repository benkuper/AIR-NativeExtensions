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

/*
using namespace InTheHand::Net::Sockets;
using namespace InTheHand::Net::Bluetooth;
*/

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
			bool isOpened;

			bool openPort(String^ portName, int baudRate)
			{
				
				this->portName = portName;

				Console::WriteLine("SerialPort :: openPort "+this->portName);

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
					return false;
				}

				//Read buffer init
				bytesSinceLastRead = 0;
				buffer = gcnew array<unsigned char>(4096); //buffer length, may need to be higher if more data are passed

				//Console::WriteLine("Port is Open ? "+_serialPort->IsOpen);

				isInit = true;
				
				return true;
			}



			void closePort()
			{
				try
				{
					_serialPort->Close();
				}catch(Exception^ e)
				{
					Console::WriteLine("Error closing the port ("+portName+"), maybe device is already disconnected ?");
				}
				
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

			static Thread^ listThread;
			static bool doList;

			static FREContext freContext;

			static bool btLibLoaded;

			static void init(FREContext ctx)
			{
				if(isInit) return;

				freContext = ctx;
				sPorts = gcnew List<Port ^>();


				ThreadStart^ readStart = gcnew ThreadStart(Read);
				if(readThread && readThread->IsAlive) readThread->Abort();
				readThread = gcnew Thread(readStart);
				doRead = true;
				readThread->Start();

				ThreadStart^ listStart = gcnew ThreadStart(ListPorts);
				if(listThread && listThread->IsAlive) listThread->Abort();
				listThread = gcnew Thread(listStart);
				doList = true;
				listThread->Start();
			}

			static bool openPort(String^ portName, int baudRate)
			{
				
				if(getPort(portName) == nullptr)
				{
					Port ^p = gcnew Port();
					
					bool openResult = p->openPort(portName,baudRate);
					if(openResult)
					{
						sPorts->Add(p);
					}

					return openResult;
				}else
				{
					Console::WriteLine("openPort :: port already opened");
					return false;
				}
			}

			static void closePort(String^ portName)
			{
				Console::WriteLine("Close port :"+portName);
				Port^ p = getPort(portName);
				if(p != nullptr)
				{
					//Console::WriteLine("Remove port from list "+portName);
					sPorts->Remove(p);
					p->closePort();
				}else
				{
					//Console::WriteLine("closePort :: port was not opened");
				}
			}

			static bool isOpened(String^ portName)
			{
				Port^ p = getPort(portName);
				return (p != nullptr);
			}


			static void write(String^ portName, array<unsigned char>^ buffer)
			{
				Port ^p = getPort(portName);
				if(p != nullptr)
				{
					p->write(buffer);
				}else
				{
					Console::WriteLine("NativeSerial :: write to "+portName+" : port not opened");
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

			static int getNumCOMPorts()
			{
				 try
				{
					ManagementObjectSearcher^ searcher = 
						gcnew ManagementObjectSearcher("root\\CIMV2", 
						"SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%(COM[0-9]%)%'"); 

					ManagementObjectCollection^ results = searcher->Get();
					return results->Count;

				 }catch (ManagementException^ e)
				{
					Console::WriteLine("An error occurred while querying for WMI data : " + e->Message);
					//return gcnew array<String ^>(0);
				}

				 return 0;
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

					//Console::WriteLine("List Port using WMI :");
					int i=0;
					for each(ManagementObject^ queryObj in results)
					{
						//Console::WriteLine("-----------------------------------");
						//Console::WriteLine("Win32_PnPEntity instance");
						//Console::WriteLine("-----------------------------------");
						//Console::WriteLine("> Name: {0}", queryObj["Name"]);
						ports[i] = queryObj["Name"]->ToString();
						i++;
					}
				}catch (ManagementException^ e)
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

				doList = false;
				listThread->Abort();
			}

			static void Read()
			{
				while (doRead)
				{

					for each(Port^ p in sPorts)
					{
						//Console::WriteLine(p->portName+" is opened ?"+p->_serialPort->IsOpen);
						p->read();
					}
					Sleep(3); // avoid CPU explosion
				}
			}

			static void ListPorts()
			{

				Console::WriteLine("Bluetooth handling");
				/*
				BluetoothClient^ client = gcnew BluetoothClient();
				array<BluetoothDeviceInfo^>^ devices = client->DiscoverDevices();
				

				for each(BluetoothDeviceInfo^ di in devices)
				{ 
					Console::WriteLine(di->DeviceName+" // "+di->DeviceAddress+" // "+di->Connected);
				}
				*/

				int prevNumCOMPorts = 0;

				while(doList)
				{
					int numCOMPorts = getNumCOMPorts();
					if(numCOMPorts != prevNumCOMPorts) 
					{	
						Console::WriteLine("[NativeSerial::ListPort Thread] Ports changed !");
						FREDispatchStatusEventAsync(freContext,(const uint8_t*)"updatePorts",(const uint8_t*)"changed");
						prevNumCOMPorts = numCOMPorts;
					}
					Sleep(500); //list only 2 times / seconds
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

		NativeSerial::init(ctx);


		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	FREObject listPorts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial :: listPorts\n");


		array<String^>^ comPortsArray = NativeSerial::getCOMPorts();
		int numPorts = comPortsArray->Length;

		
		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<String>",0,NULL,&result,NULL);
		FRESetArrayLength(result,numPorts);

		//printf("COM Ports found : %i\n",numPorts);

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
		//printf("NativeSerial Extension :: openPort\n");
		

		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);

		int baud = 0;
		FREGetObjectAsInt32(argv[1],&baud);

		String^ portName = gcnew String((const char *)port);

		bool openResult = NativeSerial::openPort(portName,baud);

		FREObject result;
		FRENewObjectFromBool(openResult,&result);
		return result;

	}


	FREObject isPortOpened(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial Extension :: is Port open ?\n");
		
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);

		String^ portName = gcnew String((const char *)port);

		bool openResult = NativeSerial::isOpened(portName);

		FREObject result;
		FRENewObjectFromBool(openResult,&result);
		return result;

	}

	FREObject closePort(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial Extension :: closePort \n");

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
			{ (const uint8_t*) "isPortOpened",        NULL, &isPortOpened },
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