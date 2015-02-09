/* teVirtualMIDI C interface
 *
 * Copyright 2009-2014, Tobias Erichsen
 * All rights reserved, unauthorized usage & distribution is prohibited.
 *
 *
 * File: teVirtualMIDITest.c
 *
 * This file contains a sample using the TeVirtualMIDI-dll-interface, which
 * implements a simple loopback-MIDI-port.
 */

#include <stdio.h>
#include <conio.h>
#include "AIRVirtualMIDI.h"
#include "teVirtualMIDI.h"
#include <string>

#define MAX_SYSEX_BUFFER	65535


FREContext fre;
LPVM_MIDI_PORT port;

extern "C"
{
	char *binToStr( const unsigned char *data, DWORD length ) {
		static char dumpBuffer[ MAX_SYSEX_BUFFER * 3 ];
		DWORD index = 0;

		while ( length-- ) {
			sprintf( dumpBuffer+index, "%02x", *data );
			if ( length ) {
				strcat( dumpBuffer, ":" );
			}
			index+=3;
			data++;
		}
		return dumpBuffer;
	}

	void CALLBACK teVMCallback( LPVM_MIDI_PORT midiPort, LPBYTE midiDataBytes, DWORD length, DWORD_PTR dwCallbackInstance ) {
		if ( ( NULL == midiDataBytes ) || ( 0 == length ) ) {
			printf( "empty command - driver was probably shut down!\n" );
			return;
		}
		if ( !virtualMIDISendData( midiPort, midiDataBytes, length ) ) {
			printf( "error sending data: %d\n" + GetLastError() );
			return;
		}
		  printf( "command: %s\n", binToStr( midiDataBytes, length ) );
	}

	
	FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		fre = ctx;

		printf( "teVirtualMIDI C loopback sample\n" );
		printf( "using dll-version:    %ws\n", virtualMIDIGetVersion( NULL, NULL, NULL, NULL ));
		printf( "using driver-version: %ws\n", virtualMIDIGetDriverVersion( NULL, NULL, NULL, NULL ));

		virtualMIDILogging( TE_VM_LOGGING_MISC | TE_VM_LOGGING_RX | TE_VM_LOGGING_TX );

		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}

	FREObject createDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const uint8_t * name;
		uint32_t nameLen;
		FREGetObjectAsUTF8(argv[0],&nameLen,&name);

		printf("created namelen : %i\n",nameLen);
		wchar_t *wcs = new wchar_t[nameLen];
		memset(wcs,NULL,nameLen*sizeof(wchar_t));
		mbstowcs(wcs,(const char *)name,nameLen-1);
		bool createResult = true;
		port = virtualMIDICreatePortEx2(wcs, teVMCallback, 0, MAX_SYSEX_BUFFER, TE_VM_FLAGS_PARSE_RX );

		if ( !port ) {
			printf( "### ERROR : could not create port: %d\n", GetLastError() );
			createResult = false;;
		}else
		{
			printf( "Virtual port created : %s\n",wcs );
		}

		FREObject result;
		FRENewObjectFromBool(createResult,&result);
		return result;
	}


	FREObject closeDevice(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		virtualMIDIClosePort( port );
		printf( "Virtual port closed - press enter to terminate application\n" );
		
		FREObject result;
		FRENewObjectFromBool(true,&result);
		return result;
	}


	// Flash Native Extensions stuff
	void VirtualMIDIContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet,  const FRENamedFunction** functionsToSet) { 

		printf("** Native MIDI Extension v1.0 by Ben Kuper **\n");

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "init",     NULL, &init },
			{ (const uint8_t*) "createDevice",    NULL, &createDevice },
			{ (const uint8_t*) "closeDevice",   NULL, &closeDevice }
		};
    
		*numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction );
		*functionsToSet = extensionFunctions;
	}


	void VirtualMIDIContextFinalizer(FREContext ctx) 
	{
		virtualMIDIClosePort( port );
		return;
	}

	void VirtualMIDIExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) 
	{
		*ctxInitializer = &VirtualMIDIContextInitializer;
		*ctxFinalizer   = &VirtualMIDIContextFinalizer;
	}

	void VirtualMIDIExtFinalizer(void* extData) 
	{
		return;
	}
}

