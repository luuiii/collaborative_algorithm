// Configs for the message queue
// To Performers:
// You need to change this configs value and then evaluate the entire
// block

// Tips for changing the configs for different chains:
// *** Weight choose
// waitTime: {[rrand(0.04,  0.05), rrand(0.4, 4)].wchoose([0.8, 0.2])},
// nextTarget: {~userList.reject(_==~id).wchoose([0.1, 0.9])}
// *** Fixed target, alwasy send to this
// nextTarget: {0}
// *** You can use pattern class in SC as well, you don't need {}
//     remember to always put "inf" in the repeats
// waitTime: Pseq([0.1, 0.2, 0.3], inf)
s.makeWindow
s.meter
(
// This is the switch to control whether we are playing in a physical venue
~offlinePerformance = false;
~configs = [(
	// sine sound
	name: \sine,
	waitTime: {1},
	nextTarget: {[0].choose},
	attack: {0.5},
	sustain: {0.2},
	amp: {0.3},
), (
	// noise sound
	name: \noise,
	waitTime: Pseq([1, 1, 0.1], inf),
	// waitTime: Pxrand([0.1, 2, 3, 0.01], inf),
	// waitTime: Pxrand([0.1, 3, 0.7, 6], inf),
	nextTarget: {[nil].choose},
	attack: {0.1},
	sustain: {0.2},
	amp: {0.3}
),  (
	// Build up queue
	name: \buildUp,
	waitTime: {0.1.rand},
	nextTarget: {[nil].choose},
	amp: {0.1}
), (
	name: \sample,
	feature: Pseq([\telephone, \signal], inf),
	waitTime: Pseq([4, 4], inf),
	nextTarget: {[1].choose},
	attack: {0.2},
	sustain: {0.9},
	amp: {0.3}
), (
	name: \sampleFull,
	feature: Pseq([\london], inf),
	waitTime: Pseq([4], inf),
	nextTarget: {[1].choose},
	attack: {0.2},
	sustain: {0.9},
	amp: {0.3}
)
];

// We need to sync chain configs for visual display
~syncChainConfigs.value();
// Needs to update oscdefs
~updateOSCDefs.value(~configs);
)


// update sine base freq
(
var freq = 1000;
~state.setVal(\baseFreq, ~id, freq);
);

// *** Braids Section
(
// Send braid change
// positive number means add freq to the oscillator
// negative means minus
n.sendMsg('/braid', ~id, 1);
n.sendMsg('/braid', 0, 0.5);
)

n.sendMsg('/braid', 1, -2);


n.sendMsg('/braid', 2, -19);

// Kill braid!
n.sendMsg('/braid_kill');

// Update braid max diff! (in frequency)
n.sendMsg('/braid_update_maxdiff', 200);

// ***** Build up

// Kill build up chain(but remember, if there's build up message still trasnfer, it will kick of itself again.)
n.sendMsg('/\build_up_kill');

// Setting partial coount threshold (eg, how many partials)
n.sendMsg('/build_up_partial_threshold', 20);

// Setting the step multiplier(how big each partial grow)
n.sendMsg('/\build_up_partial_step_multiplier', 2);

// Setting the amp multiplier(how big each partial's amp)
n.sendMsg('/\build_up_partial_amp_multiplier', 0.1);

//////////////////////////////////////////chat

n.sendMsg('/chat', ~id, "chin burger");

// **** Kick off the chain

s.meter
StageLimiter.activate

(
// Start the sine chain
var to = ~userList.reject(_==~id).choose;
to.postln;
// target, sender, waitTime, attack, sustain, amp, level, maxLevel
n.sendMsg('/sine', 0, ~id, rrand(1, 2), 0.5, 0.2, 0.12, 0, rrand(50, 400));
)

(
// start the noise chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/noise', 1, ~id, 0.1, 0.00001, 0.5, 0.25, 0, rrand(50, 100)); // target, sender, waitTime, attack, sustain, amp, level, maxLevel
)

(
// Start buildUp chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/buildUp', 1, ~id, 0.1, 0.1, 0.2, 0.1, 0, 100); // target, sender, waitTime, attack, sustain, amp, level, maxLevel
)


(
// Start sample chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sample', to, ~id, 4, 0.2, 0.9, 0.3, nil, 0, 6); // target, sender, waitTime, attack, sustain, amp, bufIndex, level, maxLevel
)

(
// Start sample full chain (always play the full duration)
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sampleFull', to, ~id, 4, 0.2, 0.9, 0.3, nil, 0, 6); // target, sender, waitTime, attack, sustain, amp, bufIndex, level, maxLevel
)


(
// Set sample durtion scale
// 1 means same duration as waitTime
~state.update(\sample, \dur, 1.1);
)

// Control display of current Target (0, 1, 2 number )
// chain, \currentTarget, boolean
(
~updateSectionDisplayState.value(\sine, \currentTarget, true);
)

// Control display of pattern(waitTime, nextTarget)
// chain, \algo, boolean
(
~updateSectionDisplayState.value(\sine, \algo, true);
)


// Control the entire sections open/close
// true -> open
// false -> close
(
var action = true;
~configs.collect(_[\name]).collect({|name|
	~updateSectionDisplayState.value(name, \currentTarget, action);
	~updateSectionDisplayState.value(name, \algo, action);
});
)
