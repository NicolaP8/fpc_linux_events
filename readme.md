# fpc_linux_events
I converted some files from the Linux Kernel to use with Free Pascal to read input events in Linux.
This is the very first release, note that:
- tested on Raspberry PI with fpc 3.0.4 and Kernel 4.14.98;
- I used Delphi mode because I know it, not tested in fpc mode;
- there are some strange coditional define because I write in the Delphi IDE, do a compile to check syntax then copy to the Raspberry PI and compile with fpc :-) ;
- a lot of strings has to be added to test program

Tested with a rotary encoder, in config.txt:
dtoverlay=rotary-encoder,pin_a=17,pin_b=27,steps-per-period=2,relative_axis

Also tested with a button, in config.txt:
dtoverlay=gpio-key,gpio=23,active_low,gpio_pull=up,label=P3,keycode=4

Files:
- IOCtl.pas conversion from ioctl.h, added e function to build ioctl codes at runtime because Pascal have not the flexibility of C preprocessor.
- input.pas conversion from input.h.
- inputeventcodes.pas conversion from input-event-codes.h.
- InputUtils.pas some simple helper functions.
- event.dpr a conversion from evtest.c, a simple program to show present event handlers and to check it.
