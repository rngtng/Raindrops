/*
*/
#include "WProgram.h"
#include <Wire.h>

#include "Com.h"

Com::Com(bool _serial, int _baud_rate) {
  serial = _serial;
  baud_rate = _baud_rate;
}

void Com::begin() {
  if(serial) {
    Serial.begin(BAUD_RATE);
  }
  else {
    Wire.begin();
  }
}


int Com::receive(int data) {
  if(serial) {
    Serial.read();
  }
  else {
    return Wire.receive();
  }
}

int Com::send(int data) {
  if(serial) {
    Serial.write(data);
  }
  else {
    Wire.send(data);
  }
}

Com::available() {
  if(serial) {
    return Serial.available();
  }
  else {
    Wire.available();
  }
  
}

void Com::beginTransmission(byte channel) {
  if(!serial) {
    Wire.beginTransmission(channel);
  }
}

void Com::endTransmission() {
  if(!serial) {
    Wire.endTransmission();
  }
}