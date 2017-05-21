(
~csv=CSVFileReader.readInterpret("/Users/mtssuser/Desktop/assistantship/2011sgp.csv").post;
~data=~csv.flop;
~masteramp=2;
)


 ////////////////////////////////////////////////////Data
(
~timedelta=1;
~bubble1 = ~data.at(0).normalize(0.001, 1);
~bubble2 = ~data.at(0).normalize(0.001, 1);
~pitch = ~data.at(0).normalize(350, 1200);
~pan = ~data.at(0).normalize(-1, 1);
~noise1 = ~data.at(0).normalize(0.8, 1);
~noise2 = ~data.at(0).normalize(0.8, 1);
~delay = ~data.at(0).normalize(0.0002, 0.2);
~lpf1 = ~data.at(0).normalize(0.001, 30);
~lpf2 = ~data.at(0).normalize(0.001, 30);
~amp =~data.at(0).normalize(8, 1);
~coef= ~data.at(0).normalize(1, 0.8)
)


/////////////////////////////////////////////////////////////////////Synth

(
SynthDef(\streamwater, {|freq=100, speed= 20 gate=1, amp=10, pan=0, mul=0.005, rq=0.03, pitch1=500, pitch2=800, lpf1=14, lpf2=30, noise1=1, noise2=1, bubble1=1, bubble2, coef=0.99|
	var src, src2, out, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=OnePole.ar(BrownNoise.ar(noise1), coef);
	src=RHPF.ar(src, LPF.ar(BrownNoise.ar(bubble1), lpf1)*pitch1 + 500, rq, mul);
	src2=OnePole.ar(BrownNoise.ar(noise2), coef);
	src2=RHPF.ar(src2, LPF.ar(BrownNoise.ar(bubble2), lpf2)*pitch2 + 1000, rq, mul);
	out=Mix.ar([src, src2]);
	out=GVerb.ar(out, 50, 0.4);
	out=Pan2.ar(src+src2, pan);
	Out.ar(0, out*env*amp*~masteramp)
}).add;
)
s.record;
Synth(\streamwater);
///////////////////////////////////////////////////////////////////////Task
(
~streamwatertask=Task({|i|
	~streamSynth= Synth(\streamwater, [
		\bubble1, ~bubble1.at(0),
		\bubble2, ~bubble2.at(0),
		\pitch1, ~pitch.at(0),
		\pitch2, ~pitch.at(0),
		\pan, ~pan.at(0),
		\noise1, ~noise1.at(0),
		\noise2, ~noise2.at(0),
		\delay, ~delay.at(0),
		\lpf1, ~lpf1.at(0),
		\lpf2, ~lpf2.at(0),
		\amp, ~amp.at(0),
		\coef, ~coef.at(0)
	]);
	inf.do({arg item, i;
		var bubble1stream, bubble2stream, pitch1stream, pitch2stream, panstream, noise1stream, noise2stream, ampstream, lpf1stream, lpf2stream, coefstream;
		bubble1stream= ~bubble1.at(i);
		bubble1stream= ~bubble2.at(i);
		pitch1stream=~pitch.at(i);
		pitch2stream=~pitch.at(i);
		panstream=~pan.at(i);
		noise1stream= ~noise1.at(i).postln;
		noise2stream= ~noise2.at(i);
		lpf1stream = ~lpf1.at(i);
		lpf2stream = ~lpf2.at(i);
		ampstream= ~amp.at(i);
		coefstream= ~coef.at(i);
		~streamSynth.set(\bubble1, bubble1stream);
		~streamSynth.set(\bubble2, bubble2stream);
		~streamSynth.set(\pitch1, pitch1stream);
		~streamSynth.set(\pitch2, pitch2stream);
		~streamSynth.set(\pan, panstream);
		~streamSynth.set(\noise1, noise1stream);
		~streamSynth.set(\noise2, noise2stream);
		~streamSynth.set(\lpf1, lpf1stream);
		~streamSynth.set(\lpf2, lpf2stream);
		~streamSynth.set(\amp, ampstream);
		~streamSynth.set(\coef, coefstream);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~streamwatertask.play;
s.record;
)