(
var scale = 0.75; //1.5 for full HD
var width = 1280 * scale;
var height = 720 * scale;
var line1, line2, line3;
var line1_algo1, line2_algo1, line3_algo1;
var line1_algo2, line2_algo2, line3_algo2;
var line_chat1, line_chat2, line_chat3, line_chat4, line_chat5;

var indent = 0.03125 * width;
var indentChat = 0.4 * width;
var posY = -0.375 * height;
var algo_space = 0.04 * height;
var lineSpace = 0.17 * height;
var chatPosY = 0.3 * height;
var chatLineSpace = 0.025 * height;

var runBraid = true;//braid
var indentBraid = 0.015 * width;
var pathBraid = [];
var movingSpeed = 1 * scale;
var drawWidth = 0.1;

// Get the display value for the chain and a key
// for example: getValuesForKey.(\slow, \waitTime)
//  -> ["{1}", "", "{rrand(0.2, 0.5}"]
var getValuesForKey = {|chain, key|
	(0..2).collect({|index|
		try { ~userChainVisualConfigs[index][chain][key] } { |error|
			""
		};
	})
};


~lineshow = {|items, space|
	if(items.isNil,{
		"";
	},{
		items.collect({|i| i = i.asString++(" "!space).join}).join;
	})
};
~lineshowBuild = {|items, space|
	if(items.isNil,{
		"";
	},{ ~partialCount })
};

w = Window.new(name:"[ _  _  _ ]", bounds:Rect(0, 0, width, height));
w.view.background = Color.black;

line1 = StaticText.new(w, Rect(indent, posY + (0*lineSpace), width, height)).font_(Font("sansSerif",32 * scale)).stringColor_(Color.white);
line2 = StaticText.new(w, Rect(indent, posY + (1*lineSpace), width, height)).font_(Font("sansSerif",20 * scale)).stringColor_(Color.white);//fromHexString("#0600FF");
line3 = StaticText.new(w, Rect(indent, posY + (2*lineSpace), width, height)).font_(Font("sansSerif",20 * scale)).stringColor_(Color.red);

line1_algo1 = StaticText.new(w, Rect(indent, posY + algo_space + (0*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));
line2_algo1 = StaticText.new(w, Rect(indent, posY + algo_space + (1*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));
line3_algo1 = StaticText.new(w, Rect(indent, posY + algo_space + (2*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));

line1_algo2 = StaticText.new(w, Rect(indent, posY + (2 * algo_space) + (0*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));
line2_algo2 = StaticText.new(w, Rect(indent, posY + (2 * algo_space) + (1*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));
line3_algo2 = StaticText.new(w, Rect(indent, posY + (2 * algo_space) + (2*lineSpace), width, height)).font_(Font("sansSerif",10 * scale));

line_chat1 = StaticText.new(w, Rect(indentChat, chatPosY + (0 * chatLineSpace), width, height)).font_(Font("courier", 12 * scale));
line_chat2 = StaticText.new(w, Rect(indentChat, chatPosY + (1 * chatLineSpace), width, height)).font_(Font("courier", 12 * scale));
line_chat3 = StaticText.new(w, Rect(indentChat, chatPosY + (2 * chatLineSpace), width, height)).font_(Font("courier", 12 * scale));
line_chat4 = StaticText.new(w, Rect(indentChat, chatPosY + (3 * chatLineSpace), width, height)).font_(Font("courier", 12 * scale));
line_chat5 = StaticText.new(w, Rect(indentChat, chatPosY + (4 * chatLineSpace), width, height)).font_(Font("courier", 12 * scale));


w.front;
r = {
	inf.do { |i|
		{
			line1.string_(~lineshow.value(~histogram.value(\fast), 55));
			line2.string_(~lineshow.value(~histogram.value(\slow), 88));
			line3.string_(~lineshowBuild.value(~histogram.value(\buildUp), 88));

			line1_algo1.string_(
				~lineshow.(getValuesForKey.(\fast, \waitTime), 128)
			).stringColor_(Color.gray);

			line2_algo1.string_(
				~lineshow.(getValuesForKey.(\slow, \waitTime), 128)
			).stringColor_(Color.gray);

			line3_algo1.string_(
				~lineshow.(getValuesForKey.(\buildUp, \waitTime), 128)
			).stringColor_(Color.gray);

			line1_algo2.string_(
				~lineshow.(getValuesForKey.(\fast, \nextTarget), 108)
			).stringColor_(Color.gray);

			line2_algo2.string_(
				~lineshow.(getValuesForKey.(\slow, \nextTarget), 108)
			).stringColor_(Color.gray);

			line3_algo2.string_(
				~lineshow.(getValuesForKey.(\buildUp, \nextTarget), 108)
			).stringColor_(Color.gray);

			line_chat1.string_(~chat.reverse[4]?"").stringColor_(Color.white);
			line_chat2.string_(~chat.reverse[3]?"").stringColor_(Color.white);
			line_chat3.string_(~chat.reverse[2]?"").stringColor_(Color.white);
			line_chat4.string_(~chat.reverse[1]?"").stringColor_(Color.white);
			line_chat5.string_(~chat.reverse[0]?"").stringColor_(Color.white);

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


//
// (~histogram.value(\buildUp).isNil).if({""},{~histogram.value(\buildUp).collect({|i|
// 	((i == 0)||(i == 1)||(i == 2)).if({i = ~partialCount});
// 	i = i.asString++(" "!88).join;
// }).join})
