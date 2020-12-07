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
~userList = [0, 1, 2];

~histo = [];

~histogram = {~histo[..0].collect({
	|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
	array.postln;
})};

~respond = {|n| n==~id};

~play_message = {|from, to, waitTime|
	var freqs = [442, 800, 1200];
	var pans = [-1, 0, 1];
	Synth(\gai_id, [
		\freq, freqs[to] * waitTime.value().linlin(0.1, 20, 0.3, 10),
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
	waitTime: {rrand(5, 20)},
	nextTarget: {~userList.reject(_==~id).choose}
),  (
	// Faster queue
	name: \fast,
	waitTime: {rrand(0.2, 1)},
	nextTarget: {~userList.reject(_==~id).choose};
)];


~configs.collect({|config, index|
	OSCdef(config.name.asSymbol, {|msg|
		var from = msg[2];
		var to = msg[1];
		~histo = ~histo.insert(0, [from, to]);
		~histogram.value;
		~play_message.(from, to, config.waitTime);

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

					n.sendMsg(config.name, nextTarget, ~id, "ok");
			}.fork;},{
				//else?
		});
	}, config.name.asSymbol).postln;

});
)


(
SynthDef(\gai_id,{|freq=440, amp=0.1, pan = 0, dur = 1|
	var sig = SinOsc.ar(freq);
	var env = EnvGen.kr(
		Env([0, 1, 0], [0.01, 0.7]),
		doneAction: 2,
		timeScale: dur
	);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;
	Out.ar(0,sig)
}).add;
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
n.sendMsg('/slow', 0, ~id, "ok");
)


///////////////////////////windo_sketch
//now it's fake
(
var w;
w = Window("numbers", Rect(0, 500, 128*2, 36*2));

w.view.background = Color.black;
CompositeView.new(w,Rect(5,5,256,60));
b = StaticText.new(w,Rect(5,5,256,40)).string_("0            1            2");
b.stringColor = Color.white;
b.font = Font("sansSerif",20);

w.front;
)

///////////////////////////////////////////notes
////////////////////possible_message_paths

// 0 >> 0
// 0 >> 1
// 0 >> 2

// 0 >> 0 & 1
// 0 >> 0 & 2
// 0 >> 1 & 2

// 0 >> 0 & 1 & 2

///////////////////

// 0 >> 1
// 1 >> 2
// 2 >> 0


////////////////////////////////////notes_of_sc
0.5.coin

[1,2,nil,3,4].removeEvery([nil])
[1, 2, nil, 3, 4].select(_.isNil.not)
[1, 2, nil, 3, 4].reject(_.isNil)



