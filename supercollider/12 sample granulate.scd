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
~receiver = OSCdef(\hello, {|msg|
	// "received OSC".postln;
	// msg.postln;
	~accBus.setnSynchronous(msg[1..]);
}, '/acc')
)

~proxy[\acc] = {In.kr(~accBus.index, ~accBus.numChannels)};

~proxy[\acc].scope;



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


// set up

~proxy.ar(\playheadPosition, 1); //define audio-rate proxy

~proxy[\playheadPosition] = 0;


~proxy[\pan] = 0;

(
~proxy[\out] = {
	var snd;
	var buf = ~buffer;
	snd = BufRd.ar(1, buf, ~proxy[\playheadPosition] * BufFrames.kr(buf));
	Pan2.ar(snd, ~proxy[\pan]);
}
)
~proxy[\out].play;


~proxy[\playheadPosition] = {LFSaw.ar(0.1)};
~proxy[\playheadPosition] = {LFSaw.ar(0.1).poll};

~proxy[\playheadPosition] = {~proxy[\acc].ar(1, 0/*X axis*/).lag3(0.1).linlin(-1, 1, 0, 1)};

~proxy[\playheadPosition] = {Slew.ar(~proxy[\acc].ar(1, 0/*X axis*/).lag3(0.3).linlin(-1, 1, 0, 1), 1, 1)};
~proxy[\playheadPosition] = {Slew.ar(~proxy[\acc].ar(1, 0/*X axis*/).lag3(0.3).linlin(-1, 1, 0, 1), 2, 1)};


//better to filter out low frequencies
(
~proxy[\out] = {
	var snd;
	var buf = ~buffer;
	snd = BufRd.ar(1, buf, ~proxy[\playheadPosition] * BufFrames.kr(buf));
	snd = HPF.ar(snd, 30); //filter very low frequencies
	Pan2.ar(snd, ~proxy[\pan]);
}
)

