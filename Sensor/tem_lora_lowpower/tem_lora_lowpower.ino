

#include <MKRWAN.h>
#include <OneWire.h>
#include <ArduinoLowPower.h>

#define freqPlan TTN_FP_EU868

OneWire  ds(2);

float Temp_Buffer = 0;

LoRaModem modem;
const char *appEui = "0000000000000000";
const char *appKey = "16E5577D158C89C8AD877E823BA5F161";

void setup() {

  while (!modem.begin(EU868)) delay(1000);
  modem.joinOTAA(appEui, appKey);

}

void loop() {
  

  float celsius = readDs18b20();
  uint16_t temperature = round(100 * celsius);

  byte payload[2];
  payload[0] = highByte(temperature);
  payload[1] = lowByte(temperature);

  if (temperature > 0) {
    int err;
    modem.beginPacket();
    modem.write(payload, sizeof(payload));
    err = modem.endPacket(true);


  }
  
  LowPower.deepSleep(1799000);
  
}



float readDs18b20()
{
  byte i;
  byte present = 0;
  byte type_s;
  byte data[12];
  byte addr[8];
  float celsius, fahrenheit;

  if ( !ds.search(addr)) {

    ds.reset_search();
    delay(250);
    return 0;
  }


  for ( i = 0; i < 8; i++) {

  }

  if (OneWire::crc8(addr, 7) != addr[7]) {

    return 0;
  }


  ds.reset();
  ds.select(addr);
  ds.write(0x44, 1);        // start conversion, with parasite power on at the end

  delay(1000);     // maybe 750ms is enough, maybe not


  present = ds.reset();
  ds.select(addr);
  ds.write(0xBE);         // Read Scratchpad


  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();

  }


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

  return celsius;
}
