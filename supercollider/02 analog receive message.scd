NetAddr("10.45.0.120", 8000).sendMsg("/led", 1);
NetAddr("10.45.0.120", 8000).sendMsg("/led", 0);

NetAddr.langPort; //check language port

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