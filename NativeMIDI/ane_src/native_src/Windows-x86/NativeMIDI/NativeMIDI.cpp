// NativeMIDIExtension.cpp : Defines the exported functions for the DLL application.
//
// Using RTMidi

#include "NativeMIDI.h"
#include <iostream>

using namespace std;

//rtmidi
#include <cstdlib>
#include "RtMidi.h"

//thread
#include "pthread.h"
pthread_t readThread;
bool exitRunThread;

RtMidiIn  *midiin = 0;
RtMidiOut *midiout = 0;

std::vector<unsigned char> outMessage;

struct midiMessage
{
	byte status;
	byte data1;
	byte data2;
	double stamp;
};

FREObject messageToFre(midiMessage m)
{
	FREObject fStatus;
	FRENewObjectFromInt32((int)m.status,&fStatus);
	FREObject fD1;
	FRENewObjectFromInt32((int)m.data1,&fD1);
	FREObject fD2;
	FRENewObjectFromInt32((int)m.data2,&fD2);
	FREObject fStamp;
	FRENewObjectFromDouble(m.stamp,&fStamp);

	FREObject args[4];
	args[0] = fStatus;
	args[1] = fD1;
	args[2] = fD2;
	args[3] = fStamp;


	FREObject fm = NULL;
	FREResult fre = FRENewObject((const uint8_t *)"benkuper.nativeExtensions.MIDIMessage",4,args,&fm,NULL);
			
	printf("Message to fre FREResult %i\n",fre);

	return fm;
}


vector<midiMessage> messageQueue;

void *MIDIReadThread(FREContext ctx)
{
	printf("MIDI Start read thread\n");
	std::vector<unsigned char> message;
	int nBytes, i;
	double stamp;


	while(!exitRunThread)
	{
		stamp = midiin->getMessage( &message );
		nBytes = message.size();

		for ( i=0; i<nBytes; i++ )
		{
			printf("Byte %i = %i\n", i,(int)message[i]);
		}

		if ( nBytes > 0 )
		{
			printf(">>> stamp = %d\n",stamp);
		}

		if(nBytes == 3) //complete midi message
		{
			
			midiMessage m;
			m.stamp = stamp;
			m.status = message[0];
			m.data1 = message[1];
			m.data2 = message[2];

			messageQueue.push_back(m);

			FREDispatchStatusEventAsync(ctx,(const uint8_t *)"data",(const uint8_t *)"none");
		}

		// Sleep for 10 milliseconds ... platform-dependent.
		Sleep( 10 );
	   //FREDispatchStatusEventAsync(ctx,(const uint8_t *)"data",(const uint8_t *)"myo");
	}

	printf("Exit Run Thread !\n");

	return 0;
}
   

extern "C"
{

	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		bool initResult = true;

		// RtMidiIn constructor
		try {
			midiin = new RtMidiIn();
		}
		catch ( RtMidiError &error ) {
		error.printMessage();
		initResult = false;
		//exit( EXIT_FAILURE );
		}
		  

		// RtMidiOut constructor
		try {
		midiout = new RtMidiOut();
		}
		catch ( RtMidiError &error ) {
		error.printMessage();
		initResult = false;
		//exit( EXIT_FAILURE );
		}

		int pThreadResult = pthread_create(&readThread, NULL, MIDIReadThread,ctx);

		if (pThreadResult){
			printf("NativeMIDI :: Error on Read thread creation\n");
			initResult = false;
		}

		 //init output message
		outMessage.push_back(0);
		outMessage.push_back(0);
		outMessage.push_back(0);
		  

		FREObject result;
		FRENewObjectFromBool(initResult,&result);
		return result;

	}



	FREObject listInputDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<benkuper.nativeExtensions.MIDIDeviceIn>",0,NULL,&result,NULL);

	    unsigned int nPorts = midiin->getPortCount();

		printf("Native MIDI :: listInputDevices > %i devices detected :\n",nPorts);

		FRESetArrayLength(result,nPorts);
		
		// Check inputs.
		std::string portName;

		for ( unsigned int i=0; i<nPorts; i++ ) {
			try {
				portName = midiin->getPortName(i);
			}
			catch ( RtMidiError &error ) {
				error.printMessage();
				// return NULL;
			}

			//std::cout << "  Input Port #" << i+1 << ": " << portName << '\n';
			printf("[%i] %s\n",i,portName.c_str());

			FREObject args[1];
			FREObject portFRE = NULL;
			FRENewObjectFromUTF8(portName.size(),(const uint8_t*)portName.c_str(),&portFRE);
			args[0] = portFRE;

			FREObject curPort = NULL;
			FREObject exc = NULL;
			FREResult fre =  FRENewObject((const uint8_t *)"benkuper.nativeExtensions.MIDIDeviceIn",1,args,&curPort,&exc);
			//printf("FREResult = %i",fre);

			FRESetArrayElementAt(result,i,curPort);
		}

		return result;

	}

	FREObject listOutputDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<benkuper.nativeExtensions.MIDIDeviceOut>",0,NULL,&result,NULL);

	    unsigned int nPorts = midiout->getPortCount();

		printf("Native MIDI :: listOutputDevices > %i devices detected :\n",nPorts);

		FRESetArrayLength(result,nPorts);
		
		// Check inputs.
		std::string portName;

		for ( unsigned int i=0; i<nPorts; i++ ) {
			try {
				portName = midiout->getPortName(i);
			}
			catch ( RtMidiError &error ) {
				error.printMessage();
				// return NULL;
			}
			//std::cout << "  Input Port #" << i+1 << ": " << portName << '\n';
			printf("[%i] %s\n",i,portName.c_str());

			FREObject args[1];
			FREObject portFRE = NULL;
			FRENewObjectFromUTF8(portName.size(),(const uint8_t*)portName.c_str(),&portFRE);
			args[0] = portFRE;

			FREObject curPort = NULL;
			FREObject exc = NULL;
			FREResult fre =  FRENewObject((const uint8_t *)"benkuper.nativeExtensions.MIDIDeviceOut",1,args,&curPort,&exc);
			//printf("FREResult = %i",fre);

			FRESetArrayElementAt(result,i,curPort);
		}

		return result;

	}

	FREObject openInputDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		
		int index = 0;
		FREGetObjectAsInt32(argv[0],&index);

		printf("Native MIDI :: open input device %i\n",index);
		midiin->openPort(index);
		
		// Don't ignore sysex, timing, or active sensing messages.
		midiin->ignoreTypes( false, false, false );

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	FREObject openOutputDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = 0;
		FREGetObjectAsInt32(argv[0],&index);

		printf("Native MIDI :: open output device %i\n",index);
		midiout->openPort(index);

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	FREObject updateData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int numMessages = messageQueue.size();
		
		printf("Update data, num messages : %i",numMessages);

		FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<benkuper.nativeExtensions.MIDIMessage>",0,NULL,&result,NULL);

		FRESetArrayLength(result,numMessages);

		for(int i=0;i<numMessages;i++)
		{
			
			FRESetArrayElementAt(result,i,messageToFre(messageQueue[i]));
		}

		messageQueue.clear();

		return result;
	}

	FREObject closeInputDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		try
		{
			if(midiin->isPortOpen()) midiin->closePort();
		}catch(exception e)
		{
			printf("Error closing input device.\n");
		}

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	FREObject closeOutputDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		try
		{
			if(midiout->isPortOpen()) midiout->closePort();
		}catch(exception e)
		{
			printf("Error closing output device.\n");
		}

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	FREObject sendMIDIMessage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int status = 0;
		int data1 = 0;
		int data2 = 0;

		FREGetObjectAsInt32(argv[0],&status);
		FREGetObjectAsInt32(argv[1],&data1);
		FREGetObjectAsInt32(argv[2],&data2);

		
		outMessage[0] = (unsigned char)status;
		outMessage[1] = (unsigned char)data1;
		outMessage[2] = (unsigned char)data2;

		midiout->sendMessage(&outMessage);

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	void cleanMIDI()
	{

		if(midiin->isPortOpen()) midiin->closePort();
		if(midiout->isPortOpen()) midiout->closePort();

		delete midiin;
	    delete midiout;
	}

	void cleanThread()
	{
		exitRunThread = true;
		try
		{
			pthread_cancel(readThread);
		}catch(exception e)
		{
			printf("Thread already exited !");
		}

	}

	FREObject clean(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		cleanThread();
		cleanMIDI();

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;

	}

	


	// Flash Native Extensions stuff
	void NativeMIDIContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Native MIDI Extension v0.1 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "listInputDevices",    NULL, &listInputDevices },
			{ (const uint8_t*) "listOutputDevices",   NULL, &listOutputDevices },
			{ (const uint8_t*) "openInputDevice",     NULL, &openInputDevice },
			{ (const uint8_t*) "openOutputDevice",    NULL, &openOutputDevice },
			{ (const uint8_t*) "updateData",		  NULL, &updateData },
			{ (const uint8_t*) "closeInputDevice",    NULL, &closeInputDevice },
			{ (const uint8_t*) "closeOutputDevice",   NULL, &closeOutputDevice },
			{ (const uint8_t*) "sendMessage",		  NULL, &sendMIDIMessage },
			{ (const uint8_t*) "clean",        NULL, &clean }
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;

	}


	void NativeMIDIContextFinalizer(FREContext ctx) 
	{
		cleanThread();
		cleanMIDI();
		return;
	}

	void NativeMIDIExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &NativeMIDIContextInitializer;
		*ctxFinalizer   = &NativeMIDIContextFinalizer;
	}

	void NativeMIDIExtFinalizer(void* extData) 
	{
		return;
	}
}