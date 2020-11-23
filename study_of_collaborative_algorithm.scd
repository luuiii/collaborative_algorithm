//////////collaboratic_algorithm///////////

//////////Jia__&__Song__&__Shuoxin/////////

/////////////////20201117//////////////////

//date1123: responding state chart for every one

//to-do: maybe play a bit with sound

(
n = NetAddr("127.0.0.1", 57140);
~id = 0;//li_gai_id
~userList = [0,1,2];

~histo = [];

~histogram = {~histo[..0].collect({
	|msg|
	var from = msg[0];
	var to = msg[1];
	var array = ''!3;
	array[from] = to;
	array.postln;
})};

~respond = {|n|  n==~id};
~play_message = {|from,to|
	var freqs = [442, 800, 1200];
	var pans = [-1,0,1];
	Synth(\gai_id, [\freq, freqs[to],\pan, pans[from]])
}
)


////////////////////////////////////universal_implementation
////////////////////////////////////receive
(OSCdef(\send, {|msg|

	var from = msg[2];
	var to = msg[1];
	~histo = ~histo.insert(0,[from, to]);
	~histogram.value;
	~play_message.(from, to);
	if(~respond.(msg[1]),
		{
			{
				var next = ~userList.reject(_==~id).choose;
				0.5.wait;
				(msg[1]+" sending next message to " ++ next.asString).postln;
				n.sendMsg('/markov', next, ~id, "ok");
	}.fork;},{
//else?
	});
}, \markov);

SynthDef(\gai_id,{|freq=440, amp=0.1, pan = 0|
	var sig = SinOsc.ar(freq);
	var env = EnvGen.kr(Env([0,1,0],[0.01,0.7]), doneAction:2);
	sig = Pan2.ar(sig, pan);
	sig = sig*env*amp;
	Out.ar(0,sig)
}).add

)




(///////////////////////////////////send
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/markov', 0, ~id, "ok");
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



