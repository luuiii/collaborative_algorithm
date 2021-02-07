//////////collaboratic_algorithm///////////

//////////Jia__&__Song__&__Shuoxin/////////

/////////////////20201117//////////////////

//date1123: responding state chart for every one

//to-do: maybe play a bit with sound

(
n = NetAddr("127.0.0.1", 57140);
// The performer's ID
// Jia - 0
// Song - 1
// Shuoxin - 2
~id = 0;
~userNameList = ["jia","song","shuoxin"];
~userList = [0, 1, 2];

~histo = ();
~chat = [];
~histogram = {|name| (~histo[name]?[])[..0].collect({|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
//	array.postln;
})[0]};

~respondChecker = {|n| n==~id};

~partialVolumes = [ 0.14, 0.105, 0.07, 0.07, 0.035, 0.0175, 0.0315, 0.07, 0.028, 0.01, 0.01];

~partialList = [71, 120, 162, 193.1, 311.22, 425.667, 511.11, 939, 1022.1111, 2000, 3133] * Array.series(11,1,0);

~partialThreshold = 11;
~partialCount = 0;

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


SynthDef(\braid, {|freq=440, amp=0.1, pan = 0, attack = 1, gate = 1, freqBus = 0|
	var detectedFreq, hasFreq;
	var sig = SinOsc.ar(freq.lag(10));
	var env = EnvGen.kr(
		Env([0, 1, 0], [attack, 10], releaseNode: 1),
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

~play_message = {|queueName, from, to, waitTime|
	if (queueName == \buildUp, {
		~checkPartial.value();
		~addPartial.value();
	}, {
		var freqs = [400, 800, 1200];
		var pans = [-1, 0, 1];

		Synth(\gai_id, [
			\freq, freqs[to] * waitTime.value().linexp(0, 20, 0.3, 5),
			\pan, pans[from],
			\dur: waitTime.value() * 0.5,
		])
	});
};

// Braid configs
~freqList = [404, 400, 396];
~maxDiff = 100;
~braidBus = Bus.new(\control, 0, ~userList.size);

~applyFreqChange = {|index, change|
	var wish_freqs = ~freqList.collect({|item,i| if(i==index,{item + change},{item})});
	var freq_diff = wish_freqs.maxItem - wish_freqs.minItem;
	"wish_freqs"++wish_freqs.postln;
	"freq_diff" ++freq_diff.postln;
	if(freq_diff > ~maxDiff,{
		if(change>0,{
			~freqList[index] = wish_freqs.minItem + ~maxDiff
		},{~freqList[index] = wish_freqs.maxItem - ~maxDiff})
	},{~freqList[index] = ~freqList[index]+change});
	~freqList.postln;
};
~braidisInitialized = false;
~braidSynth = [];

// ************
// Configs Sync
// ************

// global var that holds all performer's config value as string(For visual display)
// userId -> { chainName -> { waitTime -> ...., nextTarget -> ....} }
// eg. Dictionary[ (0 -> Dictionary[ (fast -> ...), (slow -> ... ]), ...]
~userChainVisualConfigs = Dictionary.new;

~getUserConfigsValue = {|configs|
	var configsFnStore = Dictionary.new;

	// ("***Syncing chain config for user: " ++ ~userNameList[~id]).postln;
	configs.postln;
	configs.collect({|chain|
		var chainStore = Dictionary.new;
		chain.keysValuesDo({|key, value|
			var valueString = value.postString;
			valueString = valueString.removing(valueString.first);
			valueString = valueString.removing(valueString.last);

			chainStore.put(key, value.postString);
		});
		chainStore.postln;
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
}
)

////////////////////////////////////universal_implementation
////////////////////////////////////receive
(
// Configs for the message queue
// To Performers:
// You need to change this configs value and then evaluate the entire
// block

// Tips for changing the configs for different chains:
// ### Weight choose
// waitTime: {[rrand(0.04,  0.05), rrand(0.4, 4)].wchoose([0.8, 0.2])},
// nextTarget: {~userList.reject(_==~id).wchoose([0.1, 0.9])}
// ### Fixed target, alwasy send to this
// nextTarget: {0}
~configs = [(
	// Slower queue with longer wait time
	name: \slow,
	waitTime: {3},
	nextTarget: {[0, 1, 2].choose},
),  (
	// Faster queue
	name: \fast,
	waitTime: {0.3},
	nextTarget: {[0, 1, 2].choose}
), (
	// Build up queue
	name: \buildUp,
	waitTime: {10},
	nextTarget: {[0, 1, 2].choose}
)
];

// We need to sync chain configs for visual display
~syncChainConfigs.value();

~configs.collect({|config, index|
	OSCdef(config.name.asSymbol, {|msg|
		var from = msg[2];
		var receiver = msg[1];
		var lastWaitTime = msg[3];
		var toRespond = ~respondChecker.(receiver);

		~histo[config.name] = (~histo[config.name]?[]).insert(0, [from, receiver]);
		(config.name.asString++":"++~histogram.value(config.name)).postln;
		~play_message.(config.name.asSymbol, from, receiver, lastWaitTime);

		if(toRespond,
			{
				{
					var nextTarget = config.nextTarget.value();
					var waitTime = config.waitTime.value();

					("***********").postln;
					("**" ++ config.name ++ "**:").postln;
					("Next target is " ++ nextTarget).postln;
					("Getting wait time " ++ waitTime).postln;
					("***********").postln;
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

OSCdef(\chat,{|msg|
	var format = ~userNameList[msg[1]]++": "++(msg[2]).asString;
	format.postln;
	~chat = ~chat ++ [format];
},\chat);

OSCdef(\apply_freq,{|msg|
	if(~braidisInitialized == false,{
		"braidSynth Initialized ".postln;
		~braidisInitialized = true;
		~braidSynth = ~freqList.collect({|item, index|
			Synth(\braid, [
				\freq, item,
				\pan,[-1,0,1][index],
				\freqBus, ~braidBus.index + index,
			]);
		});
	},{
		~applyFreqChange.value(msg[1],msg[2]);
		~braidSynth[msg[1]].set(\freq, ~freqList[msg[1]])
	})
}, \braid)
)

// **** Trigger the piece
(
// Send message to slow
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/slow', 0, ~id, 0);
)

(
// Send message to fast
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/fast', 0, ~id, 0);
)

(
// Start the buildUp queue
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/buildUp', 0, ~id, 0);
)

(
// Send braid change
// positive number means add freq to the oscillator
// negative means minus
n.sendMsg('/braid', ~id, 10);
)
//////////////////////////////////////////chat
n.sendMsg('/chat', ~id, "Hello")