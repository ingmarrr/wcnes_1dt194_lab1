#include "UserButton.h"
#include "printfZ1.h"


module T1C @safe()
{
    uses interface Leds;
    uses interface Boot;
    uses interface Notify<button_state_t> as Button;

    /* We use millisecond timer to check the shaking of client.*/
    uses interface Timer<TMilli> as TimerAccel;

    /*Accelerometer Interface*/
    uses interface Read<uint16_t> as Xaxis;
    uses interface Read<uint16_t> as Yaxis;
    uses interface Read<uint16_t> as Zaxis;
    uses interface SplitControl as AccelControl;
}


implementation
{
    uint16_t error = 100; //Set the error value
    uint16_t x, y, z;

    event void Boot.booted() 
    {
    	call TimerAccel.startPeriodic(1000); //Starts timer
		call Button.enable(); //Start to use the button
    }

    event void AccelControl.startDone(error_t err)
    {
        printfz1_init();
        x = 0;
        y = 0;
        z = 0;
        printfz1("-----Accelerometer Started-----\n");
    }

    event void AccelControl.stopDone(error_t err) 
    {
		printfz1("-----Accelerometer Stopped-----\n");
    }

    event void TimerAccel.fired()
    {
    	call Xaxis.read(); //Takes input from the x-axis of the accelerometer
    }

    event void Xaxis.readDone(error_t result, uint16_t data)
    {
        if (abs(x - data) > error) 
        {
        	call Leds.led0On(); //LED corresponding to the x-axis
        }
        else
        {
        	call Leds.led0Off(); //If difference is less than the error turn the LED off.
        }
        
        x = data; //Store current sensor input to compare with the next.  
        call Yaxis.read(); //Takes input from the y-axis of the accelerometer
    }

    event void Yaxis.readDone(error_t result, uint16_t data)
    {
        if (abs(y - data) > error) 
        {
        	call Leds.led1On(); //LED corresponding to the y-axis
        }
        else
        {
        	call Leds.led1Off(); //If difference is less than the error turn the LED off.
        }
        
        y = data; //Store current sensor input to compare with the next.  
        call Zaxis.read(); //Takes input from the z-axis of the accelerometer
    }

    event void Zaxis.readDone(error_t result, uint16_t data)
    {
    	printfz1("Batch: [X] = (%d) ", x); //print a batch of x,y,z-axis
		printfz1("[Y] = (%d) ", y);
		printfz1("[Z] = (%d)\n", data);
    
	    if (abs(z - data) > error) 
        {
        	call Leds.led2On(); //LED corresponding to the z-axis
        }
        else
        {
        	call Leds.led2Off(); //If difference is less than the error turn the LED off.
        }
        z = data;
    }

    event void Button.notify(button_state_t val) 
    {
		if (val == BUTTON_RELEASED) 
		{
			call AccelControl.start(); //Starts accelerometer
		} 
		else 
		{
			call AccelControl.stop(); //Stops accelerometer
		}
    }
}
