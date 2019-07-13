OSCFunc.trace(false);

// s by defalut referst to an instance of a Server object

(
s.waitForBoot({
	~proxy = ProxySpace(s);
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


// proxy setup - accelerometers

~proxy[\acc] = {In.kr(~accBus.index, ~accBus.numChannels)};

~proxy[\acc].scope;


// proxy setup - parameters
(
~proxy[\minFreq] = 100;
~proxy[\maxFreq] = 1000;
~proxy[\minAmp] = -90.dbamp;
~proxy[\maxAmp] = -3.dbamp;
~proxy[\pan] = 0;
)

// proxy setup - sound generation
(
~proxy[\out] = {
	var snd, env, freq, amp;
	//note a different selection of which control channel we're using
	freq = ~proxy[\acc].kr(1, 0).linexp(-1, 1, ~proxy[\minFreq].max(0.001), ~proxy[\maxFreq].max(0.001));
	freq = freq.lag3(0.1);
	amp = ~proxy[\acc].kr(1, 1).asArray[0].linexp(-1, 1, ~proxy[\minAmp].max(0.001), ~proxy[\maxAmp].max(0.001));
	amp = amp.lag3(0.1);
	snd = SinOsc.ar(freq, 0, amp);
	Pan2.ar(snd, ~proxy[\pan]);
}
)

//play!
~proxy[\out].play;

// we can change things on the fly

~proxy[\maxFreq] = 4000;

//try again
~proxy.fadeTime_(1); //changes crossfade time between parameters
~proxy[\maxFreq] = 2000;


//change linexp source range for amp

(
~proxy[\out] = {
	var snd, env, freq, amp;
	//note a different selection of which control channel we're using
	freq = ~proxy[\acc].kr(1, 0).linexp(-1, 1, ~proxy[\minFreq].max(0.001), ~proxy[\maxFreq].max(0.001));
	freq = freq.lag3(0.1);
	amp = ~proxy[\acc].kr(1, 1).asArray[0].linexp(-0.5, 0.5, ~proxy[\minAmp].max(0.001), ~proxy[\maxAmp].max(0.001));
	amp = amp.lag3(0.1);
	snd = SinOsc.ar(freq, 0, amp);
	Pan2.ar(snd, ~proxy[\pan]);
}
)

~proxy; //see what's there
~proxy.gui; //see what's there

//stop
~proxy.stop

//play
~proxy[\out].play;

//fade out (???)
~proxy.release(2);

//clear everything
~proxy.clear;


//when done
~receiver.free;
~accBus.free;

