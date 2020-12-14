(
w = Window.new.front("numbers", Rect(0, 500, 128*2, 36*2));
w.view.background = Color.black;
CompositeView.new(w,Rect(5,5,256,60));
b = StaticText.new(w,Rect(5,5,256,40)).string_(~histogram.value);
b.stringColor = Color.white;
b.font = Font("sansSerif",20);
r = {
    inf.do { |i|
        thisThread.randSeed_(1284);
		{b.string_(~histogram.value)}.defer;
        0.15.wait;
    }
}.fork;
CmdPeriod.doOnce({ w.close });
w.onClose_({ r.stop });
)
