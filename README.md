AIR-NativeExtensions
====================

Collections of Native Extensions for Adobe AIR

## Important informations

### Mac users
Those dlls are all compiled for Windows-x86 and MacOS-x86. As Adobe decided to only support MacOS x64 since Adobe AIR 20, you will have to use the AIR 19 SDK in order to use this extensions on MacOS (or rebuild them for x64). 

### Windows users
Most of these extensions will need some dll to run correctly. I included in the repo a zip files with all the dlls needed to run the different extensions.
Those dlls need to be place in 2 places :
* when working with an IDE, they need to be place aside the adl.exe file that is in the /bin folder of the AIR SDK directory. 
  * In Flash IDE and FlashBuilder, it should be somewhere in the installation folder (program files/adobe/.../runtime).
  * In FlashDevelop, this is in the %AppData%/../Local/FlashDevelop/Apps directory (just copy and paste this path), you will see one or more sdk folders.
  * In IntelliJ, well you put the SDK yourself so you should know :)

* when packaging an app, the dlls should be added to the root directory of the installer.
  * In Flash IDE, FlashBuilder and IntelliJ, there is a setting window where you can add files to be packaged in the .exe
  * In FlashDevelop, just paste the dlls in the /bin folder of your project and you're good to go.


## What's in there ?

### BaseExtension

This is a minimal setup with all files needed to start a new NativeExtension. It contains some scripts i've made to ease the compile and testing of ANE files.


### AIRBonjour

This is a mod from opentekhnia's as3Bonjour which allows both browsing for Bonjour / Zeroconf services and registering new services as well.

### NativeSerial

This is a C++/C# extension that let users communicate with Serial COM Ports, like Arduino.
The lib also features COM port listing and automatic COM connection / disconnection detection.


### NativeDMXController

This extension allows you to control the Enttec DMX Pro device and communicate in both ways with DMX hardware.


### NativeMIDI

This extension uses the c++ rtmidi library to access Windows MIDI API (and CoreMIDI/JACK on Mac on support for OSX is released) and enables receiving and sending MIDI data from real devices or virtual midi looper such as loopMIDI or loopBe1.

### VirtualMIDI
Based on Tobias Erichsen's teVirtualMIDI SDK, this extension allows creation of Virtual MIDI Devices (like MIDILoop) from AS3


### ExtendedMouse
This extensions extends mouse functionnalities from AS3. It allows to show/hide mouse globally (not just inside the stage window), and also change the position of the cursor from code.

### SpoutAIR

This extension lets you share a BitmapData with Spout ( see http://spout.zeal.co ) so you can use it in Processing, Resolume, Unity, etc.

See : https://www.youtube.com/watch?v=Q1IaP9nCLaY


This project is done on my spare time, if you feel like it you can donate whatever you want !
<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=bkuperberg%40hotmail%2ecom&lc=US&item_name=Ben%20Kuper&item_number=open_paypal_donate&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" /></a>
