(
var width = 1280;
var height = 500;
var line1, line2, line3, line4, line5, line6, line7, line8, line9;

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

w = Window.new(name:"numbers", bounds:Rect(0, 300, width, height), border:false);
w.view.background = Color.black;

a = CompositeView.new(w,Rect(0,0,width,height));
a.background= Color.black;

line1 = StaticText.new(w,Rect(40,-200,width,height)).string_("fast");
line2 = StaticText.new(w,Rect(40,-155,width,height)).string_("slow");
line3 = StaticText.new(w,Rect(40,-125,width,height)).string_("buildup");

line4 = StaticText.new(w,Rect(500,-75,width,height)).string_(" ");
line5 = StaticText.new(w,Rect(500,-55,width,height)).string_(" ");
line6 = StaticText.new(w,Rect(500,-35,width,height)).string_(" ");
line7 = StaticText.new(w,Rect(500,-15,width,height)).string_(" ");
line8 = StaticText.new(w,Rect(500,5,width,height)).string_(" ");
line9 = StaticText.new(w,Rect(500,25,width,height)).string_(" ");

line1.stringColor = Color.white;
line2.stringColor = Color.red;
line3.stringColor = Color.white;
line4.stringColor = Color.white;
line5.stringColor = Color.white;
line6.stringColor = Color.white;
line7.stringColor = Color.white;
line8.stringColor = Color.white;
line9.stringColor = Color.white;

line1.align_(\left);
line2.align_(\left);
line3.align_(\left);
line4.align_(\left);
line5.align_(\left);
line6.align_(\left);
line7.align_(\left);
line8.align_(\left);
line9.align_(\left);

line1.font = Font("sansSerif",32);
line2.font = Font("sansSerif",20);
line3.font = Font("sansSerif",20);
line4.font = Font("courier", 12);
line5.font = Font("courier", 12);
line6.font = Font("courier", 12);
line7.font = Font("courier", 12);
line8.font = Font("courier", 12);
line9.font = Font("courier", 12);



w.front;
r = {
    inf.do { |i|
        thisThread.randSeed_(1284);
		{
			line1.string_(~lineshow.value(~histogram.value(\fast),55));
			line2.string_(~lineshow.value(~histogram.value(\slow),88));
			line3.string_(~lineshow.value(~histogram.value(\buildUp),88));
		//	line4.string_(~chat.reverse[5]);
			line5.string_(~chat.reverse[4]);
			line6.string_(~chat.reverse[3]);
			line7.string_(~chat.reverse[2]);
			line8.string_(~chat.reverse[1]);
			line9.string_(~chat.reverse[0]);

		}.defer;
		0.15.wait;
    }
}.fork;
CmdPeriod.doOnce({ w.close });
w.onClose_({ r.stop });
)

w.close


//
// (~histogram.value(\buildUp).isNil).if({""},{~histogram.value(\buildUp).collect({|i|
// 	((i == 0)||(i == 1)||(i == 2)).if({i = ~partialCount});
// 	i = i.asString++(" "!88).join;
// }).join})

