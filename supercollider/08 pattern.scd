
OSCFunc.trace(true);
OSCFunc.trace(false);

// s by defalut referst to an instance of a Server object

(
s.waitForBoot({
	~accBus = Bus.control(s, 3);
	~proxy = ProxySpace(s);
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


//define synthdef, based on a \default synth
(
SynthDef(\saw1, { arg out=0, freq=440, amp=0.1, pan = 0, gate=1, relTime = 0.5;
	var z;
	z = Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.3, 0.3));
	x = x * Linen.kr(gate, 0.01, 0.7, relTime, 2); //envelope
	OffsetOut.ar(out, Pan2.ar(z, pan, amp));
	// SendReply.kr(gate, '/trig', 0);
}).add;
)


(
~pattern.stop;
~pattern = Pbind(
	\instrument, \saw1,
	\freq, Prand([300, 500, 231.2, 399.2], inf),
	\dur, 1,
	\tempo, 10,
).play;
)

~pattern.stop;


(
~pattern.stop;
~pattern = Pbind(
	\instrument, \saw1,
	\degree, Pseq([ 0, 1, 2, 4, 7, 8, 9, 11 ], inf),
	\scale, Scale.minor,
	\ctranspose, Pseq([Pn(0, 32), Pn(-5, 32) ], inf),
	\dur, 1,
	\tempo, 10,
).play;
)

~pattern.stop;

//---------------
// combine with proxy

~proxy.fadeTime_(1);

~proxy[\acc] = {In.kr(~accBus.index, ~accBus.numChannels)};

~proxy[\acc].scope

(
~proxy[\src] = Pbind(
	\instrument, \saw1,
	\degree, Pseq([ 0, 1, 2, 4, 7, 8, 9, 11 ], inf),
	\scale, Scale.minor,
	\ctranspose, Pseq([Pn(0, 32), Pn(-5, 32) ], inf),
	\dur, 1,
	\tempo, 10,
)
)

(
~proxy[\filterFreq] = 500;
~proxy[\filterRes] = 0.5; //values<1
)

~proxy[\out] = {MoogVCF.ar(~proxy[\src], ~proxy[\filterFreq], ~proxy[\filterRes].min(0.89))}; //protect against too high resonance


~proxy[\out].play;
~proxy[\out].stop


~proxy[\filterFreq] = 2000;
~proxy[\filterFreq] = 10000;

~proxy[\filterRes] = 0.1;
~proxy[\filterRes] = 0.8;

// connect to accelerometer!

~proxy[\filterFreq] = {~proxy[\acc].kr(1, 1/*Y axis*/).linexp(-0.5, 0.5, 400, 10000)};

// smooth out
~proxy[\filterFreq] = {~proxy[\acc].kr(1, 1/*Y axis*/).lag3(0.1).linexp(-0.5, 0.5, 400, 10000)};


~proxy.clear(2);



//when done
~receiver.free;
~accBus.free;
