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
~configs = [(
	// sine sound
	name: \sine,
	waitTime: {0.3},
	nextTarget: {[2].choose},
	attack: {0.01},
	sustain: {0.9}
), (
	// noise sound
	name: \noise,
	waitTime: {1},
	nextTarget: {[2].choose},
	attack: {0.5},
	sustain: {0.998}
), (
	// Build up queue
	name: \buildUp,
	waitTime: {10.rand},
	nextTarget: {[0, 1, 2].choose}
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
n.sendMsg('/braid', 0, -1);
)
s.meter
// Kill braid!
n.sendMsg('/braid_kill');

// Update braid max diff! (in frequency)
n.sendMsg('/braid_update_maxdiff', 1000);

// ***** Build up

// Kill build up chain(but remember, if there's build up message still trasnfer, it will kick of itself again.)
n.sendMsg('/\build_up_kill');

// Setting partial coount threshold (eg, how many partials)
n.sendMsg('/build_up_partial_threshold', 10);

// Setting the step multiplier(how big each partial grow)
n.sendMsg('/\build_up_partial_step_multiplier', 13);

// Setting the amp multiplier(how big each partial's amp)
n.sendMsg('/\build_up_partial_amp_multiplier', 1);

//////////////////////////////////////////chat

n.sendMsg('/chat', ~id, "hello world");

// **** Kick off the chain
(
// Start the sine chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/sine', 2, ~id, 0.1);
)

(
// start the noise chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/noise', 2, ~id, 1);
)

(
// Start the buildUp queue
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/buildUp', 0, ~id, 0.1);
)
