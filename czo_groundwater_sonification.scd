(
~csv=CSVFileReader.readInterpret("/Users/mtssuser/Desktop/assistantship/2011sgp.csv").post;
~data=~csv.flop;
~masteramp=4;
)

speed-water on the ground to movement;
percipiation-too repetative;
mix in precipitation data-intesnity;
min and max= min()....keep from clipping- use minimum
reduce clipping;
tutorial sounds 5 seconds;

 ////////////////////////////////////////////////////Data
(
~timedelta=1;
~bubble1g = ~data.at(1).normalize(0, 1);
~bubble2g = ~data.at(1).normalize(0, 1);
~pitchg = ~data.at(1).normalize(600, 2500);
~pang = ~data.at(1).normalize(-1, 1);
~noise1g = ~data.at(1).normalize(1, 4);
~noise2g = ~data.at(1).normalize(1, 4);
~delayg = ~data.at(1).normalize(0.02, 1);
~ampg =~data.at(1).normalize(40, 60)
)
/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\groundwater, {| gate=1, amp=40, pan=0, mul=0.005, rq=0.03, pitch1=500, pitch2=800, lpf1=14, lpf2=30, noise1=1, noise2=1, bubble1=1, bubble2=1, delay=0.002|
	var src, src2, out, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=OneZero.ar(Impulse.ar(noise1), 0.99);
	src=RHPF.ar(src, LPF.ar(BrownNoise.ar(bubble1), lpf1)*600 + pitch1, rq, mul);
	src2=OneZero.ar(Impulse.ar(noise2), 0.99);
	src2=DelayL.ar(RHPF.ar(src2, LPF.ar(BrownNoise.ar(bubble2), lpf2)*600 + pitch2, rq, mul), 0.2, delay);
	out=Mix.ar([src, src2]);
	out=GVerb.ar(out, 20, 3, drylevel:0.01);
	out=Pan2.ar(src+src2, pan);
	Out.ar(0, out*env*amp*~masteramp)
}).add;
)

s.record;
Synth(\groundwater);
///////////////////////////////////////////////////////////////////////Task
(
~groundtask=Task({|i|
	~groundSynth= Synth(\groundwater, [
		\bubble1, ~bubble1g.at(0),
		\bubble2, ~bubble2g.at(0),
		\pitch1, ~pitchg.at(0),
		\pitch2, ~pitchg.at(0),
		\pan, ~pang.at(0),
		\noise1, ~noise1g.at(0),
		\noise2, ~noise2g.at(0),
		\delay, ~delayg.at(0),
		\amp, ~ampg.at(0),
	]);
	inf.do({arg item, i;
		var bubble1ground, bubble2ground, pitch1ground, pitch2ground, panground, noise1ground, noise2ground, ampground, delayground;
		bubble1ground= ~bubble1g.at(i);
		bubble1ground= ~bubble2g.at(i);
		pitch1ground=~pitchg.at(i).postln;
		pitch2ground=~pitchg.at(i);
		panground=~pang.at(i);
		noise1ground= ~noise1g.at(i);
		noise2ground= ~noise2g.at(i);
		delayground= ~delayg.at(i);
		ampground= ~ampg.at(i);
		~groundSynth.set(\bubble1, bubble1ground);
		~groundSynth.set(\bubble2, bubble2ground);
		~groundSynth.set(\pitch1, pitch1ground);
		~groundSynth.set(\pitch2, pitch2ground);
		~groundSynth.set(\pan, panground);
		~groundSynth.set(\noise1, noise1ground);
		~groundSynth.set(\noise2, noise2ground);
		~groundSynth.set(\delay, delayground);
		~groundSynth.set(\amp, ampground);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
s.record;
~groundtask.play;
	)