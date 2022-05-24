#include <TheThingsNetwork.h>

#include <Arduino.h>

#include <OneWire.h>
 
OneWire  ds(2);  

float Temp_Buffer = 0;


const char *appEui = "0000000000000000";
const char *appKey = "2F694E13BD3E110E9BB470A6B3CDB104";

#define debugSerial Serial
#define loraSerial Serial1


#define freqPlan TTN_FP_EU868


#define DHTTYPE DHT22



//Calls the constructor for the TheThingsNetwork class from the TheThingsNetwork library
TheThingsNetwork ttn(loraSerial, debugSerial, freqPlan);

void setup(){

Serial.begin(9600);  
  debugSerial.begin(9600);
  loraSerial.begin(57600);

  // Wait a maximum of 10s for Serial Monitor
  while (!debugSerial && millis() < 10000)
    ;



  ttn.showStatus();
  debugSerial.println("-- JOIN");
  ttn.join(appEui, appKey);

}


void loop()
{
  
  Temp_Buffer = readDs18b20();
 
}
  debugSerial.println("-- LOOP");

float readDs18b20()
{
    byte i;
  byte present = 0;
  byte type_s;
  byte data[12];
  byte addr[8];
  float celsius, fahrenheit;
   
  if ( !ds.search(addr)) {
    // Serial.println("No more addresses.");
    // Serial.println();
    ds.reset_search();
    delay(250);
    // return 0;
  }
  
   // Serial.print("ROM =");
  for( i = 0; i < 8; i++) {
    Serial.write(' ');
    Serial.print(addr[i], HEX);
  }
 
  if (OneWire::crc8(addr, 7) != addr[7]) {
      Serial.println("CRC is not valid!");
      return 0;
  }
  Serial.println();
  
  // the first ROM byte indicates which chip
  switch (addr[0]) {
    case 0x10:
     // Serial.println("  Chip = DS18S20");  // or old DS1820
      type_s = 1;
      break;
    case 0x28:
     // Serial.println("  Chip = DS18B20");
      type_s = 0;
      break;
    case 0x22:
      Serial.println("  Chip = DS1822");
      type_s = 0;
      break;
    default:
      Serial.println("Device is not a DS18x20 family device.");
      return 0;
  } 
 
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
   
  delay(1000);     // maybe 750ms is enough, maybe not
  // we might do a ds.depower() here, but the reset will take care of it.
   
  present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE);         // Read Scratchpad
 
  Serial.print("  Data = ");
  Serial.print(present,HEX);
  Serial.print(" ");
  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();
    Serial.print(data[i], HEX);
    Serial.print(" ");
  }
  Serial.print(" CRC=");
  Serial.print(OneWire::crc8(data, 8), HEX);
  Serial.println();
 
  // convert the data to actual temperature
 
  unsigned int raw = (data[1] << 8) | data[0];
  if (type_s) {
    raw = raw << 3; // 9 bit resolution default
    if (data[7] == 0x10) {
      // count remain gives full 12 bit resolution
      raw = (raw & 0xFFF0) + 12 - data[6];
    }
  } else {
    byte cfg = (data[4] & 0x60);
    if (cfg == 0x00) raw = raw << 3;  // 9 bit resolution, 93.75 ms
    else if (cfg == 0x20) raw = raw << 2; // 10 bit res, 187.5 ms
    else if (cfg == 0x40) raw = raw << 1; // 11 bit res, 375 ms
    // default is 12 bit resolution, 750 ms conversion time
  }
  celsius = (float)raw / 16.0;
  fahrenheit = celsius * 1.8 + 32.0;
  Serial.print("  Temperature = ");
  Serial.print(celsius);
  Serial.print(" Celsius, ");   
  Serial.print(fahrenheit);
  Serial.println(" Fahrenheit");
  
  
  Serial.println(celsius,1);
  return celsius;
}

  // Split both words (16 bits) into 2 bytes of 8
  byte payload[6];
  payload[0] = highByte(temperature);
  payload[1] = lowByte(temperature);
 

  debugSerial.print("Temperature: ");
  debugSerial.println(temperature);
  
  ttn.sendBytes(payload, sizeof(payload));

  delay(30000);
}
