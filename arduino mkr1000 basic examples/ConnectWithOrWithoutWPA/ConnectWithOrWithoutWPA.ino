/*
This is based on built-in example for connecting to a
secured network: ConnectWithWPA

modified for mkr1000

by Marcin Pączkowski
 */
#include <SPI.h>
#include <WiFi101.h> //note the library for mkr1000

char ssid[] = "bodysound";     //  your network SSID (name)
char pass[] = "interface";  // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status

unsigned long maxWaitForSerial = 2000; //in ms


void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);

  // wait for serial port to connect, up to maximum maxWaitForSerial
  // Needed for native USB port only
  while (!Serial) {
    if (millis() > maxWaitForSerial) {
      break;
    }
  }

  // confirm we're starting
  Serial.println("Hello!");

  // check for the presence of the shield:
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue:
    while (true);
  }
}

void loop() {
  // check if we're connected
  if(WiFi.status() != WL_CONNECTED) {
    // connect
    connectToWiFi();
  } else {
    // if connected, check the signal strength once every 10 seconds:
    delay(10000);
    printSignalStrength();
  }
}


void connectToWiFi() {
  // attempt to connect to Wifi network:
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    
    // Connect to open or WPA/WPA2 network:
    if(sizeof(pass)>1) {  
      // Connect to WPA/WPA2 network:
      status = WiFi.begin(ssid, pass);
    } else {
      // Connect to open network
      status = WiFi.begin(ssid);
    }

    // wait 10s before attempting to reconnect:
    if(status != WL_CONNECTED) {
      delay(10000);
    }
  }

  // you're connected now, so print out the data:
  Serial.println("You're connected to the network!");
  printWifiData();
  printCurrentNet();
  printSignalStrength();
}

void printWifiData() {
  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("My IP Address: ");
  Serial.println(ip);

  // print your MAC address:
  byte mac[6];
  WiFi.macAddress(mac);
  Serial.print("My MAC address: ");
  Serial.print(mac[5], HEX);
  Serial.print(":");
  Serial.print(mac[4], HEX);
  Serial.print(":");
  Serial.print(mac[3], HEX);
  Serial.print(":");
  Serial.print(mac[2], HEX);
  Serial.print(":");
  Serial.print(mac[1], HEX);
  Serial.print(":");
  Serial.println(mac[0], HEX);

}

void printCurrentNet() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print the MAC address of the router you're attached to:
  byte bssid[6];
  WiFi.BSSID(bssid);
  Serial.print("Router MAC address: ");
  Serial.print(bssid[5], HEX);
  Serial.print(":");
  Serial.print(bssid[4], HEX);
  Serial.print(":");
  Serial.print(bssid[3], HEX);
  Serial.print(":");
  Serial.print(bssid[2], HEX);
  Serial.print(":");
  Serial.print(bssid[1], HEX);
  Serial.print(":");
  Serial.println(bssid[0], HEX);

  // print the encryption type:
  byte encryption = WiFi.encryptionType();
  Serial.print("Encryption Type:");
  Serial.println(encryption, HEX);
}

void printSignalStrength() {
    // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.println(rssi);
}
