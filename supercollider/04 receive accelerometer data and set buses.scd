NetAddr.langPort; //check language port

OSCFunc.trace(true);//check all incoming messages
OSCFunc.trace(false);

// s by defalut referst to an instance of a Server object

(
s.waitForBoot({
	~accBus = Bus.control(s, 3);
})
)

~accBus.scope;

//receive and set bus

(
~receiver = OSCdef(\hello, {|msg|
	// "received OSC".postln;
	// msg.postln;
	~accBus.setnSynchronous(msg[1..]);
}, '/acc')
)

~receiver.free;