/* Com:
 * Abstraction of Serial / Wir commmunication
*/
 
#ifndef Com_h
#define Com_h

#define MODE_SERIAL true
#define MODE_WIRE false
#define BAUD_RATE 9600

#include "WProgram.h"


class Com
{

public:
  int baud_rate;
  bool serial;
  
  Com(bool _serial = MODE_SERIAL, int _baud_rate = BAUD_RATE);
  void begin();
  void send(int data);
  int receive();
  byte available();
  void beginTransmission(byte channel = 0);
  void endTransmission();
};

#endif