// by Marcin Pączkowski

// for mkr1000

#include <WiFi101.h>

#include <WiFiUdp.h>
#include <OSCBundle.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>

WiFiUDP UdpSend;
WiFiUDP UdpReceive;

char ssid[] = "bodysound";     //  your network SSID (name)
char pass[] = "interface";  // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status

// destination IP and port
IPAddress destIP(10, 45, 0, 149); //also called "host IP" or "host" - put your COMPUTER's IP here
const unsigned int destPort = 57120;
const unsigned int receivePort = 8000;

int ledPin = 6;

void setup()
{
  Serial.begin(9600);      // initialize serial communication
  pinMode(ledPin, OUTPUT);      // set the LED pin mode

  // wait for serial port to connect
  // Needed for native USB port only
  // this means that the sketch won't start without USB connected and Serial Monitor started
  while (!Serial) {
    ;
  }

  // confirm we're starting
  Serial.println("Hello!");

  // check for the presence of the shield:
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    while (true);       // don't continue
  }

  // attempt to connect to WiFi network:
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to Network named: ");
    Serial.println(ssid);                   // print the network name (SSID);

    if (sizeof(pass) > 1) {
      // Connect to WPA/WPA2 network:
      status = WiFi.begin(ssid, pass);
    } else {
      status = WiFi.begin(ssid);
    }

    // wait 1 second for connection:
    delay(1000);
  }

  //initialize udp
  UdpSend.begin(destPort);
  UdpReceive.begin(receivePort);

  printWiFiStatus();
}

void loop()
{
  receiveOSC(); //receive in the main loop
}

void sendOSC() {
  //declare the bundle
  OSCBundle bndl;

  //BOSCBundle's add' returns the OSCMessage so the message's 'add' can be composed together
  bndl.add("/hello").add("World").add(1).add(23.4);
  //    bndl.add("/analog/0").add((int32_t)analogRead(0));
  //    bndl.add("/analog/1").add((int32_t)analogRead(1));
  //    bndl.add("/digital/5").add((digitalRead(5)==HIGH)?"HIGH":"LOW");

  UdpSend.beginPacket(destIP, destPort);
  bndl.send(UdpSend); // send the bytes to the SLIP stream
  UdpSend.endPacket(); // mark the end of the OSC Packet
  bndl.empty(); // empty the bundle to free room for a new one
}

void receiveOSC() {
  OSCBundle bndl;
  int size;

  if ( (size = UdpReceive.parsePacket()) > 0)
  {
    while (size--)
      bndl.fill(UdpReceive.read());

    if (!bndl.hasError()) {
      bndl.dispatch("/led", ledFunc);
      Serial.println("received OSC");
      //send hello back
      sendOSC();
    }

  }
}

void ledFunc(OSCMessage &msg) {
  if (msg.size() > 0) {
    int val = msg.getInt(0);
    Serial.println(val);
    if (val) {
      digitalWrite(ledPin, HIGH);
    } else {
      digitalWrite(ledPin, LOW);
    }
  }
}

void printWiFiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("My IP Address and listening port: ");
  Serial.print(ip);
  Serial.print(":");
  Serial.println(receivePort);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
