
OSCFunc.trace(true);
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



//define synthdef, based on a \default synth
(
SynthDef(\bufPlayWhole, { arg buffer = 0, out=0, amp=0.1, startPos = 0/*0-1*/, rate = 1, pan = 0;
	var snd;
	snd = PlayBuf.ar(1, buffer, rate, startPos: startPos * BufFrames.kr(buffer), doneAction: 2);
	// snd = snd * Linen.kr(gate, 0.01, 0.7, relTime, 2); //envelope
	Out.ar(out, Pan2.ar(snd, pan, amp));
	// SendReply.kr(gate, '/trig', 0);
}).add;
)


//specify soundfile path by hand
~buffer = Buffer.readChannel(s, "path/to/soundfile", channels: 0);

//or
(
FileDialog({|path|
	"loading buffer from ".post; path.postln;
	~buffer.free; //free first, just in case
	~buffer = Buffer.readChannel(s, path, channels: 0);
}, {"cancelled".postln}, 1, 0, true)
)

~buffer.plot; //see if it's there

Synth(\bufPlayWhole, [\buffer, ~buffer]);

Synth(\bufPlayWhole, [\buffer, ~buffer, \rate, 1.5]);
Synth(\bufPlayWhole, [\buffer, ~buffer, \rate, 0.4]);

Synth(\bufPlayWhole, [\buffer, ~buffer, \rate, 1, \startPos, 0.5]);


//alternative we can control the duration instead of playing file to the end
//define synthdef, based on a \default synth
(
SynthDef(\bufPlayDur, { arg buffer = 0, out=0, amp=0.1, startPos = 0/*0-1*/, rate = 1, pan = 0, dur = 1, att = 0.1, rel = 0.5;
	var snd;
	snd = PlayBuf.ar(1, buffer, rate, startPos: startPos * BufFrames.kr(buffer), loop: 1, doneAction: 0);
	snd = snd * Env.linen(att, dur - att - rel, rel, curve: \sin).kr(2); //envelope
	Out.ar(out, Pan2.ar(snd, pan, amp));
	// SendReply.kr(gate, '/trig', 0);
}).add;
)

Synth(\bufPlayDur, [\buffer, ~buffer]);
Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 2]);
Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.2]);
Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.2, \att, 0.01, \rel, 0.1])
Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.3, \att, 0.01, \rel, 0.1, \startPos, 0.6]);
Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.3, \att, 0.01, \rel, 0.1, \startPos, rrand(0.0, 0.8)]);



//when done
~receiver.free;
~accBus.free;
