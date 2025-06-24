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
(
// This is the switch to control whether we are playing in a physical venue
//~offlinePerformance = false;
~offlinePerformance = false;
~configs = [(
	// sine sound
	name: \sine,
	//waitTime: 1/1.exp,
	waitTime: Pseq([1/1.exp, 1.exp*0.499]*0.944, inf),
	//waitTime: Pbrown(0.30, 0.333, 0.03)/pi, //  /3
	//waitTime: {exprand(1/pi, 1/1.exp)*0.9},
	//waitTime: 1/1.exp, //1.05,
	//waitTime: pi*pi,
	//waitTime: Pwhite(0.1, Pbrown(0.1, 1.11, 0.125), inf), //1.01/0.1, 1.01,1.001,1.11
	//waitTime: {rrand(0.2, 0.5)-0.3}, //0.2, 0.5 -0.3, + 1.01


	//waitTime: Pgeom(1/1.exp, Pbrown(1.01, 1.11),inf),
	//waitTime: Pgeom(1/pi-0.3, Pbrown(1.01, 1.11),inf),

	//waitTime: Pwhite(0.1, Pbrown(2.50, 2.90, 0.05), inf),
	//waitTime: Pwhite(0.1, Pbrown(0.50, 2.90, 0.05), inf),//0.1, 1.01,1.11
	//waitTime: {rrand(0.19, 0.23)+1.01}, //0.2, 0.5
	//waitTime: Pseq([1/1.exp,1.exp, pi, 1/pi].powerset.flatten.scramble, inf),

	//nextTarget: {[0,1].choose},
	nextTarget: Pseq([0,1,2].powerset.flatten,inf),
	//nextTarget: {[1,2].choose},

	//attack: {0.9},
	attack: {[0.005, 0.1].choose},
	//attack: {[0.005, 0.9].choose},
	//attack: {[0.005, 0.1, 0.3, 0.5, 0.7, 0.9].choose},
	//attack: {[0.005].choose},
	sustain: {0.2}
), (
	// noise sound
	name: \noise,
	waitTime: {pi},
	//waitTime: Pseq([0.25, 0.5], inf),
	nextTarget: {[0,1,2].choose},
	//nextTarget: {[nil].choose},
	//attack: {0.00001},
	//attack: Pseq([0.25, 0.5], inf),
	//attack: {[0.001,0.9].choose},
	attack: {pi},
	sustain: {1/pi}
),  (
	// Build up queue
	name: \buildUp,
	waitTime: {0.1},
	nextTarget: {[nil].choose},
	//nextTarget: {[0,1,2].choose}
), (
	name: \sample,
	feature: Pseq([\telephone, \signal], inf),
	waitTime: Pseq([4, 4], inf),
	nextTarget: {[1].choose},
	attack: {0.2},
	sustain: {0.9}
), (
	name: \sampleFull,
	feature: Pseq([\london], inf),
	waitTime: Pseq([4], inf),
	nextTarget: {[1].choose},
	attack: {0.2},
	sustain: {0.9}
)
];

// We need to sync chain configs for visual display
~syncChainConfigs.value();
// Needs to update oscdefs
~updateOSCDefs.value(~configs);
)


// *** Braids Section
(
// Send braid change
// positive number means add freq to the oscillator
// negative means minus
n.sendMsg('/braid', ~id, 10);
)

// Kill braid!
n.sendMsg('/braid_kill');
.
// Update braid max diff! (in frequency)
n.sendMsg('/braid_update_maxdiff', 5000);

// ***** Build up

// Kill build up chain(but remember, if there's build up message still trasnfer, it will kick of itself again.)
n.sendMsg('/\build_up_kill');

// Setting partial coount threshold (eg, how many partials)
n.sendMsg('/build_up_partial_threshold', 3);

// Setting the step multiplier(how big each partial grow)
n.sendMsg('/\build_up_partial_step_multiplier', 1);

// Setting the amp multiplier(how big each partial's amp)
n.sendMsg('/\build_up_partial_amp_multiplier', 0.6);

//////////////////////////////////////////chat

n.sendMsg('/chat', ~id, "jingkelong niubi");

// **** Kick off the chain
(
// Start the sine chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sine', to, ~id, 1);
)

(
// start the noise chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/noise', to, ~id, 0.1);
)


(
// Start the buildUp queue
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/buildUp', to, ~id, 0.1);
)

(
// Start sample chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sample', to, ~id, 0.1);
)


(
// Start sample full chain(always play the full duration)
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sampleFull', to, ~id, 0.1);
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