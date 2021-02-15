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
	// Slower queue, noise sound
	name: \slow,
	waitTime: {1},
	nextTarget: {[0, 1, 2].choose}
),  (
	// Faster queue, sine sound
	name: \fast,
	waitTime: {0.5},
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
// Needs to update oscdefs
~updateOSCDefs.value(~configs);
)


// *** Braids Section
(
// Send braid change
// positive number means add freq to the oscillator
// negative means minus
n.sendMsg('/braid', ~id, 1);
)

// Kill braid!
n.sendMsg('/braid_kill');

// Update braid max diff! (in frequency)
n.sendMsg('/braid_update_maxdiff', 200);

//////////////////////////////////////////chat
n.sendMsg('/chat', ~id, "Hello")


// **** Kick off the chain
(
// start slow chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/slow', to, ~id, 0.1);
)

(
// Start fast chain
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/fast', 0, ~id, 0.1);
)

(
// Start the buildUp queue
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/buildUp', to, ~id, 0.1);
)
