NetAddr("10.45.0.120", 8000).sendMsg("/led", 1);
NetAddr("10.45.0.120", 8000).sendMsg("/led", 0);

NetAddr.langPort; //check language port


(
~sending.stop;
~sending = fork{
	var value = true;
	loop{
		NetAddr("10.45.0.120", 8000).sendMsg("/led", value.asInteger);
		value = value.not;
		0.5.wait;
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