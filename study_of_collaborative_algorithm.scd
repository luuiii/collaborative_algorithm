//////////collaboratic_algorithm///////////

//////////Jia__&__Song__&__Shuoxin/////////

// Last updated time
// 20210214

//date1123: responding state chart for every one

//to-do: maybe play a bit with sound


(
n = NetAddr("127.0.0.1", 57140);
// The performer's ID
// Jia - 0
// Song - 1
// Shuoxin - 2
~id = 3;
~userNameList = [
	"jia",
	"song",
	"shuoxin",
	"edward",
];
~userList = [0, 1, 2];

~histo = ();
~chat = [];
~histogram = {|name| (~histo[name]?[])[..0].collect({|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
})[0]};

~respondChecker = {|n| n==~id};

// Build up chain settings

~partialThreshold = 11;
~partialCount = 0;
~partialStepMultiplier = 1;
~partialAmpMultiplier = 1;

~genPartialConfig = {
	~partialVolumes = Array.rand(~partialThreshold, 0.01, 0.04) * ~partialAmpMultiplier;
	~partialList = [500] + Array.series(
		~partialThreshold, 50, rrand(40, 55) * ~partialStepMultiplier
	);
};

// Init the volumes and list for partial
~genPartialConfig.value();

~sineGroup = Group.new(addAction: \addToTail);

~addPartial = {
	var freq = ~partialList[~partialCount];
	var amp = ~partialVolumes[~partialCount];
	("Adding one partial number:" ++ ~partialCount ++ " with freq: " ++ freq).postln;

	Synth(\sine,
		[\freq, freq, \amp, amp],
		~sineGroup,
		\addToTail
	);
	~partialCount = ~partialCount + 1;
};

~checkPartial = {
	if ( ~partialCount >= ~partialThreshold, {
		~sineGroup.set(\gate, 0);
		~partialCount = 0;
	});
};

~updatePartialStepMultiplier = { |val|
	if(val.isNumber && val > 0, {
		("***Update partial step multiplier to :" ++ val).postln;
		~partialStepMultiplier = val;
		~genPartialConfig.value();
	}, {
		("***!!Invalid partial step multiplier :" ++ val).postln;
	});
};

~updatePartialAmpMultiplier = { |val|
	if(val.isNumber && val > 0, {
		("***Update partial amp multiplier to :" ++ val).postln;
		~partialAmpMultiplier = val;
		~genPartialConfig.value();
	}, {
		("***!!Invalid partial amp multiplier :" ++ val).postln;
	});
};

~updatePartialThreshold = { |val|
	if(val.isNumber && val > 1, {
		("***Update partial thresold to to :" ++ val).postln;
		~partialThreshold = val;
		~genPartialConfig.value();
	}, {
		("***!!Invalid partial thresold :" ++ val).postln;
	});
};


OSCdef(\build_up_kill, {|msg|
	~sineGroup.set(\gate, 0);
	~partialCount = 0;
}, \build_up_kill);

OSCdef(\build_up_partial_threshold, {|msg|
	~updatePartialThreshold.(msg[1]);
}, \build_up_partial_threshold);

OSCdef(\build_up_partial_amp_multiplier, {|msg|
	~updatePartialAmpMultiplier.(msg[1]);
}, \build_up_partial_amp_multiplier);

OSCdef(\build_up_partial_step_multiplier, {|msg|
	~updatePartialStepMultiplier.(msg[1]);
}, \build_up_partial_step_multiplier);

SynthDef(\sine, {|freq=440, amp=0.1, pan = 0, attack = 1, gate = 1|
	var sig = SinOsc.ar(freq + LFNoise2.kr(1, 0));
	var env = EnvGen.kr(
		Env([0, 1, 0], [attack, Rand(5, 10)], releaseNode: 1),
		doneAction: 2,
		gate: gate,
	);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;
	Out.ar(0,sig)
}).add;


SynthDef(\braid, {|freq=440, amp=0.1, pan = 0, attack = 1, gate = 1, freqBus = 0, release=10|
	var detectedFreq, hasFreq;
	var lagFreq = freq.lag(10);
	var sig = SinOsc.ar(lagFreq);
	var env = EnvGen.kr(
		Env([0, 1, 0], [attack, release], releaseNode: 1),
		doneAction: 2,
		gate: gate,
	);

	#detectedFreq, hasFreq = Pitch.kr(sig);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;

	Out.ar(0, sig);
	Out.kr(freqBus, [detectedFreq]);
}).add;

SynthDef(\gai_id,{|freq=440, amp=0.1, pan = 0, dur = 1|
	var sig = SinOsc.ar(freq);
	var env = EnvGen.kr(
		Env([0, 1, 0], [0.005, 0.5]),
		doneAction: 2,
		timeScale: dur
	);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;
	Out.ar(0,sig)
}).add;

SynthDef(\noise, {|out=0, amp=0.1, freq=1500, rq=1, dur=5, pan=0|
	var in = GrayNoise.ar(1);
	var sig = BPF.ar(in, freq, rq);
	var env = EnvGen.kr(
		Env([0, 1, 1, 0], [0.001, 1, 0.001]),
		timeScale: dur,
		doneAction: 2,
	);
	sig = Pan2.ar(
		sig*env,
		pan,
		amp
	);
	Out.ar(out, sig);
}).add;

~play_message = {|queueName, from, to, waitTime|
	var panMap = [-1, 0, 1];
	switch(queueName,
		\buildUp, {
			~checkPartial.value();
			~addPartial.value();
		},
		\noise, {
			var freqs = [300, 700, 2300];

			Synth(\noise, [
				\amp, 0.2,
				\freq, freqs[to],
				\rq, 0.5,
				\pan, panMap[from],
				\dur, waitTime.value() * 0.4,
			]);
		}, {
			var freqs = [400, 600, 900];
			// var pans = [-1, 0, 1];

			Synth(\gai_id, [
				\freq, freqs[to] * waitTime.value().linexp(0, 19, 8, 0.00000001),
				\pan, panMap[from],
				\dur: waitTime.value() * 0.5,
			]);
		}
	);
};

// Braid configs
~freqList = [419, 419, 419];
~maxDiff = 100;
~braidBus = Bus.new(\control, 0, ~userList.size);

~applyFreqChange = {|index, change|
	var wish_freqs = ~freqList.collect({|item,i| if(i==index,{item + change},{item})});
	var freq_diff = wish_freqs.maxItem - wish_freqs.minItem;

	if(freq_diff > ~maxDiff,{
		if(change>0,{
			~freqList[index] = wish_freqs.minItem + ~maxDiff
		},{~freqList[index] = wish_freqs.maxItem - ~maxDiff})
	},{~freqList[index] = ~freqList[index]+change});
	~freqList.postln;
	("***Braid freqs is: " ++ ~freqList ++ " Max diff: " ++ ~maxDiff).postln

};
~braidisInitialized = false;
~braidSynth = [];

~killBraid = {
	if(~braidisInitialized == true, {
		"***Kill braid now!!".postln;
		~braidSynth.collect{|synth|
			synth.release;
		};
		~braidisInitialized = false;
	});
};

~updateBraidMaxDiff = { |val|
	if(val.isNumber, {
		("***Update braid max diff to :" ++ val).postln;
		~maxDiff = val;
	}, {
		("***!!Invalid braid max diff  :" ++ val).postln;
	});
};


OSCdef(\apply_freq,{|msg|
	if(~braidisInitialized == false,{
		"braidSynth Initialized ".postln;
		~braidisInitialized = true;
		~braidSynth = ~freqList.collect({|item, index|
			Synth(\braid, [
				\freq, item,
				\pan, [-1,0,1][index],
				\freqBus, ~braidBus.index + index,
			]);
		});
	},{
		~applyFreqChange.value(msg[1],msg[2]);
		~braidSynth[msg[1]].set(\freq, ~freqList[msg[1]])
	})
}, \braid);

OSCdef(\braid_update_maxdiff, {|msg|
	~updateBraidMaxDiff.(msg[1])
}, \braid_update_maxdiff);

OSCdef(\braid_kill, {|msg|
	~killBraid.();
}, \braid_kill);


// Chat OSCDef
OSCdef(\chat, {|msg|
	var format = ~userNameList[msg[1]]++": "++(msg[2]).asString;
	format.postln;
	~chat = ~chat ++ [format];
},\chat);

// ************
// Configs Sync
// ************

// global var that holds all performer's config value as string(For visual display)
// userId -> { chainName -> { waitTime -> ...., nextTarget -> ....} }
// eg. Dictionary[ (0 -> Dictionary[ (sine -> ...), (noise -> ... ]), ...]
~userChainVisualConfigs = Dictionary.new;

~getUserConfigsValue = {|configs|
	var configsFnStore = Dictionary.new;

	// ("***Syncing chain config for user: " ++ ~userNameList[~id]).postln;
	configs.collect({|chain|
		var chainStore = Dictionary.new;
		chain.keysValuesDo({|key, value|
			var valueString = value.asCompileString;

			// If the value is function, remove the {}
			// {rrand(3)}=> {}
			if(value.isFunction, {
				valueString = valueString.asArray[
					(1..valueString.size - 2)
				].join.asString.stripWhiteSpace;
			});

			// If it's a symbol, we use postString
			if(value.class == Symbol, {
				valueString = value.postString;
			});

			// everything else, like Pattern
			// we just use the compile string
			chainStore.put(key, valueString);
		});

		configsFnStore.put(chainStore.at(\name).asSymbol, chainStore);
	});

	configsFnStore;
};


OSCdef(\syncConfigs, {|msg|
	var userId = msg[1];
	var config = msg[2].asString.interpret;

	~userChainVisualConfigs[userId] = config;
}, \syncConfigs);

~syncChainConfigs = {
	n.sendMsg(
		'/syncConfigs',
		~id,
		~getUserConfigsValue.(~configs).asCompileString
	)
};

~updateOSCDefs = {|configs|
	configs.collect({|config, index|
		// Use asStream to evaluate the Pattern as as Routine
		// Function will stay the same
		var waitTimeFn = config['waitTime'].asStream;
		var nextTargetFn = config['nextTarget'].asStream;

		OSCdef(config.name.asSymbol, {|msg|
			var from = msg[2];
			var receiver = msg[1];
			var lastWaitTime = msg[3];
			var toRespond = ~respondChecker.(receiver);

			~histo[config.name] = (~histo[config.name]?[]).insert(0, [from, receiver]);
			// (config.name.asString++":"++~histogram.value(config.name)).postln;
			~play_message.(config.name.asSymbol, from, receiver, lastWaitTime);

			if(toRespond,
				{
					{
						var nextTarget = nextTargetFn.value();
						var waitTime = waitTimeFn.value();

						// Debug logging
						// ("***********").postln;
						// ("**" ++ config.name ++ "**:").postln;
						// ("Next target is " ++ nextTarget).postln;
						// ("Getting wait time " ++ waitTime).postln;
						// ("***********").postln;
						waitTime.wait;


						if (nextTarget.isNil, {
							(config.name +" sending nil, stopped").postln;
						}, {
							(receiver +" sending next message to " ++ nextTarget.asString).postln;
							n.sendMsg(config.name, nextTarget, ~id, waitTime);
						});
				}.fork;},{
					//else?
			});
		}, config.name.asSymbol).postln;
	});
	"OSCDefs updated";
};

"Initialized the piece!";
)