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


// you can get the data from the bus
~accBus.getnSynchronous;
~accBus.getnSynchronous[0]; //just the X axis

// create a simple synthesis definition
(
a = SynthDef(\sineBusFreqControl, {arg out = 0, freqBus = 0, freqMin = 440, freqMax = 1000, amp = 0.5, pan = 0, gate = 1;
	var snd, env, freq;
	freq = In.kr(freqBus, 1);
	freq = freq.linexp(-1, 1, freqMin.max(0.001), freqMax.max(0.001)); //note that exponential part may not cross 0, so we make sure that freqMin and freqMax are larger than 0
	snd = SinOsc.ar(freq, 0, amp);
	env = EnvGen.kr(Env.adsr, gate, doneAction: 2); //different envelope
	Out.ar(out, Pan2.ar(snd * env, pan));
}).add
)

// single sound
~sound.release; ~sound = Synth(\sineBusFreqControl, [\freqBus, ~accBus.index + 0/*X axis*/, \freqMin, 100, \freqMax, 1000, \amp, -9.dbamp]);

~sound.release; //gently release

//larger range
~sound.release; ~sound = Synth(\sineBusFreqControl, [\freqBus, ~accBus.index + 0/*X axis*/, \freqMin, 100, \freqMax, 2000, \amp, -9.dbamp]);


// smooth out frequency
// redefine synthdef, the run line above
(
a = SynthDef(\sineBusFreqControl, {arg out = 0, freqBus = 0, freqMin = 440, freqMax = 1000, amp = 0.5, pan = 0, gate = 1;
	var snd, env, freq;
	freq = In.kr(freqBus, 1);
	freq = freq.linexp(-1, 1, freqMin.max(0.001), freqMax.max(0.001));
	freq = freq.lag3(0.1);
	snd = SinOsc.ar(freq, 0, amp);
	env = EnvGen.kr(Env.adsr, gate, doneAction: 2); //different envelope
	Out.ar(out, Pan2.ar(snd * env, pan));
}).add
)

//-------

//add amplitude control
(
a = SynthDef(\sineBusFreqControl, {arg out = 0, freqBus = 0, freqMin = 440, freqMax = 1000, ampBus = 0, ampMin = 0.1, ampMax = 0.5, pan = 0, dur = 1, gate = 1;
	var snd, env, freq, amp;
	freq = In.kr(freqBus, 1).linexp(-1, 1, freqMin.max(0.001), freqMax.max(0.001));
	freq = freq.lag3(0.1);
	amp = In.kr(ampBus, 1).linexp(-1, 1, ampMin.max(0.001), ampMax.max(0.001));
	amp = amp.lag3(0.1);
	snd = SinOsc.ar(freq, 0, amp);
	env = EnvGen.kr(Env.adsr, gate, doneAction: 2); //different envelope
	Out.ar(out, Pan2.ar(snd * env, pan));
}).add
)


//larger range
~sound.release; ~sound = Synth(\sineBusFreqControl, [\freqBus, ~accBus.index + 0/*X axis*/, \freqMin, 100, \freqMax, 2000, \amp, -9.dbamp, \ampBus, ~accBus.index + 1/*Y axis*/, \ampMin, -90.dbamp, \ampMax, -3.dbamp]);

~sound.release; //gently release

//------
//when done
~receiver.free;
~accBus.free;
