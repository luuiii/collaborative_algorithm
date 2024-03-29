//////////collaboratic_algorithm///////////

//////////Jia__&__Song__&__Shuoxin/////////

// Last updated time
// 20210904

//date1123: responding state chart for every one

//to-do: maybe play a bit with sound


(
n = NetAddr("127.0.0.1", 57140);
// The performer's ID
// Jia - 0
// Song - 1
// Shuoxin - 2
~state = State.new(n);
~id = 1;
~userNameList = [
	"jia",
	"song",
	"shuoxin",
	"edward",
];
~userList = [0, 1, 2];
~braidInitFreq = 110;

// Buffers
Buffer.freeAll;
~audioFiles = "/Volumes/GoogleDrive/*/*/Musikfonds/audio/*.wav".pathMatch;
~parseTagsFromPath = {|path|
	var file, ext, chunks;
	#file, ext = path.splitext;
	chunks = file.split($-);
	chunks[2].split($|);
};


~loadFiles = {|filePaths|
	var buffers = [];
	var buffersMap = IdentityDictionary.new();

	filePaths.collect{ |path, index|
		// 00-20211011-karlsruhe|announcment.wav
		var tags = ~parseTagsFromPath.(path);
		var buffer = Buffer.read(s, path);
		buffers = buffers ++ buffer;

		tags.do {|tag|
			var tagSymbol = tag.asSymbol;
			buffersMap[tagSymbol] = (buffersMap[tagSymbol] ? [] ) ++ [index];
		}
	};
	[buffers, buffersMap];
};

~loadedContent = ~loadFiles.(~audioFiles);
~buffers = ~loadedContent[0];
~buffersMap = ~loadedContent[1];

~buffersMap.keys().do{|key|
	(key ++ " length: " ++ ~buffersMap[key].size).postln;
};

// To read the offline mode from config, if it's not there
~offlinePerformance = if(~offlinePerformance.isNil, false, ~offlinePerformance);
~histo = ();
~chat = [];
~histogram = {|name| (~histo[name]?[])[..0].collect({|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
})[0]};

~isSelfChecker = {|n| n==~id};

// Build up chain settings

~partialThreshold = 11;
~partialCount = 0;
~partialStepMultiplier = 1;
~partialAmpMultiplier = 1;

~genPartialConfig = {
	~partialVolumes = Array.rand(~partialThreshold, 0.012, 0.045) * ~partialAmpMultiplier;
	~partialList = [500] + Array.series(
		~partialThreshold, 50, rrand(40, 55) * ~partialStepMultiplier
	);
};

// Init the volumes and list for partial
~genPartialConfig.value();

~sineGroup = Group.new(addAction: \addToTail);

~addPartial = {|genSound|
	var freq = ~partialList[~partialCount];
	var amp = ~partialVolumes[~partialCount];
	("Adding one partial number:" ++ ~partialCount ++ " with freq: " ++ freq).postln;

	if(genSound, {
		Synth(\sine,
			[\freq, freq, \amp, amp],
			~sineGroup,
			\addToTail
		);
	});

	~partialCount = ~partialCount + 1;
};

~offlinePanMap = {|loc|
	0;
};

~panMap = {|loc|
	var panMap = [-1, 0, 1];
	panMap[loc];
};

~getPanFunc = {
	if(~offlinePerformance, {
		~offlinePanMap;
	}, {
		~panMap;
	});
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
		("***!!Invalid partial step multiplier :" ++ val).error;
	});
};

~updatePartialAmpMultiplier = { |val|
	if(val.isNumber && val >= 0, {
		("***Update partial amp multiplier to :" ++ val).postln;
		~partialAmpMultiplier = val;
		~genPartialConfig.value();
	}, {
		("***!!Invalid partial amp multiplier :" ++ val).error;
	});
};

~updatePartialThreshold = { |val|
	if(val.isNumber && val > 1, {
		("***Update partial thresold to to :" ++ val).postln;
		~partialThreshold = val;
		~genPartialConfig.value();
	}, {
		("***!!Invalid partial thresold :" ++ val).error;
	});
};


// display utility function for performance windows
~checkSectionPart = {|part|
	if([\currentTarget, \algo].includes(part).not, {
		Error("Section part %s is invalid".format(part)).throw;
	});
};

~getSectionDisplayState = {|chain, part|
	var toDisplay = ~state.getVal(chain, part);
	~checkSectionPart.value(part);
	toDisplay == true || toDisplay == 1;
};

~updateSectionDisplayState = {|chain, part, val|
	~checkSectionPart.value(part);
	~state.update(chain, part, val);
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

SynthDef(\sine, {|freq=440, amp=0.12, pan = 0, attack = 1, gate = 1|
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

	#detectedFreq, hasFreq = Pitch.kr(sig, initFreq: ~braidInitFreq, minFreq:40, maxFreq: 10500);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;

	Out.ar(0, sig);
	Out.kr(freqBus, [detectedFreq]);
}).add;


SynthDef(\gai_id,{|
	freq=440, amp=0.12, pan = 0, dur = 1, attack=0.1, sustain=0.8
	|
	var sig = SinOsc.ar(freq);
	var env = EnvGen.kr(
		Env([0, 1, 1, 0], [
			(1 - sustain) * attack,
			sustain,
			(1 - sustain) * (1 - attack)
		]),
		doneAction: 2,
		timeScale: dur
	);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;
	Out.ar(0,sig)
}).add;

SynthDef(\playbufFull, {|out=0, pan=0, rate=1.0, attack=0.03, sustain=0.06, amp=1.0, startPos=0, bufnum|
	var env, sig;
	sig = PlayBuf.ar(
		2, bufnum, rate: BufRateScale.kr(bufnum) * rate,
		startPos: BufFrames.ir(bufnum) * startPos,
		loop: 0, doneAction: Done.freeSelf);
	env = EnvGen.kr(
		Env([0, 1, 1, 0], [
			(1 - sustain) * attack,
			sustain,
			(1 - sustain) * (1 - attack)
		]),
		doneAction: 2,
		timeScale: BufDur.kr(bufnum) * (1 / rate),
	);
	sig = sig*env*amp;
	Out.ar(out, sig);
}).add;

SynthDef(\playbuf, {|out=0, pan=0, dur=20, rate=1.0, attack=0.03, sustain=0.06, amp=1.0, startPos=0, bufnum|
	var env, sig;
	sig = PlayBuf.ar(
		2, bufnum, rate: BufRateScale.kr(bufnum) * rate,
		startPos: BufFrames.ir(bufnum) * startPos,
		loop: 0, doneAction: Done.freeSelf);
	env = EnvGen.kr(
		Env([0, 1, 1, 0], [
			(1 - sustain) * attack,
			sustain,
			(1 - sustain) * (1 - attack)
		]),
		doneAction: 2,
		timeScale: dur
	);
	sig = sig*env*amp;
	Out.ar(out, sig);
}).add;

SynthDef(\noise, {|out=0, amp=0.1, freq=1500, rq=1, dur=5, attack=0.5, sustain= 0.998, pan=0|
	var in = GrayNoise.ar(1);
	var sig = BPF.ar(in, freq, rq);

	var env = EnvGen.kr(
		Env([0, 1, 1, 0], [
			(1 - sustain) * attack,
			sustain,
			(1 - sustain) * (1 - attack)
		]),
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


~responseToEventForLoc = {|loc|
	~offlinePerformance.not || (~isSelfChecker.value(loc));
};


// ~getBufferByFeaturesState = {
// 	var features = ~state.getVal(\sample, \features);
//
// 	if(features.isNil, {
// 		~buffers.size.rand;
// 		}, {
// 			features.collect({|feature| ~buffersMap[feature]}).flat.choose;
// 	});
// };

~getBufferByFeature = {|feature|
	if(feature.isInteger, {
		if ((feature < ~buffers.size) && (feature > -1), {
			feature
		}, {
			("Invalid feature '" ++ feature ++"' for sample").error;
			nil
		});
	}, {
		var selectedSample;
		selectedSample = ~buffersMap[feature];
		if (selectedSample.size > 0,{ selectedSample.choose}, {
			("Invalid feature '" ++ feature ++"'for sample").error;
			nil
		});
	})
};

~play_message = {|queueName, from, to, waitTime, attack, sustain, bufindex|
	// When it's offline and it's not for you. We do nothing
	var respondToEvent = ~responseToEventForLoc.(from);
	var panFunc = ~getPanFunc.value();
	var pitchScale = ~state.getVal(queueName, \pitch);
	var durScale = ~state.getVal(queueName, \dur) ? 1;
	// ("received bufindex " ++ bufindex).postln;

	switch(queueName,
		\buildUp, {
			~checkPartial.value();
			~addPartial.value(genSound: respondToEvent);
		},
		\sample, {
			if(respondToEvent && bufindex.isNil.not, {
				Synth(\playbuf, [
					\amp, 0.3,
					\bufnum, ~buffers[bufindex],
					\rate, 1,
					\startPos, 0,
					\dur, waitTime.value() * durScale,
					\attack, attack ? 0.02,
					\sustain, sustain ? 0.998,
				]);
			})
		},
		\sampleFull, {
			if(respondToEvent && bufindex.isNil.not, {
				Synth(\playbufFull, [
					\amp, 0.3,
					\bufnum, ~buffers[bufindex],
					\rate, 1,
					\startPos, 0,
					\attack, attack ? 0.02,
					\sustain, sustain ? 0.998,
				]);
			})
		},
		\noise, {
			if(respondToEvent, {
				var freqs = [300, 700, 2300];

				Synth(\noise, [
					\amp, 0.25,
					\freq, freqs[to] * pitchScale,
					\rq, 0.5,
					\pan, panFunc.value(from),
					\dur, waitTime.value() * 0.4,
					\attack, attack ? 0.5,
					\sustain, sustain ? 0.998,
				]);
			})
		}, {
			if(respondToEvent, {
				var freqs = [400, 600, 900];

				Synth(\gai_id, [
					\freq, freqs[to] * waitTime.value().linexp(
						0, 19, 8 * pitchScale, 0.00000001
					),
					\pan, panFunc.value(from),
					\dur, waitTime.value() * 0.5,
					\attack, attack ? 0.1,
					\sustain, sustain ? 0.7,
				]);
			})
		}
	);
};


// Braid configs
~freqList = ~braidInitFreq.dup(~userList.size);
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
			if (~responseToEventForLoc.value(index), {
				Synth(\braid, [
					\freq, item,
					\pan, ~getPanFunc.value().value(index),
					\freqBus, ~braidBus.index + index,
				]);
			});
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

OSCdef(\update_state, {|msg|
	var chain = msg[1].asSymbol;
	var key = msg[2].asSymbol;
	var val = msg[3];
	~state.setVal(chain, key, val);
}, \update_state);

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
		var featureFn = config['feature'].asStream;

		var attackFn = config['attack'].asStream;
		var sustainFn = config['sustain'].asStream;

		if(config['waitTime'].asStream.value().isArray, {
			Error("Chain %s can't return an array for waitTime".format(config.name.asSymbol)).throw;
		});

		if(config['nextTarget'].asStream.value().isArray, {
			Error("Chain %s can't return an array for nextTarget".format(config.name.asSymbol)).throw;
		});

		if(config['feature'].asStream.value().isArray, {
			Error("Chain %s can't return an array for feature".format(config.name.asSymbol)).throw;
		});

		OSCdef(config.name.asSymbol, {|msg|
			var from = msg[2];
			var receiver = msg[1];
			var lastWaitTime = msg[3];
			var attack = msg[4];
			var sustain = msg[5];
			var sampleBufindex = msg[6];
			var toRespond = ~isSelfChecker.(receiver);
			var chainName = config.name.asSymbol;

			// "whether to response?".postln;
			// toRespond.postln;

			~histo[config.name] = (~histo[config.name]?[]).insert(0, [from, receiver]);
			// (config.name.asString++":"++~histogram.value(config.name)).postln;

			~state.recordPassing(config.name.asSymbol);

			~play_message.(
				chainName, from, receiver, lastWaitTime,
				attack, sustain, sampleBufindex
			);

			// "============".postln;
			// ~state.postln;
			// "============".postln;

			if(toRespond,
				{
					{
						var nextTarget = nextTargetFn.value();
						var waitTime = waitTimeFn.value();
						var selectedFeature = featureFn.value();

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
							// (receiver +" sending next message to " ++ nextTarget.asString).postln;

							// For sample chain, it has an extra buffer argument
							if ([\sample, \sampleFull].includes(chainName), {
								n.sendMsg(
									config.name, nextTarget, ~id, waitTime,
									attackFn.value(),
									sustainFn.value(),
									~getBufferByFeature.value(selectedFeature)
								);

							}, {
								n.sendMsg(
									config.name, nextTarget, ~id, waitTime,
									attackFn.value(),
									sustainFn.value(),
								);
							})
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
