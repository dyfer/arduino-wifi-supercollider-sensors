NetAddr.langPort; //check language port, should be 57120 (matching sending port in Arduino)

OSCFunc.trace(true);//check all incoming messages
OSCFunc.trace(false);

//receive

(
~receiver = OSCdef(\an0, {|msg|
	// "received OSC".postln;
	msg.postln;
}, '/analog/0')
)

~receiver.free;


(
~receiver1 = OSCdef(\an1, {|msg|
	// "received OSC".postln;
	msg.postln;
}, '/analog/1')
)

~receiver1.free;