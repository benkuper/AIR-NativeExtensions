

#include "ExtendedMouse.h"
#include <stdlib.h>

FREContext freContext;


//util
void as3Print(const char * message)
{
   
    FREDispatchStatusEventAsync(freContext, (const uint8_t*)"print", (const uint8_t*)message);
}


FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{

    freContext = ctx;
    
    as3Print("Init");
    
   
    FREObject result;
    FRENewObjectFromBool(1,&result);
    return result;
    
}

FREObject showMouse(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    CGDisplayShowCursor (kCGDirectMainDisplay);
    return NULL;
}


FREObject hideMouse(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    CGDisplayHideCursor (kCGDirectMainDisplay);
    return NULL;
}

FREObject setCursorPos(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    int tx = 0;
    int ty = 0;
    FREGetObjectAsInt32(argv[0], &tx);
    FREGetObjectAsInt32(argv[1], &ty);

    //as3Print("Set cursor pos \n");//,tx,ty);

    CGPoint point;
    point.x = tx;
    point.y = ty;

    CGAssociateMouseAndMouseCursorPosition(true);
    
    //CGWarpMouseCursorPosition(point);
   // printf("Error : %i\n",error);
    CGDisplayMoveCursorToPoint(CGMainDisplayID(),point);

    CGAssociateMouseAndMouseCursorPosition(true);
    CGEventRef mouse = CGEventCreateMouseEvent (NULL, kCGEventMouseMoved, CGPointMake(tx, ty),0);
    CGEventPost(kCGHIDEventTap, mouse);
    CFRelease(mouse);
    
    
    CGEventRef event = CGEventCreate(NULL);
    CGPoint cursorGet = CGEventGetLocation(event);
    CFRelease(event);
    
    
    
    char msg[256];
    sprintf(msg,"After set, check pos %f %f\n",cursorGet.x, cursorGet.y);
    //as3Print(msg);
    
    FREObject result;
    FRENewObjectFromBool(1, &result);
    //FRENewObjectFromBool(true,&result);
    return result;
}




void reg(FRENamedFunction *store, int slot, const char *name, FREFunction fn) {
    store[slot].name = (const uint8_t*)name;
    store[slot].functionData = NULL;
    store[slot].function = fn;
}

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
{
    *numFunctions = 4;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));
    *functions = func;
    reg(func,0,"init",init);
    reg(func,1,"setCursorPos",setCursorPos);
    reg(func,2,"showMouse",showMouse);
    reg(func,3,"hideMouse",hideMouse);
}





void ContextFinalizer(FREContext ctx)
{
    return;
}

void MouseExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
{
    
    *ctxInitializer = &ContextInitializer;
    *ctxFinalizer = &ContextFinalizer;
    *extData = NULL;
    
}

void MouseExtFinalizer(void* extData)
{
	FREContext nullCTX;
	nullCTX = 0;
    
	ContextFinalizer(nullCTX);
	return;
}

