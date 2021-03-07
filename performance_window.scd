(
var scale = 1; //1.5 for full HD
var width = 1280 * scale;
var height = 720 * scale;

var indent_lmr = 0.25;
var leftshift = 100;
var box_width = 0.21 * width;
var left = width * (0.5 - indent_lmr) - leftshift;
var mid = width * 0.5 - leftshift;
var right = width * (0.5 + indent_lmr) - leftshift;

var line_space = 0.2 * height;
var algo_space = 0.07 * height;

var line = [];
var waitTime_array = [];
var target_array = [];
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
var chatSentencesCount = 8;

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

line = Array.fill(9,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.75*box_width), 1.07*posY + ((i/3).floor*line_space), box_width, height)).font_(Font("Helvetica Neue",4.5*[32,32,5][(i/3).floor.asInteger] * scale,[0,1,0][(i/3).floor.asInteger].asBoolean,[0,1,0][(i/3).floor.asInteger].asBoolean)).stringColor_([Color.white,Color.white,Color.fromHexString("E93000")][(i/3).floor.asInteger]).align_(\center);});

waitTime_array = Array.fill(6,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.5*box_width), posY + algo_space + ((i/3).floor*line_space), box_width, height)).font_(Font("menlo",17 * scale)).align_(\center)});

target_array = Array.fill(6,{|i| StaticText.new(w, Rect([left, mid, right][i%3]-(0.5*box_width), posY + (2 * algo_space) + ((i/3).floor*line_space), box_width, height)).font_(Font("menlo",17 * scale)).align_(\center)});

chatTextField = StaticText.new(
	w, Rect(chat_indent, chat_posY, chatSectionWidth, height*0.395)
).font_(Font("menlo", 16 * scale)).align_(\bottomLeft).stringColor_(Color.gray);


w.front;
r = {
	inf.do { |i|
		{
			line[..5].do{|item, index|
				item.string_(show.((~histogram.([\sine, \noise, \buildUp][index/3.floor.asInteger])?"")[index%3]));
			};
			line[6..8].do{|item, index|
				item.string_(show.(([0,1,2].includes((~histogram.(\buildUp)?"")[index%3])).if({~partialCount},{""})));
			};
			waitTime_array.do{|item, index| item.string_(
				getValuesForKey.([\sine, \noise, \buildUp][(index/3).floor.asInteger], \waitTime, index%3).join).stringColor_(Color.gray)};

			target_array.do{|item, index| item.string_(
				getValuesForKey.([\sine, \noise, \buildUp][(index/3).floor.asInteger], \nextTarget, index%3).join).stringColor_(Color.gray)};

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
					Pen.width = 2.5;
					Pen.color = Color.white;

					pathBraid = pathBraid ++ [v];
					pathBraid = pathBraid.keep(-1*(width-(2*indentBraid)).asInteger);
					3.do {|i|
						Pen.beginPath;
						pathBraid.collect({|p, q|
							Pen.moveTo(
								Point(
									indentBraid + (q*movingSpeed),
									pathBraid[q][i].linlin(50, 1700, 0.9*height, 0.07*height)
								)
							);
							Pen.lineTo(
								Point(
									indentBraid*1.025 + (q*movingSpeed),
									pathBraid[q][i].linlin(50, 1700, 0.9*height, 0.07*height)
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
w.close



// (~histogram.value(\buildUp).isNil).if({""},{~histogram.value(\buildUp).collect({|i|
// 	((i == 0)||(i == 1)||(i == 2)).if({i = ~partialCount});
// 	i = i.asString++(" "!88).join;
// }).join})
// ~userChainVisualConfigs
