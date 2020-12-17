(
var width = 1280;
var height = 150;
w = Window.new(name:"numbers", bounds:Rect(0, 620, width, height),border:false);
w.view.background = Color.gray;
a = CompositeView.new(w,Rect(0,0,width,height));
a.background= Color.black;
b = StaticText.new(w,Rect(0,-10,width,height)).string_(3);
c = StaticText.new(w,Rect(0,35,width,height)).string_(3);
b.stringColor = Color.white;
c.stringColor = Color.red;
b.align_(\center);
c.align_(\center);

b.font = Font("sansSerif",32);
c.font = Font("sansSerif",20);


w.front;
r = {
    inf.do { |i|
        thisThread.randSeed_(1284);
		{
			b.string_(~histogram.value(\slow).collect({|i| i = i.asString++(" "!35).join}).join);
			c.string_(~histogram.value(\fast).collect({|i| i = i.asString++(" "!56).join}).join);
		}.defer;
		0.15.wait;
    }
}.fork;
CmdPeriod.doOnce({ w.close });
w.onClose_({ r.stop });
)
s.plotTree
~histogram.value(\slow)


Window.closeAll

1.linlin(1,3,2,6);


GrainBuf