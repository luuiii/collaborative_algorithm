(
var scale = 1; //1.5 for full HD
var width = 1280 * scale;
var height = 720 * scale;

var indent_lmr = 0.25;
var leftshift = 0;
var box_width = 0.21 * width;
var left = width * (0.5 - indent_lmr) - leftshift;
var mid = width * 0.5 - leftshift;
var right = width * (0.5 + indent_lmr) - leftshift;

var current_message_space = 0.15 * height;
var algo_space = 0.03 * height;

var current_message = [];
var waitTime_array = [];
var target_array = [];
var feature_array = [];
// var chat_array = [];

var indent = 0.03125 * width;
var chat_indent = 0.05 * width;

var posY = - 0.375 * height;

var chat_posY = 0.5 * height;
var chat_linespace = 0.03 * height;
// How big the chat window is
var chatSectionWidth = 0.618*width;
var chatSentenceSpace =  0.2 * height;

var runBraid = true; //braid
var indentBraid = 0.015 * width;
var pathBraid = [];
var movingSpeed = 1 * scale;
var drawWidth = 0.1;
var chatTextField;
var chatSentencesCount = 7;


// Get the display value for the chain and a key
// for example: getValuesForKey.(\noise, \waitTime)
//  -> ["{1}", "", "{rrand(0.2, 0.5}"]
var getValuesForKey = {|chain, key, user|
	(user..user).collect({|index|
		try { ~userChainVisualConfigs[index][chain][key] } { |error|
			""
		};
	})
};

var show = {|items|
	if(items.isNil,{
		"";
	},{
		items = items.asString;
	})
};

w = Window.new(name:"[ _  _  _ ]", bounds: Rect(0, 0, width, height), border:true);
w.view.background = Color.black;

current_message = Array.fill(15,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.75*box_width), 1.07*posY + ((i/3).floor*current_message_space), box_width, height)).font_(Font("Helvetica Neue",scale*32*[3,3,0.5,1,1][i/3],
	[0,1,0,0,0][(i/3).floor.asInteger].asBoolean,[0,1,0,1,1][(i/3).floor.asInteger].asBoolean)).stringColor_([Color.white,Color.white,Color.fromHexString("E93000"),Color.white,Color.white][i/3]).align_(\left);});

waitTime_array = Array.fill(15,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.5*box_width), posY + algo_space + ((i/3).floor*current_message_space), box_width, height)).font_(Font("menlo",11 * scale)).align_(\left).stringColor_(Color.gray)});

target_array = Array.fill(15,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.5*box_width), posY + (2 * algo_space) + ((i/3).floor*current_message_space), box_width, height)).font_(Font("menlo",11 * scale)).align_(\left).stringColor_(Color.gray)});

feature_array = Array.fill(15,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.5*box_width), posY + (3.2 * algo_space) + ((i/3).floor*current_message_space), box_width, height)).font_(Font("menlo",11 * scale)).align_(\right).stringColor_(Color.gray)});

chatTextField = StaticText.new(
	w, Rect(chat_indent, chat_posY, chatSectionWidth, height*0.395)
).font_(Font("menlo", 12 * scale)).align_(\bottomLeft).stringColor_(Color.gray);


w.front;
r = {
	inf.do { |i|
		{
			current_message[..5].do{|item, index|
				item.string_(show.((~histogram.([\sine, \noise, \buildUp][index/3.floor.asInteger])?"")[index%3]));
			};

			current_message[6..8].do{|item, index|
				item.string_(show.(([0,1,2].includes((~histogram.(\buildUp)?"")[index%3])).if({~partialCount},{""})));
			};

			current_message[9..14].do{|item, index|
				item.string_(show.((~histogram.([\sample, \sampleFull][index/3.floor.asInteger])?"")[index%3]));
			};

			waitTime_array.do{|item, index| item.string_(
				getValuesForKey.([\sine, \noise, \buildUp, \sample, \sampleFull][(index/3).floor.asInteger], \waitTime, index%3).join)};

			target_array.do{|item, index| item.string_(
				getValuesForKey.([\sine, \noise, \buildUp, \sample, \sampleFull][(index/3).floor.asInteger], \nextTarget, index%3).join)};

			feature_array[9..14].do{|item, index| item.string_(
				getValuesForKey.([\sample, \sampleFull][(index/3).floor.asInteger], \feature, index%3).join);
			};

			// join the line break with the first "chatSentencesCount" count of chat

			chatTextField.string_((~chat?[])[
				(~chat.size -chatSentencesCount - 1)..(~chat.size - 1)
			].join("\n"));

		}.defer;
		0.15.wait;
	}
}.fork;

Routine {
	while { runBraid } {
		var v = ~braidBus.getnSynchronous(3);

		if((w.isClosed.not)&&(~braidisInitialized)) {
			w.drawFunc = {
				Pen.use {
					Pen.width = 1.1;
					Pen.color = Color.white;

					pathBraid = pathBraid ++ [v];
					// Keep the last X items so it fit into the screen
					pathBraid = pathBraid.keep(
						(-1/scale*(width-(2*indentBraid))).asInteger
					);

					3.do {|i|
						Pen.beginPath;
						pathBraid.collect({|p, q|
							Pen.moveTo(
								Point(
									indentBraid + (q*movingSpeed),
									pathBraid[q][i].linlin(50, 10500, 0.9*height, 0.07*height)
								)
							);
							Pen.lineTo(
								Point(
									indentBraid*1.075 + (q*movingSpeed),
									pathBraid[q][i].linlin(50, 10500, 0.9*height, 0.07*height)
								)
							);
							Pen.stroke;
						})
					};
				};
			};
		};
		w.refresh;
		(1/20).wait;
	}
}.play(AppClock);

CmdPeriod.doOnce({ w.close });
w.onClose_({ r.stop; runBraid = false;});
)


//just in case
// w.close