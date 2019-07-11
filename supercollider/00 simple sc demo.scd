// shift-enter executes single line
// cmd/ctrl-enter executes code block

// before we start: install sc3plugins
// 1. open extensions folder
thisProcess.platform.userExtensionDir; //this will give you the path
thisProcess.platform.userExtensionDir.openOS;

// (unzip sc3plugins)
// 2. copy sc3plugins to the Extensions folder


// now let's make some sound

// boot the server
s.quit
s.boot
s.meter

// create a simple synthesis definition
(
a = SynthDef(\simple, {arg out = 0, freq = 440, amp = 0.5, pan = 0, dur = 1;
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
Routine.run({
	10.do({|i|
		Synth(\simple, [\amp, -9.dbamp]);
		0.2.wait;
	});
})
)

(
Routine.run({
	10.do({|i|
		Synth(\simple, [\amp, -9.dbamp, \freq, rrand(440, 450)]);
		0.2.wait;
	});
})
)

(
Routine.run({
	10.do({|i|
		Synth(\simple, [\amp, -9.dbamp, \freq, rrand(440, 1450)]);
		0.2.wait;
	});
})
)

(
Routine.run({
	10.do({|i|
		Synth(\simple, [\amp, -9.dbamp, \freq, rrand(440, 1450)]);
		(0.1 + 0.1.rand).wait;
	});
})
)

(
Routine.run({
	100.do({|i|
		Synth(\simple, [\amp, -18.dbamp, \freq, rrand(440, 1450)]);
		(0.01 + 0.05.rand).wait;
	});
})
)

(
Routine.run({
	100.do({|i|
		Synth(\simple, [\amp, -18.dbamp, \freq, rrand(440, 1450), \pan, rrand(-1.0, 1.0)]);
		(0.01 + 0.05.rand).wait;
	});
})
)

(
Routine.run({
	100.do({|i|
		Synth(\simple, [\amp, -18.dbamp, \freq, rrand(40, 4450), \pan, rrand(-1.0, 1.0)]);
		(0.01 + 0.05.rand).wait;
	});
})
)

(
Routine.run({
	100.do({|i|
		Synth(\simple, [\amp, -18.dbamp, \freq, rrand(40 + (i * 20), 450 + (i*40)), \pan, rrand(-1.0, 1.0)]);
		(0.01 + 0.05.rand).wait;
	});
})
)


(
Routine.run({
	1000.do({|i|
		Synth(\simple, [\amp, -24.dbamp, \freq, rrand(40 + (i * 5), 450 + (i*10)), \pan, rrand(-1.0, 1.0)]);
		// a.note.freq_(rrand(40 + (i * 5), 450 + (i*10))).amp_(-24.dbamp).play;
		(0.01 + 0.02.rand).wait;
	});
})
)


