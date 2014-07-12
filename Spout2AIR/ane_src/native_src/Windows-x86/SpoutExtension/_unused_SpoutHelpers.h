#include "spoutSDK.h"

Spout spout;

GLuint myTexture;
int texWidth;
int texHeight;

GLuint receiveTexID;
GLuint offscreen_framebuffer;
unsigned int rTexWidth;
unsigned int rTexHeight;

bool InitGL(HWND hWnd);

bool initSpout(HWND hWnd)
{
	//return spout.CheckInterop(NULL);
	//spout.init(NULL);
	return InitGL(hWnd);
}


bool updateTexture(GLvoid * pixels)
{
	glBindTexture(GL_TEXTURE_2D, myTexture);
	

	glTexImage2D(GL_TEXTURE_2D, 0,  GL_RGBA, texWidth, texHeight, 0,GL_BGRA_EXT, GL_UNSIGNED_BYTE,pixels);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); //  GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); //  GL_LINEAR);

	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);

	return spout.SendTexture(myTexture, GL_TEXTURE_2D, texWidth, texHeight, true);
}


/// GL
void EnableOpenGL(HWND hWnd, HDC * hDC, HGLRC * hRC)
{
    PIXELFORMATDESCRIPTOR pfd;
    int iFormat;

    // get the device context (DC)
    *hDC = GetDC( hWnd );

    // set the pixel format for the DC
    ZeroMemory( &pfd, sizeof( pfd ) );
    pfd.nSize = sizeof( pfd );
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL |
                  PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 24;
    pfd.cDepthBits = 16;
    pfd.iLayerType = PFD_MAIN_PLANE;
    iFormat = ChoosePixelFormat( *hDC, &pfd );
    SetPixelFormat( *hDC, iFormat, &pfd );

    // create and enable the render context (RC)
    *hRC = wglCreateContext( *hDC );
    wglMakeCurrent( *hDC, *hRC );
}

void DisableOpenGL(HWND hWnd, HDC hDC, HGLRC hRC)
{
    wglMakeCurrent( NULL, NULL );
    wglDeleteContext( hRC );
    ReleaseDC( hWnd, hDC );
}

void InitTexture(int width, int height)					// Initialize local texture for sharing
{

	texWidth = width;
	texHeight = height;
	// printf("WinSpoutSDK : InitTexture : bMemoryMode = %d\n", bMemoryMode);

	if(myTexture != NULL) {
		glDeleteTextures(1, &myTexture);
		myTexture = NULL;
	}

	// Create a local texture for transfers
	glGenTextures(1, &myTexture);
	glBindTexture(GL_TEXTURE_2D, myTexture);

	glTexImage2D(GL_TEXTURE_2D, 0,  GL_RGBA, width, height, 0,GL_BGRA_EXT, GL_UNSIGNED_BYTE,NULL);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); //  GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); //  GL_LINEAR);
}


bool InitGL(HWND hWnd)						// All Setup For OpenGL Goes Here
{

	printf("InitGL with EnabledOpenGL\n");

	HDC hDC;
	HGLRC glContext;
	EnableOpenGL(hWnd,&hDC,&glContext);


	// http://www.opengl.org/wiki/Swap_Interval
	// Lock drawing to vertical sync
	// Noted that although it was OK on the development machine, it failed on others
	// Noted 21-04-14 swapinterval has no effect fullscreen mode for a receiver
	// https://www.opengl.org/discussion_boards/showthread.php/180739-wglSwapIntervalEXT-problem
	// Noted that this was caused only if the window was topmost before it entered fullscreen
	// Also requires glfinish (see below)
	if(!spout.SetVerticalSync(true)) {
		// means that vertical sync is already set or oad of extensions failed
		// printf("Vsync set error\n");
	}

	// a swap interval of 1 causes SwapBuffers to wait until the
	// next vertical sync, avoiding possible tears in your images.
	// Note that this limits your framerate to 60 fps or so,
	// so don't forget to turn it OFF if you are doing render timing.

	// Determine hardware capabilities now, not later when all is initialized
	// =====================================================
	//glContext = wglGetCurrentContext(); // should check if opengl context creation succeed
	if(glContext) {
		//
		// ======= Hardware compatibility test =======
		//
		// Now we can call GetNVExt for an initial hardware compatibilty check
		// This initiailizes Glew and checks for the NV_DX_interop extensions
		// getNvExt will fail if the graphics deiver does not support them, or fbos
		// ======================================================
		if(wglGetProcAddress("wglDXOpenDeviceNV")) { // extensions loaded OK
			// It is possible that the extensions load OK, but that initialization will still fail
			// This occurs when wglDXOpenDeviceNV fails - noted on dual graphics machines with NVIDIA Optimus
			// Directx initialization seems OK with null hwnd, but in any case we will not use it.

			// SPOUTSDK
			printf("Compatible hardware\nNV_DX_interop extensions supported\n");

			if (spout.TextureShareCompatible()) { // Spout dll function
				printf("Interop load successful\nTexture sharing mode available\n");
				if(wglGetProcAddress("glBlitFramebufferEXT"))
					printf("FBO blit available\n");
				else
					printf("FBO blit not available\n");
			}
			else {
				printf("but wglDXOpenDeviceNV failed to load > Limited to memory share mode\n");
			}

			printf("We are here !\n");
		}
		else {
			
			// Determine whether fbo support is the reason or interop
			if(!wglGetProcAddress("glGenFramebuffersEXT"))
				printf("Hardware does not support EXT_framebuffer_object extensions\nTexture sharing not available\nLimited to memory share mode\n");
			else
				printf("Hardware does not support NV_DX_interop extensions\nTexture sharing not available\nLimited to memory share mode\n");


			return false;
		}
	}
	else {

		printf("No GL context, GetLastError : %X\n",GetLastError());

		return false;
	}


	printf("GL set some values\n");

	glShadeModel(GL_SMOOTH);							// Enable Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f);				// Black Background
	glClearDepth(1.0f);									// Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);							// Enables Depth Testing
	glDepthFunc(GL_LEQUAL);								// The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);	// Really Nice Perspective Calculations


	printf("And we are there !\n");

	//BuildFont();										// Build The Font

	// Set start time for FPS calculation
	// Initialize timing variables
	/*
	fps					= 60.0; //give a realistic starting value - win32 issues
	frameRate			= 60.0;
	lastFrameTime = diff = timeThen = timeNow = 0.0;
	startTime = (double)timeGetTime();
	*/
	//
	// Initialize a Spout sender or receiver
	// A render window must be available for Spout initialization
	//

	/*
	// A receiver will return the texture size of the sender
	if(bReceiver) {

		// sendername, width and height are returned by InitReceiver
		unsigned int theWidth = 0;
		unsigned int theHeight = 0;
		char sendername[256];
		strcpy_s(sendername, 256, "No sender"); // Sender name to connect to if required
		strcpy_s(g_SharedMemoryName, 256, sendername); // Set global name in advance in case it connects

		// SPOUTSDK

		printf("WinSpoutSDK : calling InitReceiver\n");
		bInitialized = spout.InitReceiver(sendername, theWidth, theHeight, bTextureShare, bMemoryMode);
		printf("InitReceiver [%s} returned : %dx%d bInitialized  = %d\n", sendername, theWidth, theHeight, bInitialized);
		
		// Remove the sender selection option for memorymode
		if(bMemoryMode) {
			hMenu = GetMenu(hWnd);
			HMENU hSubMenu;
			hSubMenu = GetSubMenu(hMenu, 0); // File
			RemoveMenu(hSubMenu,  IDM_SPOUTSENDERS, MF_BYCOMMAND);
			RemoveMenu(hSubMenu,  0, MF_BYPOSITION); // and the separator
		}

		//
		// InitReceiver
		//
		// name				- Character array containing the name of the sender to attempt connection to.
		// width			- Returns width of sender texture.
		// height			- Returns height of sender texture.
		// bTextureShare	- Returns texture share compatible (true) or not (false).
		// bMemoryShare		- Optional - set to true to force memoryshare mode.
		// Returns 
		// 	true for success (Sender name is returned different if the active sender has been used)
		// 	false for initialisation failure.

		// Check sender details if it connected
		if(bInitialized) {

			if(!strcmp(sendername, g_SharedMemoryName) == 0) { // connected to a different sender
				strcpy_s(g_SharedMemoryName, 256, sendername); // update local sender name
			}

			// double check width and height
			if(theWidth == 0 || theHeight == 0) {
				return FALSE;
			}

			// Any change to texture width and height ?
			if(theWidth != g_Width || theHeight != g_Height) {

				// Reset global width and height
				g_Width  = theWidth;
				g_Height = theHeight;

				// Reset render window
				GetWindowRect(hWnd, &windowRect);
				GetClientRect(hWnd, &clientRect);
				AddX = (windowRect.right - windowRect.left) - (clientRect.right - clientRect.left);
				AddY = (windowRect.bottom - windowRect.top) - (clientRect.bottom - clientRect.top);
				SetWindowPos(hWnd, HWND_TOP, windowRect.left, windowRect.top, g_Width+AddX, g_Height+AddY, SWP_SHOWWINDOW);
				// SetWindowPos(hWnd, HWND_TOP, 0, 0, g_Width+AddX, g_Height+AddY, SWP_SHOWWINDOW);
				// This causes a WM_SIZE message which then calls ReSizeGLScene and also resets texture size

				// Update the Spout local share texture
				InitTexture(g_Width, g_Height);

				// Return for the next round
				return TRUE;

			}

			// Update the Spout local share texture
			InitTexture(g_Width, g_Height);

		} // endif receiver initialized OK drop through
		else {
			MessageBoxA(NULL, "No sender running.\nStart one and try again..", "ERROR", MB_OK | MB_ICONEXCLAMATION);
			return FALSE;
		}

	} // endif receiver
	else {

		//
		// Sender
		//

		// First load the cube image for this demo
		if (!LoadCubeTexture()) {	// Jump To Texture Loading Routine
			return FALSE;			// If Texture Didn't Load Return FALSE
		}

		// Initialize a local texture for share transfers
		g_Width = width;
		g_Height = height;

		InitTexture(g_Width, g_Height);

		//
		// SPOUT InitSender
		//
		// name						- name of this sender
		// width, height			- width and height of this sender
		// bTextureShare			- Returns texture share compatible (true) or not (false).
		// bMemoryShare	Optional	- set to true to force memoryshare mode.
		// Returns true for success or false for initialisation failure.
		#ifdef is64bit
		strcpy_s(g_SharedMemoryName, 256, "Spout Demo Sender 64bit"); // Sender name
		#else
		strcpy_s(g_SharedMemoryName, 256, "Spout Demo Sender 32bit"); // Sender name;
		#endif

		// SPOUTSDK

		bInitialized = spout.InitSender(g_SharedMemoryName, g_Width, g_Height, bTextureShare, bMemoryMode);
		printf("InitSender [%s} returned : %dx%d bInitialized  = %d\n", g_SharedMemoryName, width, height, bInitialized);

	} // endif Sender
	*/


	return true;										// Initialization Went OK

}


//RECEIVING

void InitReceiveTexture(int width, int height)					// Initialize local texture for sharing
{

	rTexWidth = width;
	rTexHeight = height;
	// printf("WinSpoutSDK : InitTexture : bMemoryMode = %d\n", bMemoryMode);

	if(myTexture != NULL) {
		glDeleteTextures(1, &receiveTexID);
		receiveTexID = NULL;
	}

	//Generate a new FBO. It will contain your texture.
	glGenFramebuffersEXT(1, &offscreen_framebuffer);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, offscreen_framebuffer);

	//Create the texture 
	glGenTextures(1, &receiveTexID);
	glBindTexture(GL_TEXTURE_2D, receiveTexID);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  width, height, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, NULL);

	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

	//Bind the texture to your FBO
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, receiveTexID, 0);

	//Test if everything failed    
	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT) {
		printf("failed to make complete framebuffer object %x\n", status);
	}

}

int getNumSenders()
{
	spoutSenders senders;
	return senders.GetSenderCount();
}


bool  getTextureBytes(char * sharingName,uint32_t * pixels)
{
	bool receiveResult = spout.ReceiveTexture(sharingName,receiveTexID, GL_TEXTURE_2D,rTexWidth,rTexHeight);
	if(!receiveResult) 
	{
		printf("spout.ReceiveTexture failed.\n");
		return false;
	}
	//Bind the FBO
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, offscreen_framebuffer);
	// set the viewport as the FBO won't be the same dimension as the screen
	glViewport(0, 0, rTexWidth, rTexHeight);

	//GLubyte* pixels = (GLubyte*) malloc(rTexWidth * rTexHeight * sizeof(GLubyte) * 4);
	glReadPixels(0, 0, rTexWidth, rTexHeight,GL_BGRA_EXT, GL_UNSIGNED_BYTE, pixels);

	return true;

}