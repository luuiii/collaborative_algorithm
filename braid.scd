(
var w, run = true;
~path = [];
w = Window("braid", Rect(200, 300, 1020, 300));
w.view.background = Color.black;
w.onClose = { run = false; };
w.front;
s.waitForBoot({

	b = Bus.new(\control, 0, 3);

	q = SynthDef(\Docs_FreqMonitor, {
		var freq, snd1, snd2, snd3, freq1, freq2, freq3;
		freq = LFNoise1.ar([0.31,0.33,0.35], 70, 440/*+SinOsc.kr(0.01,pi/2,50,50)*/);
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
								Pen.width = 0.01;
								Pen.color = Color.white;
								~path = ~path++[v];
								3.do {|i|
									Pen.width = 1;
									Pen.beginPath;
									~path.collect({|p,q|
										Pen.moveTo(Point(20+(q/3.5), ~path[q][i].linlin(300,600,200,120)));
										Pen.lineTo(Point(20.5+(q/3.5), ~path[q][i].linlin(300,600,200,120)));
										Pen.stroke;})
								};
							};
						};
					}
				}.defer
			});
			0.08.wait;
			{ while { run } { w.refresh; 0.08.wait } }.fork(AppClock);
		}

	}.play;
}))