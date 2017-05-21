s.boot;
~masteramp=1;
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/data2/inoc2r_51.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_2.csv").post;
~data=~csv.flop;
)

(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_3.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_4.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_6.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_7.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_8.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_9.csv").post;
~data=~csv.flop;
)
(
~csv=CSVFileReader.readInterpret("/Users/Bay/Desktop/inoc2r_10.csv").post;
~data=~csv.flop;
)
 ////////////////////////////////////////////////////Feelings
 //AGV
(
~timedelta = ~data.at(2).normalize(5);
~negD = ~data.at(3);
~negO = ~data.at(4);
~calmD = ~data.at(5);
~calmO = ~data.at(6);
)
/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\negd,  { |out=0, mul=0.4, amp=1, sustain=0.5, pan=0, gate=1|
	var src, env, env2;
	env = EnvGen.kr(Env.asr(0.01, 1, 1), gate);
	env2 = EnvGen.kr(Env.perc(0.01, 1), Impulse.kr(2));
	src= Impulse.ar(XLine.kr(120, 175, 0.2))*SinOsc.ar(1);
	Out.ar(out, Pan2.ar(src, pan, env*amp*~masteramp));
}).add;

SynthDef(\nego, { arg midi= 69, delayDecay = 1.0, gate=1, amp=1, pan=0, out=0;
	var burstEnv, att = 0, dec = 0.001;
	var src, delayTime, env, env2;
	env = EnvGen.kr(Env.perc(att, dec), Impulse.kr(Rand(1, 5)));
	env2 = EnvGen.kr(Env.asr(0.01, 1, 1), gate);
	delayTime = [[69, 72, 75, 77].choose, midi + 12].midicps.reciprocal;
	src = PinkNoise.ar(env);
	src = CombL.ar(src, delayTime, delayTime, delayDecay, add: src);
	Out.ar(out, Pan2.ar(src, pan, env2*amp*~masteramp));
	}
).add;

SynthDef(\calmd,   { |out=0, mul=0.4, dens=200, amp=0.1, sustain=0.5, pan=0, gate=1|
	var src, env;
	env = EnvGen.kr(Env.asr(0.01, 1, 1), gate);
	src = DynKlank.ar(`[[Rand(600, 800), Rand(800, 1000), Rand(1200, 1300)], [1, 1, 1]], Impulse.ar(Rand(2, 5)));
	Out.ar(out, Pan2.ar(src, pan, env*amp*~masteramp));
}).add;

SynthDef(\calmo, {|mul=0.6, bp=1300, gate=1, amp=5, impusle=20, pan=0|
	var src, env;
	env=EnvGen.kr(Env.asr(5, 20, 10), gate);
	src=WhiteNoise.ar(Impulse.ar(40));
	src=BPF.ar(src, bp, SinOsc.kr(0.01).range(0.001, 0.004));
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp);
}).add;
)

Synth(\negd);
Synth(\nego);
Synth(\calmd);
Synth(\calmo);

(
~inoc=Task({|i|
	~negDSynth= Synth(\negd, [\gate, ~negD.at(3)]);
	~negOSynth= Synth(\nego, [\gate, ~negO.at(4)]);
	~calmDSynth= Synth(\calmd, [\gate, ~calmD.at(5)]);
	~calmOSynth= Synth(\calmo, [\gate, ~calmO.at(6)]);
	inf.do({arg item, i;
		var gatenegD, gatenegO, gatecalmD, gatecalmO;
		gatenegD=~negD.at(i);
		gatenegO=~negO.at(i);
		gatecalmD=~calmD.at(i);
		gatecalmO=~calmO.at(i);
		~negDSynth.set(\gate, gatenegD);
		~negOSynth.set(\gate, gatenegO);
		~calmDSynth.set(\gate, gatecalmD);
		~calmOSynth.set(\gate, gatecalmO);
		~timedelta.at(i).wait;
	})
});
)

(
~inoc.play;
s.record;
)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SynthDef(\nego,  { |out=0, mul=0.5, amp=0.3, sustain=0.5, pan=0, gate=1|
	var src, env;
	env = EnvGen.kr(Env.asr(0.01, 1, 1), gate);
	src=Mix.ar(WhiteNoise.ar(mul), BrownNoise.ar(mul))*SinOsc.kr(8)*SinOsc.kr(0.3);
	Out.ar(out, Pan2.ar(src, pan, env*amp*~masteramp));
}).add;
(
SynthDef(\noise, {|impulse=50, freq=2000, time=12, gate=1, rq=0.0001, rate=0.1, amp=7, out=0|
	var src, env;
	env=EnvGen.kr(Env([0, 1, 0],[0.8, 60*time,0.8]), gate, doneAction:2);
	src=WhiteNoise.ar(0.3);
	src=BPF.ar(src, freq, rq);
	src=Pan4.ar(src, SinOsc.kr(rate, 3pi).range(-1, 1), SinOsc.kr(rate, 1pi).range(-1, 1));
	Out.ar(out, src*env*amp);
}).add;

SynthDef(\crackle, {|impulse=50, freq=200, time=12, gate=1, rq=0.001, rate=0.1, amp=7, out=0|
	var src, env;
	env=EnvGen.kr(Env([0, 1, 0],[0.8, 60*time,0.8]), gate, doneAction:2);
	src=Crackle.ar(1.6);
	src=Pan4.ar(src, -0.5, 1);
	Out.ar(out, src*env*amp);
}).add;



SynthDef(\dust, {|high=300, low=2, time=10, mul=0.5, out=0|
	var src;
	 src=Dust.ar(XLine.kr(high, low, time), mul);
	 src=Pan4.ar(src, Rand(-1, 1), Rand(-1, 1));
	Out.ar(out, src)
}).add;


SynthDef(\pat, {|mul=0.3, amp=0.4, pan=0, bp=150|
	var src, env;
	env=EnvGen.kr(Env.perc(0.1, 0.3), doneAction:2);
	src=WhiteNoise.ar(mul);
	src=Resonz.ar(src, 200);
	src=BPF.ar(src, bp);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\siz, {|mul=0.6, bp=1300, gate=1, amp=1, impusle=20, pan=0|
	var src, env;
	env=EnvGen.kr(Env.asr(5, 20, 10), gate);
	src=WhiteNoise.ar(Impulse.ar(1));
	src=BPF.ar(src, bp, SinOsc.kr(0.01).range(0.001, 0.004));
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp);
}).add;

Synth(\siz);

SynthDef(\pin, {|mul=0.6, pan=0, freq=1300, gate=1, amp=0.6, panx= -1, pany=1|
	var src, env, env2;
	env=EnvGen.kr(Env.asr(0.01, 2));
	env2 = EnvGen.kr(Env([800, 1100, 900], [1, 2, 1], loopNode:1));
	src=PinkNoise.ar(0.5);
	src=BPF.ar(src, env2, SinOsc.kr(0.01).range(0.001, 0.004));
	src=Pan2.ar(src, 0);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\chop, {
	|
	freq=300, impulse=8, mul=0.5, add=0, amp=0.6, out=0, pan=0, rate=3, gate=1, dur=0.1, bp=1300
	|
	var env, src;
	env=EnvGen.kr(Env.perc(0.01, 7), gate, doneAction:2);
	src=Mix([BrownNoise.ar(mul),WhiteNoise.ar(mul)]);
	src=GrainIn.ar(1, Impulse.ar(impulse), dur, src, pan);
	src=BPF.ar(src, bp, 0.02);
	src=Pan4.ar(src, Rand(1, -1), Rand(1, -1));
	Out.ar(0, src*env*amp);
}).add;


SynthDef(\grains, {
	|
	attack=5, sus=10, release=5, impulse=20, freq=0.2, modfreq=0.01 bp=2000, rq=0.001, dur=0.01, pan=0.2, mul=1, add=0, room=300, rev=5, numgrains=512, gate=1, amp=1
	 |
	var src, mod, trigger, env;
	env=EnvGen.kr(Env([0, 1, 0], [attack, sus, release]), gate, doneAction:2);
	trigger=Impulse.ar(impulse);
	src=WhiteNoise.ar(freq);
	mod=SinOsc.ar(modfreq);
	src=BPF.ar(src*mod, bp, rq);
	src=GrainIn.ar(2, trigger, dur, src, pan, -1, numgrains, mul, add);
	src=GVerb.ar(src, room, rev);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\grains2, {
	|
	impulse=150, freq=30, modfreq=0.01, dur=0.01, pan=2, mul=1, add=0, room=30, rev=5, numgrains=512, gate=1, amp=0.04
	 |
	var src, mod, trigger, env;
	env=EnvGen.kr(Env([0, 1, 1, 0], [5, 10, 10, 5]), gate, doneAction:2);
	trigger=Impulse.ar(impulse);
	src=SinOsc.ar(freq);
	mod=SinOsc.ar(modfreq);
	src=GrainIn.ar(2, trigger, dur, src, pan, -1, numgrains, mul, add);
	src=GVerb.ar(src, room, rev);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\dink, {|freq=600, amp=0.2, pan=0, gate=1|
	var env, src;
	env=EnvGen.kr(Env.perc(0.01, 0.2), gate, doneAction:2);
	src=SinOsc.ar(freq)*Impulse.ar(3);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env);
}).add;
)

Synth(\noise);
Synth(\crackle);
Synth(\pat);
Synth(\dust);
Synth(\siz);
Synth(\pin);
Synth(\chop);
Synth(\grains);
Synth(\grains2);
Synth(\dink);
