/*

  for mkr1000
  and  GY-521 (MPU 6050 accelerometer and gyroscope)

  connections:

  mkr1000 |   Gy-521
  VCC       VCC
  GND       GND
  11        SDA
  12        SCL

  by Marcin Pączkowski

  NOTE: this is sending data as fast as possible! this might not be always needed
*/
#include <SPI.h>
#include <WiFi101.h> //note the library for mkr1000
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>


// I2Cdev and MPU6050 must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "MPU6050.h"


char ssid[] = "bodysound";     //  your network SSID (name)
char pass[] = "interface";  // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status

// UDP setup
WiFiUDP UdpSend; //for sending
//WiFiUDP UdpReceive; //for receiving
//IPAddress myIP;

// destination IP and port
IPAddress destIP(10, 45, 0, 149);
const unsigned int destPort = 57120;

OSCErrorCode error;

//MPU6050 setup
MPU6050 accelgyro;
//MPU6050 accelgyro(0x69); // <-- use for AD0 high

//variables for acceleration and gyro values
int16_t ax, ay, az;
int16_t gx, gy, gz;


// uncomment "OUTPUT_READABLE_ACCELGYRO" if you want to see a tab-separated
// list of the accel X/Y/Z and then gyro X/Y/Z values in decimal. Easy to read,
// not so easy to parse, and slow(er) over UART.
#define OUTPUT_READABLE_ACCELGYRO

unsigned long maxWaitForSerial = 2000; //in ms

float valueScaler = 2048; //we divide raw accelerometer values to obtain values in G-force (force of gravity)


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

  delay(5000);

  // confirm we're starting
  Serial.println("Hello!");

  // check for the presence of the shield:
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue:
    while (true);
  }

  //initialize udp
  UdpSend.begin(destPort);

  // start wire library
  Wire.begin();

  Serial.println("Initializing sensor");
  //initialize mpu 6050
  accelgyro.initialize();
  Serial.println("Testing device connections...");
  Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
  accelgyro.setFullScaleAccelRange(MPU6050_ACCEL_FS_16); //sets the scale to full range (16G)
}

void loop() {
  // check if we're connected
  if (WiFi.status() != WL_CONNECTED) {
    // connect
    connectToWiFi();
  } else {
    // if connected, check the signal strength once every 10 seconds:
    //    delay(10000);
    //    printSignalStrength();
    // send accelerometer data
    sendAcc();
    delay(10);
  }
}

void sendAcc() {
  //get data
  accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  OSCMessage msgAcc("/acc");
//  msgAcc.add(ax);
//  msgAcc.add(ay);
//  msgAcc.add(az);
  //scaled:
  msgAcc.add(ax / valueScaler);
  msgAcc.add(ay / valueScaler);
  msgAcc.add(az / valueScaler);
  UdpSend.beginPacket(destIP, destPort);
  msgAcc.send(UdpSend);
  UdpSend.endPacket();
  msgAcc.empty();
  //    Serial.println(az);
}

void connectToWiFi() {
  // attempt to connect to Wifi network:
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // check for size of the password - empty string will give size 1
    if (sizeof(pass) > 1) {
      // Connect to WPA/WPA2 network:
      status = WiFi.begin(ssid, pass);
    } else {
      status = WiFi.begin(ssid);
    }


    // wait 10s before attempting to reconnect:
    if (status != WL_CONNECTED) {
      delay(10000);
    }
  }

  // you're connected now, so print out the data:
  Serial.println("You're connected to the network!");
  printWifiData();
  printCurrentNet();
  printSignalStrength();
  printOscData();
}

void printOscData() {
  Serial.print("Sending OSC data to ");
  Serial.print(destIP);
  Serial.print(":");
  Serial.println(destPort);
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
