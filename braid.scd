(
var w, run = true;
w = Window("braid", Rect(128, 64, 800, 500));
w.view.background = Color.black;
w.onClose = { run = false; };
w.front;
s.waitForBoot({

	b = Bus.new(\control, 0, 3);

	q = SynthDef(\Docs_FreqMonitor, {
		var freq, snd1, snd2, snd3, freq1, freq2, freq3;
		freq = LFNoise0.ar([0.2,0.3,0.5], 50, 440);
		snd1 = SinOsc.ar(freq[0].lag(10), 0, 0.2);
		snd2 = SinOsc.ar(freq[1].lag(10), 0, 0.2);
		snd3 = SinOsc.ar(freq[2].lag(10), 0, 0.2);

		freq1 = Pitch.kr(snd1);
		freq2 = Pitch.kr(snd2);
		freq3 = Pitch.kr(snd3);

		Out.ar(0, Splay.ar(Pan2.ar([snd1,snd2,snd3],[-1,0,1],1),1));
		Out.kr(b.index, [freq1[0],freq2[0],freq3[0]]);
	}).play;

	r = Routine {
		1000.do{|j|
			b.get({ |v|
				{
					if(w.isClosed.not) {
						w.drawFunc = {
							Pen.use {
								Pen.width = 2;
								Pen.color = Color.white;
								3.do {|i|
									Pen.width = 1;
									Pen.beginPath;
									Pen.moveTo(Point(50+j, v[i].linlin(300,500,300,0)));
									Pen.lineTo(Point(52+j, v[i].linlin(300,500,300,0)));
									Pen.stroke;
								};
							};
						};
					}
				}.defer
			});
			0.1.wait;
			{ while { run } { w.refresh; 0.1.wait } }.fork(AppClock);
		}

	}.play;
}))

