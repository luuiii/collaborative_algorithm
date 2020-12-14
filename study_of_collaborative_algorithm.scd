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

~histogram = {|name| (~histo[name]?[])[..0].collect({|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
//	array.postln;
})[0]};

~respond = {|n| n==~id};

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

~play_message = {|from, to, waitTime|
	var freqs = [400, 800, 1200];
	var pans = [-1, 0, 1];

	Synth(\gai_id, [
		\freq, freqs[to] * waitTime.value().linexp(0.1, 20, 0.3, 5),
		\pan, pans[from],
		\dur: waitTime.value() * 0.5,
	]
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
~configs = [(
	// Slower queue with longer wait time
	name: \slow,
	waitTime: {rrand(2, 5)},
	nextTarget: {~userList.reject(_==~id).choose},
	// Weight choose
	// nextTarget: {~userList.reject(_==~id).wchoose([0.1, 0.9])}
	// Fixed target, alwasy send to this
	// nextTarget: {0}
),  (
	// Faster queue
	name: \fast,
	waitTime: {rrand(0.1, 0.5)},
	// waitTime: {[rrand(0.04,  0.05), rrand(0.4, 4)].wchoose([0.8, 0.2])},
	nextTarget: {~userList.reject(_==~id).choose};
)];


~configs.collect({|config, index|
	OSCdef(config.name.asSymbol, {|msg|
		var from = msg[2];
		var to = msg[1];
		var lastWaitTime = msg[3];
		~histo[config.name] = (~histo[config.name]?[]).insert(0, [from, to]);
		(config.name.asString++":"++~histogram.value(config.name)).postln;
		~play_message.(from, to, lastWaitTime);

		if(~respond.(msg[1]),
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

					(msg[1] +" sending next message to " ++ nextTarget.asString).postln;

					n.sendMsg(config.name, nextTarget, ~id, waitTime);
			}.fork;},{
				//else?
		});
	}, config.name.asSymbol).postln;

});
OSCdef(\chat,{|msg|
	(~userNameList[msg[1]]++": "++(msg[2]).asString).postln},\chat);
)


// **** Trigger the piece
(
// Send message to slow
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/slow', 0, ~id, "ok");
)

(
// Send message to fast
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/fast', 0, ~id, "ok");
)

//////////////////////////////////////////chat
n.sendMsg('/chat',~id, "?")
