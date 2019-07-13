NetAddr("10.45.0.120", 8000).sendMsg("/led", 1); //replace IP address with the one of the Arduino WiFi (in Serial Monitor)
NetAddr("10.45.0.120", 8000).sendMsg("/led", 0); //replace IP address with the one of the Arduino WiFi (in Serial Monitor)

NetAddr.langPort; //check language port, should be 57120 (matching sending port in Arduino)


(
~sending.stop;
~sending = fork{
	var value = true;
	loop{
		10.do({
			NetAddr("10.45.0.120", 8000).sendMsg("/led", value.asInteger); //replace IP address with the one of the Arduino WiFi (in Serial Monitor)
			"sending".postln;
			0.1.wait;
		});
		value = value.not;
	}
}
)

~sending.stop;


//receive

(
~receiver = OSCdef(\hello, {|msg|
	"received OSC".postln;
	msg.postln;
}, '/hello')
)

~receiver.free;