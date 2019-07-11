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

~proxy[\playheadPosition] = 0;


~proxy[\pan] = 0;
~proxy[\rate] = 1;

(
~proxy[\out] = {
	var snd;
	var buf = ~buffer;
	snd = Warp1.ar(1, ~buffer, ~proxy[\playheadPosition].kr(1), ~proxy[\rate].kr, 0.8, -1, 8, 0.01, 4);
	Pan2.ar(snd, ~proxy[\pan]);
}
)
~proxy[\out].play;



~proxy[\playheadPosition] = {LFSaw.ar(0.1)};
~proxy[\playheadPosition] = {LFSaw.ar(0.1).poll};

~proxy[\playheadPosition] = {~proxy[\acc].ar(1, 0/*X axis*/).lag3(0.1).linlin(-1, 1, 0, 1)};

