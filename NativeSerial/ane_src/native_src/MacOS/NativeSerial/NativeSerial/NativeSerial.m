#include "NativeSerial.h"

#include "stdio.h"
#include "pthread.h"
#include "stdint.h"
#include "String.h"
#include "rs232.h"

 
#include <stdlib.h>


FREContext freContext;


//From ArduinoConnector
pthread_t ptrToThread;
unsigned char buffer[4096];
int bufferSize;

const int maxPorts = 22;
unsigned char comPorts[maxPorts][1024];
bool availableHandles[maxPorts];

pthread_mutex_t safety = PTHREAD_MUTEX_INITIALIZER;

int getHandleForPort(unsigned char *portName)
{
    //printf("Get Handle for port %s :\n",portName);
    
    for(int i=0;i<maxPorts;i++)
    {
        if(strcmp((const char *)portName,(const char *)comPorts[i]) == 0)
        {
            //printf("\t> Found at %i !\n",i);
            return i;
        }
    }

    //printf("...Not found.\n");
    return 0;
}

int getFirstAvailableHandle()
{
    for(int i=0;i<maxPorts;i++)
    {
        bool available = availableHandles[i];
        if(available) return i;
    }
    
    return -1;
}

void as3Print(const char * message)
{
    
    FREDispatchStatusEventAsync(freContext, (const uint8_t*)"print", (const uint8_t*)message);
}
 
	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
        freContext = ctx;
        
		printf("NativeSerial :: init\n");
        as3Print("init");
        
        //Fill with available true
        for(int i=0;i<maxPorts;i++)
        {
            availableHandles[i] = true;
        }
        
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
        
    }
    
	FREObject listPorts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("NativeSerial :: listPorts is handled from AS3 on Mac OSX !!\n");
        as3Print("listPorts is handled from AS3 on Mac OSX !!");
       
        /*
        //NSArray *availablePorts = portManager.availablePorts;
        int numPorts = 0;//availablePorts.count;
        
        printf("numPorts : %i\n",numPorts);
        as3Print("got length");
        
        FREObject result = NULL;
		FRENewObject((const uint8_t *)"Vector.<String>",0,NULL,&result,NULL);
		FRESetArrayLength(result,numPorts);
        
        for(int i=0;i<numPorts;i++)
		{
            //ORSSerialPort *port = [availablePorts objectAtIndex:i];
			
			const char* portName = "to implement";//(const char*)[port.name UTF8String];
            printf("    -> Port name :%s\n",portName);
            
			FREObject curPort = NULL;
            
			FRENewObjectFromUTF8(strlen(portName),(const uint8_t*)portName,&curPort);
			FRESetArrayElementAt(result,i,curPort);
			
		}
        */
        
		return NULL;
        
        
	}
    
	FREObject openPort(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		
        as3Print("openPort\n");
        
        
        int comPortError = 0;
        uint comLength;
        const unsigned char *localComPort;
        
        int baud=0;
        FREGetObjectAsUTF8(argv[0], &comLength, &localComPort);
        FREGetObjectAsInt32(argv[1], &baud);
        
        printf("NativeSerial Extension :: openPort %s\n",localComPort);
        
        int handleIndex = getFirstAvailableHandle();
        
        printf("Get first available handle : %i\n",handleIndex);
        
        memcpy(comPorts[handleIndex], localComPort, comLength);
        
        bufferSize = 0;
        
        comPortError = OpenComport((unsigned char *)localComPort,baud, handleIndex, false);
        
        as3Print("We are here !");
        
        bool openResult = false;
        
        if (comPortError == 0)
        {
            //usleep(100);
            //pthread_create(&ptrToThread, NULL, pollForData, NULL);
            openResult = true;
            availableHandles[handleIndex] = false;
            //as3Print("Open result OK");
        }else
        {
            //as3Print("Open result ERROR");
        }
        
        
        
		FREObject result;
		FRENewObjectFromBool(openResult,&result);
		return result;
        
	}
    
    
	FREObject isPortOpened(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		//printf("NativeSerial Extension :: is Port open ?\n");
		
        /*
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
        
		String^ portName = gcnew String((const char *)port);
        
		bool openResult = NativeSerial::isOpened(portName);
        */
        
        bool openResult = true;//temp
        
        
		FREObject result;
		FRENewObjectFromBool(openResult,&result);
		return result;
        
	}

	

	FREObject closePort(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		as3Print("NativeSerial Extension :: closePort \n");
        
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
        
        int handleIndex = getHandleForPort((unsigned char *)port);
        CloseComport(handleIndex);
        
        availableHandles[handleIndex] = true;
        
        /*
		String^ portName = gcnew String((const char *)port);
        
		NativeSerial::closePort(portName);
        */
        
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
        
	}
    
	FREObject update(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);
        
        
        unsigned char incomingBuffer[4096];
        int incomingBufferSize = 0;
        
        int handleIndex = getHandleForPort((unsigned char *)port);
        incomingBufferSize = PollComport(handleIndex,incomingBuffer,4095);
        
        FREObject result;
        FRENewObjectFromInt32(incomingBufferSize, &result);
        
        
        if(incomingBufferSize > 0)
        {
            FREByteArray bytes;
            
            FREAcquireByteArray(argv[1], &bytes);
        
            pthread_mutex_lock( &safety);
            memcpy(bytes.bytes,incomingBuffer,incomingBufferSize);
        
            pthread_mutex_unlock( &safety);
        
            
            FREReleaseByteArray(argv[1]);
        }
        
        bufferSize=0;
        
        return result;
        
	}
    
	FREObject writeBytes(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * port;
		uint32_t portLength = 0;
		FREGetObjectAsUTF8(argv[0], &portLength,&port);	
        
        FREObject result;
        FREByteArray dataToSend;
        int sendResult = 0;
        
        bool sResult = false;
        
        FREAcquireByteArray(argv[1], &dataToSend);
        
        int handleIndex = getHandleForPort((unsigned char *)port);
        sendResult = SendBuf(handleIndex, (unsigned char *)&dataToSend.bytes, dataToSend.length);
        
        FREReleaseByteArray(argv[1]);
        
        if (sendResult != -1)
        {
            sResult = true;
        }
        else
        {
            char err[256];
            sprintf(err,"writeBytes error, sendResult : %i",sendResult);
            as3Print(err);
        }
        
        
        FRENewObjectFromBool(sResult, &result);
        return result;
	}


void reg(FRENamedFunction *store, int slot, const char *name, FREFunction fn) {
    store[slot].name = (const uint8_t*)name;
    store[slot].functionData = NULL;
    store[slot].function = fn;
}


void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
{
    
    printf("** Native Serial Extension v0.4a by Ben Kuper **\n");
    
    *numFunctions = 7;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));
    *functions = func;
    reg(func,0,"init",init);
    reg(func,1,"listPorts",listPorts);
    reg(func,2,"openPort",openPort);
    reg(func,3,"isPortOpened",isPortOpened);
    reg(func,4,"closePort",closePort);
    reg(func,5,"update",update);
    reg(func,6,"write",writeBytes);
}





void ContextFinalizer(FREContext ctx)
{
    return;
}

void NativeSerialExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
{
    
    *ctxInitializer = &ContextInitializer;
    *ctxFinalizer = &ContextFinalizer;
    *extData = NULL;
    
}

void NativeSerialExtFinalizer(void* extData)
{
	FREContext nullCTX;
	nullCTX = 0;
    
	ContextFinalizer(nullCTX);
	return;
}
