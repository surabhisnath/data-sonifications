////////////////////////////////////////////////This is done////////////////////////////////////////////////////////

(
//burger
~burgercsv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/ForeignAffairs/groundbeefcheesebacon2.csv").post;
~burgerdata=~burgercsv.flop;
)



 ////////////////////////////////////////////////////Data
(
~masteramp=2;
~timedelta=0.15;
~bacon = ~burgerdata.at(0).normalize(0.1, 2);
~sizzle = ~burgerdata.at(0).normalize(1, 600);
~sizzlepitch = ~burgerdata.at(0).normalize(100, 2000);
~beef = ~burgerdata.at(2).normalize(0.1, 6);
~cheese = ~burgerdata.at(1).normalize(2, 10);
)

/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\bacon, {|bacon=0.1, sizzle=100, sizzlepitch=100 amp=200, pan=0, out=0, gate=1|
	var  src, env;
	env=EnvGen.kr(Env.asr(0.01, 0.1), gate, doneAction:2);
	src=WhiteNoise.ar(bacon);
	src=LPF.ar(src, sizzlepitch);
	src=src*Dust.ar(sizzle);
	src=Pan2.ar(src, pan);
	src=Out.ar(out, src*env*amp*~masteramp);
}).add;


SynthDef(\beef, { |beef=1, out=0, gate=1, amp=0.6|
	var src, env1, env2;
	env1 = EnvGen.kr(Env.perc(0.1, 1), Impulse.kr(beef));
	env2 = EnvGen.kr(Env.perc(0, 0.01), Impulse.kr(beef));
	src = Array.fill(10, WhiteNoise.ar*env2);
	src = FreeVerb.ar(src, 0.8, 0.1, 0.2);
	src=Pan2.ar(src, 0, env1*amp*~masterAmp);
	Out.ar(out, src);
}).add;


SynthDef(\cheese, {| gate=1, amp=50, pan=0, mul=0.005, rq=0.03, pitch1=500, pitch2=800, lpf1=14, lpf2=10, cheese=6, noise2=6, bubble1=1, bubble2=1, delay=0.002|
	var src, src2, out, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=OneZero.ar(Impulse.ar(cheese), 0.99);
	src=RHPF.ar(src, LPF.ar(BrownNoise.ar(bubble1), lpf1)*600 + pitch1, rq, mul);
	src2=OneZero.ar(Impulse.ar(cheese), 0.99);
	src2=DelayL.ar(RHPF.ar(src2, LPF.ar(BrownNoise.ar(bubble2), lpf2)*600 + pitch2, rq, mul), 0.2, delay);
	out=Mix.ar([src, src2]);
	out=GVerb.ar(out, 20, 3, drylevel:0.01);
	out=Pan2.ar(src+src2, pan);
	Out.ar(0, out*env*amp*~masteramp)
}).add;
)



///////////////////////////////////////////////////////////////////////Task
(
~burgertask=Task({|i|
	~baconSynth= Synth(\bacon, [
		\bacon, ~bacon.at(0),
		\sizzle, ~sizzle.at(0),
		\sizzlepitch, ~sizzlepitch.at(0)
	]);
	~beefSynth= Synth(\beef, [
		\beef, ~beef.at(1),
	]);
	~cheeseSynth= Synth(\cheese, [
		\cheese, ~cheese.at(2),
	]);

	inf.do({arg item, i;
		var beef, sizzle, sizzlepitch, cheese, bacon;
	    bacon = ~bacon.at(i).postln;
		sizzle= ~sizzle.at(i);
		sizzlepitch= ~sizzlepitch.at(i);
		beef= ~beef.at(i);
	    cheese = ~cheese.at(i);

		~baconSynth.set(\bacon, bacon);
		~beefSynth.set(\sizzle, sizzle);
		~beefSynth.set(\sizzlepitch, sizzlepitch);
		~beefSynth.set(\beef, beef);
		~cheeseSynth.set(\cheese, cheese);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~burgertask.play;
s.record("/Users/mbk5020/Desktop/burgersynth.wav");
)