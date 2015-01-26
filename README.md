AIR-NativeExtensions
====================

Collections of Native Extensions for Adobe AIR


### BaseExtension

This is a minimal setup with all files needed to start a new NativeExtension. It contains some scripts i've made to ease the compile and testing of ANE files.


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
