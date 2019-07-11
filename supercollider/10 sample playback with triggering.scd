//------------------
//---triggering--

OSCFunc.trace(true);
OSCFunc.trace(false);

// s by defalut referst to an instance of a Server object

(
s.waitForBoot({
	~accBus = Bus.control(s, 3);
	~proxy = ProxySpace(s);
})
)


(
~trigThreshold = 3.5; //in G-force
~previousVal = 0;
~valDifference = 0.1; //since the data has some noise, we're looking for difference larger than this
~triggered = false;
~trigAxis = 2; //0->X, 1->Y, 2->Z
~receiver = OSCdef(\hello, {|msg|
	var trigVal;
	// "received OSC".postln;
	// msg.postln;
	~accBus.setnSynchronous(msg[1..]); //our regular bus setting

	//triggering
	trigVal = msg[1+ ~trigAxis]; //offset indices by one
	if(trigVal > ~trigThreshold, {
		// we want to trigger after we change direction, so we check whether current value is SMALLER than the previous
		// e.g. 		if(trigVal < ~previousVal
		// but since there's some nosie in the data, we want to make sure we are smaller by certain amount
		if(((~previousVal - trigVal) > ~valDifference) && ~triggered.not, {
			"triggering".postln;
			//-----run some code here-----

			//housekeeping
			~triggered = true;
		})
	}, {
		//when we're below trigger, reset state
		~triggered = false
	});
	~previousVal = trigVal; //so we can compare next time

}, '/acc')
)


//back to sample playback

//choose sample

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


~accBus.scope;


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

Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.3, \att, 0.01, \rel, 0.1, \startPos, rrand(0.0, 0.8)]);


//trigger that!

(
~trigThreshold = 3.5; //in G-force
~previousVal = 0;
~valDifference = 0.1; //since the data has some noise, we're looking for difference larger than this
~triggered = false;
~trigAxis = 2; //0->X, 1->Y, 2->Z
~receiver = OSCdef(\hello, {|msg|
	var trigVal;
	// "received OSC".postln;
	// msg.postln;
	~accBus.setnSynchronous(msg[1..]); //our regular bus setting

	//triggering
	trigVal = msg[1+ ~trigAxis]; //offset indices by one
	if(trigVal > ~trigThreshold, {
		// we want to trigger after we change direction, so we check whether current value is SMALLER than the previous
		// e.g. 		if(trigVal < ~previousVal
		// but since there's some nosie in the data, we want to make sure we are smaller by certain amount
		if(((~previousVal - trigVal) > ~valDifference) && ~triggered.not, {
			"triggering".postln;
			//-----run some code here-----
			Synth(\bufPlayDur, [\buffer, ~buffer, \dur, 0.3, \att, 0.01, \rel, 0.1, \startPos, rrand(0.0, 0.8)]);
			//housekeeping
			~triggered = true;
		})
	}, {
		//when we're below trigger, reset state
		~triggered = false
	});
	~previousVal = trigVal; //so we can compare next time

}, '/acc')
)


