Developed and debugged using Keil uVision4. Run on LPC1768.

-----------------------------------------------------------------------------------------------------------
Lab-1: Flashing LED
-----------------------------------------------------------------------------------------------------------

Objective
The objective of this lab is to complete, assemble and download a simple assembly language
program. Here is a short list of what you will do in this session:
- Write some THUMB assembly language instructions
- Use different memory addressing modes
- Test and debug the code on the Keil board
- The on-board RAM is used instead of Flash memory
You will flash an LED (Light Emitting Diode) at an approximate 1 Hz frequency. 



-----------------------------------------------------------------------------------------------------------
Lab-2: Subroutines and parameter passing
-----------------------------------------------------------------------------------------------------------

Objective
In structured programming, big tasks are broken into small routines. A short program is written for
each routine. The main program calls these short subroutines.
In most cases when a subroutine is called, some information, parameters, must be communicated
between the main program and the subroutine. This is called parameter passing.
In this lab, you will use subroutines and parameter passing by implementing a Morse code system.

What you do
In this lab you will turn one LED into a Morse code transmitter. You will cause one LED to blink in
Morse code for a five character word. The LED must be turned on and off with specified time
delays until all characters are communicated. 

-----------------------------------------------------------------------------------------------------------
Lab-3: Input/Output interfacing
-----------------------------------------------------------------------------------------------------------

Objective
The objective of this lab is to learn how to use peripherals (LEDs, switch) connected to a
microprocessor. The ARM CPU is connected to the outside world using Ports and in this lab you
will setup, and use, Input and Output ports.
What you do
- A simple counter subroutine that increments from 0x00 to 0xFF, wraps to 0, and continues
counting. This will prove that the bits are displayed in the correct order on the LEDs.
- The reflex-meter.

-----------------------------------------------------------------------------------------------------------
Lab-4: Interrupt handling 
-----------------------------------------------------------------------------------------------------------

Objective
The objective of this lab is to learn about interrupts. You will enable an interrupt source in the
LPC1768 microprocessor, and write an interrupt service routine (ISR) that is triggered when the
INT0 button is pressed. The ISR returns to the main program after handling the interrupt. 

The random number generator output will be used to generate a number
which gives a time delay of 5.0 to 25.0 seconds with a resolution of 0.1s. Ie. An integer between
50 and 250.