
(
var w, run = true;
var path = [];
var movingSpeed = 1/7;
var drawWidth = 0.5;

w = Window("braid", Rect(200, 300, 1020, 300));
w.view.background = Color.black;
w.onClose = { run = false; };
w.front;

s.waitForBoot({
	r = Routine {
		30000.do{|j|
			~braidBus.get({ |v|
				{
					if(w.isClosed.not) {
						w.drawFunc = {
							Pen.use {
								Pen.width = drawWidth;
								Pen.color = Color.white;

								path = path ++ [v];

								3.do {|i|
									Pen.width = drawWidth;

									Pen.beginPath;

									path.collect({|p, q|
										Pen.moveTo(
											Point(
												20 + (q*movingSpeed),
												path[q][i].linlin(300, 600, 200, 120)
											)
										);

										Pen.lineTo(
											Point(
												20.5 + (q*movingSpeed),
												path[q][i].linlin(300, 600, 200, 120)
											)
										);

										Pen.stroke;
									})
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