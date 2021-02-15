(
var scale = 1; //1.5 for full HD
var width = 1280 * scale;
var height = 720 * scale;

var indent_lmr = 0.35;
var left = width * (0.5 - indent_lmr);
var mid = width * 0.5;
var right = width * (0.5 + indent_lmr);

var line_space = 0.17 * height;
var algo_space = 0.04 * height;

var line = [];
var waitTime_array = [];
var target_array = [];
var chat_array = [];

var indent = 0.03125 * width;
var chat_indent = 0.4 * width;

var posY = -0.375 * height;

var chat_posY = 0.3 * height;
var chat_linespace = 0.025 * height;

var runBraid = true;//braid
var indentBraid = 0.015 * width;
var pathBraid = [];
var movingSpeed = 1 * scale;
var drawWidth = 0.1;

// Get the display value for the chain and a key
// for example: getValuesForKey.(\slow, \waitTime)
//  -> ["{1}", "", "{rrand(0.2, 0.5}"]
var getValuesForKey = {|chain, key, user|
	(user..user).collect({|index|
		try { ~userChainVisualConfigs[index][chain][key] } { |error|
			""
		};
	})
};

var getHistogram = {|item|
	try { (~histogram.value([\fast, \slow, \buildUp][item]).asString) } { |error|
		""
	};
};

var show = {|items|
	if(items.isNil,{
		"";
	},{
		items = items.asString;
	})
};

w = Window.new(name:"[ _  _  _ ]", bounds:Rect(0, 0, width, height));
w.view.background = Color.black;

line = Array.fill(9,{|i| StaticText.new(w, Rect([left, mid, right][i%3], posY + ((i/3).floor*line_space), width, height)).font_(Font("sansSerif",[32,20,20][(i/3).floor.asInt] * scale)).stringColor_([Color.white,Color.white,Color.red][(i/3).floor.asInt]);});

waitTime_array = Array.fill(9,{|i| StaticText.new(w, Rect([left, mid, right][i%3], posY + algo_space + ((i/3).floor*line_space), width, height)).font_(Font("sansSerif",10 * scale)).align_(\left)});

target_array = Array.fill(9,{|i| StaticText.new(w, Rect([left, mid, right][i%3], posY + (2 * algo_space) + ((i/3).floor*line_space), width, height)).font_(Font("sansSerif",10 * scale)).align_(\left)});

chat_array = Array.fill(5,{|i| StaticText.new(w, Rect(chat_indent, chat_posY + (i * chat_linespace), width, height)).font_(Font("courier", 12 * scale))};
);

w.front;
r = {
	inf.do { |i|
		{
			line.do{|item, index|
				item.string_(show.((~histogram.([\fast, \slow, \buildUp][index/3.floor.asInt])?"")[index%3]));
			};
			waitTime_array.do{|item, index| item.string_(
				getValuesForKey.([\fast, \slow, \buildUp][(index/3).floor.asInt], \waitTime, index%3).join).stringColor_(Color.gray)};

			target_array.do{|item, index| item.string_(
				getValuesForKey.([\fast, \slow, \buildUp][(index/3).floor.asInt], \nextTarget, index%3).join).stringColor_(Color.gray)};

			5.do{|i|
				chat_array[i].string_(~chat.reverse[4-i]?"").stringColor_(Color.white);
			};
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
						Pen.width = 1;
						Pen.color = Color.white;

						pathBraid = pathBraid ++ [v];
						pathBraid = pathBraid.keep(-1*(width-(2*indentBraid)).asInt);
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

w.close//just in case



// (~histogram.value(\buildUp).isNil).if({""},{~histogram.value(\buildUp).collect({|i|
// 	((i == 0)||(i == 1)||(i == 2)).if({i = ~partialCount});
// 	i = i.asString++(" "!88).join;
// }).join})
~userChainVisualConfigs
~histogram.(\fast)[2]