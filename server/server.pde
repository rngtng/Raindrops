/*
 * Raindrops - Server.pde
 * upload this on the Arduino connected to the Accelerometer
 */
 
#include <Wire.h>
#include <Accelerometer.h>

void accel_measure(int loops = 8, int measure_delay = 15);
boolean avg_accel_measure(int cylces = 6, int diff = 2);
Accelerometer accel = Accelerometer(3, 2, 1);
volatile boolean do_calibrate = false;

int borders[] = {90,46,43,26,20,1};
int pitch[]   = {3,0,3}; //pitch  real, correct, avg
int roll[]    = {20,0,20};

void button_pressed()
{
  do_calibrate = true;
}

void setup()
{
  Wire.begin();
  attachInterrupt(0, button_pressed, FALLING);
  accel.calibrate();
}

void calibrate()
{
  Wire.beginTransmission(0);
  Wire.send(254);
  Wire.endTransmission();

  while(!avg_accel_measure());
  for(int i = 0; i < 6; i++) borders[i] = 0;
  accel.calibrate();

  accel_measure();
  set_border(0);
  set_border(5);
  accel_measure();
 
  for(int state = 1; state < 5; state++)
  {
    Wire.beginTransmission(0);
    Wire.send(255 - state - 1);
    Wire.endTransmission();

    int test = get_border(state);
    int test2 = test;

    while( !(avg_accel_measure() && abs(test - test2) > 20) )
    {
      test2 = get_border(state);
    }
    delay(10);
    while(!avg_accel_measure());
    set_border(state);
  }
  do_calibrate = false;
}

void loop()
{
  accel_measure();

  pitch[1] = 40 + (pitch[0] * 40 ) / ((pitch[0] < 0) ? borders[1] : borders[2]);
  roll[1]  = 40 + (roll[0]  * 40 ) / ((roll[0]  < 0) ? borders[3] : borders[4]);
  if(pitch[1] < 0)   pitch[1] = 0;
  if(roll[1]  < 0)   roll[1]  = 0;
  if(pitch[1] > 80)  pitch[1] = 80;
  if(roll[1] >  80)  roll[1]  = 80;

  Wire.beginTransmission(0);
  Wire.send(255);
  Wire.send(pitch[1]);
  Wire.send(roll[1]);
  Wire.endTransmission();

  if(do_calibrate) calibrate();
}

void accel_measure(int loops, int measure_delay)
{
  while(--loops > 0)
  {
    delay(measure_delay);
    accel.loop();
  }
  pitch[0] = accel.pitch() - borders[0];
  roll[0]  = accel.roll()  - borders[5];
}

boolean avg_accel_measure(int cycles, int diff) {
  pitch[2] = pitch[0];
  roll[2]  = roll[0];

  for(int c = 1; c < cycles; c++) 
  {
    accel_measure(8, 1);
    pitch[2] += pitch[0];
    roll[2]  += roll[0];
  }

  pitch[2] /= cycles;
  roll[2]  /= cycles;
  return abs(pitch[2] - pitch[0]) < diff && abs(roll[2] - roll[0]) < diff;
}


void set_border(int border) 
{
  borders[border] = abs(get_border(border));
}

int get_border(int border) 
{
  return (border < 3) ? pitch[0] : roll[0];
}
