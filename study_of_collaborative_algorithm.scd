//////////collaboratic_algorithm///////////

//////////Jia__&__Song__&__Shuoxin/////////

/////////////////20201117//////////////////

//date1118: simple implementation of distributed markov chain

//to-do: responding state chart for every one

(
n = NetAddr("127.0.0.1", 57120);
~id = 0;
~userList = [0,1,2];
)


////////////////////////////////////////////////////////logic


(//////////////////////////////receive_all
(OSCdef(\send, {|msg|
	if(true,
		{
			{
				var to = ~userList.reject(_==msg[1]).choose;
				var chart = [" "," "," "];
				0.5.wait;
				chart[msg[1]] = to;
				chart.postln;
				n.sendMsg('/markov', to, "ok");
		}.fork;},{
			//else?
	});
}, \markov);
))

(///////////////////////////////////send
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/markov', to, "ok");
)

(///////////////////markov_chain_like
	var u1 = [1,2];
	var u2 = [0,2];
	var u3 = [0,1];
var state= Array.fill(3,"  ");
	var current = [u1,u2,u3].choose.choose;
30.do{
	var next_choice;
	state = Array.fill(3,"  ");
	next_choice = [u1,u2,u3][current].choose;
	state[current] = next_choice;
	state.postln;
	current = next_choice;
})



////////////////////////////////////universal_implementation
(////////////////////////////////////receive
(OSCdef(\send, {|msg|
	if(msg[1] == ~id,
		{
			{
				var to = ~userList.reject(_==~id).choose;
				0.5.wait;
				(msg[1]+" sending next message to " ++ to.asString).postln;
				n.sendMsg('/markov', to, "ok");
	}.fork;},{
//else?
	});
}, \markov);
))

(///////////////////////////////////send
var to = ~userList.reject(_==~id).choose;
to.postln;
n.sendMsg('/markov', 0, "ok");
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



