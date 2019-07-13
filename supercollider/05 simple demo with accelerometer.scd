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
SynthDef(\simple, {arg out = 0, freq = 440, amp = 0.5, pan = 0, dur = 1;
	var snd, env;
	snd = SinOsc.ar(freq, 0, amp);
	env = EnvGen.kr(Env.perc(releaseTime: dur), doneAction: 2);
	Out.ar(out, Pan2.ar(snd * env, pan));
}).add
)

// single sound
Synth(\simple);

// iteration


(
~sounds.stop;
~sounds = Routine.run({
	inf.do({|i|
		Synth(\simple, [\amp, -9.dbamp, \freq, ~accBus.getnSynchronous[0].linexp(-1, 1, 300, 3000), \pan, rrand(-1.0, 1.0)]); //X axis
		0.2.wait;
	});
})
)
~sounds.stop;


(
~sounds.stop;
~sounds = Routine.run({
	inf.do({|i|
		Synth(\simple, [\amp, -9.dbamp, \freq, ~accBus.getnSynchronous[0].linexp(-1, 1, 300, 3000), \pan, rrand(-1.0, 1.0)]); //X axis
		~accBus.getnSynchronous[1].linlin(-1, 1, 0.05, 0.5).wait;//Y axis
	});
})
)
~sounds.stop;


//when done
~receiver.free;
~accBus.free;