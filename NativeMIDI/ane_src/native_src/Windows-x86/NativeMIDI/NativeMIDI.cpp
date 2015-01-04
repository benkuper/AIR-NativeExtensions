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


std::vector<RtMidiIn *> openMidiIn;
std::vector<RtMidiOut *> openMidiOut;

/*
RtMidiIn * getMidiIn(RtMidiIn* device)
{
	for (size_t i = 0; i < openMidiIn.size(); ++i) {
        // If two Myo pointers compare equal, they refer to the same Myo device.
		if (openMidiIn[i] == device) {
            return openMidiIn[i];
        }
    }
}
*/

struct midiMessage
{
	RtMidiIn* device;
	byte status;
	byte data1;
	byte data2;
	double stamp;
};


int getDeviceIndex(RtMidiIn *device)
{
	for (size_t i = 0; i < openMidiIn.size(); ++i) {
        // If two Myo pointers compare equal, they refer to the same Myo device.
		if (openMidiIn[i] == device) {
            return i;
        }
    }

	printf("MIDI device not found %i\n",device);
	return -1;
}


void removeDeviceIn(RtMidiIn * device)
{
	printf("Remove device in %i\n",device);
	int id = getDeviceIndex(device);
	if(id != -1) openMidiIn.erase(openMidiIn.begin()+id);
}

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
	FREObject fDevice;
	FRENewObjectFromInt32((int)m.device,&fDevice);

	FREObject args[5];
	args[0] = fStatus;
	args[1] = fD1;
	args[2] = fD2;
	args[3] = fStamp;
	args[4] = fDevice;

	FREObject fm = NULL;
	FREResult fre = FRENewObject((const uint8_t *)"benkuper.nativeExtensions.MIDIMessage",5,args,&fm,NULL);
			
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
		//printf("Check thread, %i devices\n",openMidiIn.size());
		for(int di=0;di<openMidiIn.size();di++)
		{
			
			RtMidiIn * in = openMidiIn[di];
			stamp = in->getMessage(&message );
			
			nBytes = message.size();

			//printf("> check for %i, %i\n",di,in);
		//	printf("Midi in %i get message %i\n",in,stamp);


			for ( i=0; i<nBytes; i++ )
			{
				printf("Byte %i = %i\n", i,(byte)message[i]);
			}

			if ( nBytes > 0 )
			{
				printf(">>> stamp = %d\n",stamp);
			}

			if(nBytes == 3) //complete midi message
			{
			
				midiMessage m;
				m.device = in;
				m.stamp = stamp;
				m.status = message[0];
				printf("Status %i from %i\n",m.status,in);
				m.data1 = message[1];
				m.data2 = message[2];

				messageQueue.push_back(m);

				FREDispatchStatusEventAsync(ctx,(const uint8_t *)"data",(const uint8_t *)"none");
			}

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

		//printf("Native MIDI :: listInputDevices > %i devices detected :\n",nPorts);

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
			//printf("[%i] %s\n",i,portName.c_str());

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

		//printf("Native MIDI :: listOutputDevices > %i devices detected :\n",nPorts);

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
			//printf("[%i] %s\n",i,portName.c_str());

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
		
		int pointer = -1;
		try {
			RtMidiIn* in = new RtMidiIn();
			in->openPort(index);
			openMidiIn.push_back(in);

			pointer = (int)in;
			printf("Open midi pointer : %i (%s), num open devices :  %i\n",pointer,in->getPortName(index).c_str(),openMidiIn.size());
			// Don't ignore sysex, timing, or active sensing messages.
			midiin->ignoreTypes( false, false, false );

		}
		catch ( RtMidiError &error ) {
			error.printMessage();
		}		
		
		FREObject result;
		FRENewObjectFromInt32(pointer,&result);
		return result;
	}

	FREObject openOutputDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = 0;
		FREGetObjectAsInt32(argv[0],&index);

		printf("Native MIDI :: open output device %i\n",index);

		int pointer = -1;
		
		try {
			RtMidiOut* out = new RtMidiOut();
			out->openPort(index);
			//openMidiOut.push_back(in);

			pointer = (int)out;
			printf("Open midi pointer : %i\n",pointer);
			// Don't ignore sysex, timing, or active sensing messages.
			midiin->ignoreTypes( false, false, false );

		}
		catch ( RtMidiError &error ) {
			error.printMessage();
		}	

		FREObject result;
		FRENewObjectFromInt32(pointer,&result);
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
		int pointer = 0;
		FREGetObjectAsInt32(argv[0],&pointer);
		
		try
		{
			RtMidiIn *in = (RtMidiIn *)pointer;
			if(in->isPortOpen()) in->closePort();
			removeDeviceIn(in);
			printf("Num open midi devices %i\n",openMidiIn.size());
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
		int pointer = 0;
		FREGetObjectAsInt32(argv[0],&pointer);

		try
		{
			RtMidiOut *out = (RtMidiOut *)pointer;
			if(out->isPortOpen()) out->closePort();
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

		for(int i=0;i<openMidiIn.size();i++)
		{
			openMidiIn[i]->closePort();
		}

		delete midiin;
	    delete midiout;
	}

	void cleanThread()
	{
		exitRunThread = true;
		try
		{
			//pthread_cancel(readThread);
		}catch(exception e)
		{
			printf("Thread already exited !");
		}

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