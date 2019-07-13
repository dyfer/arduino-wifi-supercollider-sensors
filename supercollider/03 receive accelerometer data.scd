NetAddr.langPort; //check language port, should be 57120 (matching sending port in Arduino)

OSCFunc.trace(true);//check all incoming messages
OSCFunc.trace(false);

//receive

(
~receiver = OSCdef(\hello, {|msg|
	// "received OSC".postln;
	// msg.postln;
	msg[1..].round(0.01).postln;
}, '/acc')
)

~receiver.free;

//see how fast we're going
(
~numMessages = 0;
~lastSecond = thisThread.seconds;

~receiver = OSCdef(\hello, {|msg|
	// "received OSC".postln;
	// msg.postln;
	~numMessages = ~numMessages + 1;
	if((thisThread.seconds - ~lastSecond) > 1, {
		"accelerometer data: ".post; msg[1..].round(0.01).postln; //post data
		"received ".post; ~numMessages.post; " messages per second".postln;
		//reset
		~numMessages = 0;
		~lastSecond = thisThread.seconds;
	})

}, '/acc')
)

~receiver.free;