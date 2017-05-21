s.boot;
(
~csv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/trial.csv").post;
~data=~csv.flop;
)
///////////////////////////////////////////////////////////////////////Communication
(
~masteramp=0.2;
~timedelta=1;
~communication=~data.at(1).normalize(200, 800);
~communicationimp=~data.at(1).normalize(0, 8);
~communicationamp=~data.at(1).normalize(0, 0.08);
~entertainment=~data.at(3).normalize(1, 8);
~entertainmentamp=~data.at(3).normalize(0, 0.2);
~news=~data.at(4).normalize(100, 200);
~newsmul=~data.at(4).normalize(0.1, 6);
~newsamp=~data.at(4).normalize(0, 1.8);
~reference=~data.at(5).normalize(200, 1200);
~referenceamp=~data.at(5).normalize(0, 2.2);
~software=~data.at(8).normalize(10, 100);
~softwarespeed=~data.at(8).normalize(0.001, 1);
~softwareamp=~data.at(8).normalize(0, 0.2);
)

(
SynthDef(\communication, {|freq=900, imp=4, mul=0.4, add=0, amp=0.2, out=0, pan=0, rate=3, dur=0.1, gate=1|
	var env, env2, src;
	env = EnvGen.kr(Env.asr(0.1, 1, 1), gate);
	src=DynKlank.ar(`[[freq!4], [0.1, 0.4]], Impulse.ar(imp), decayscale:0.5);
	src=GrainIn.ar(1, Impulse.ar(freq), dur, src, pan);
	src=LPF.ar(src, 200);
	src=Pan2.ar(src*env, pan);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\entertainment, {
	|
	freq=8, out=0, arousal=100, arousalvol=0.2, buf =2, amp=0.3, pan=0, rate=0.1 t_trig =1
	|
	var src, brush, hat, thud, env, tempo, value;
	tempo = Impulse.ar(freq);
	env=EnvGen.ar(Env([1, 1], [2, 2]));
	brush = BrownNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 8, 1), 0.005, 0.5));
	hat= Mix.ar([WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5))*SinOsc.ar(400)]);
	src=Pan2.ar((brush + hat)*amp*env, pan);
	Out.ar(out, src);
}).add;

SynthDef(\news, {|freq=400, car=400, amp=30, pan=0, out=0, mul=1, mod=3, rcalmul=0.2, rcalroom=0.8, gate=1|
	var src, env;
	env = EnvGen.kr(Env.asr(0.1, 1, 1), gate);
	src=PMOsc.ar(freq, car, SinOsc.kr(0.01).range(0.1, 30))*SinOsc.kr(mul);
	src=BPF.ar(src, freq, rcalmul);
	src=FreeVerb.ar(src, 0.3, rcalroom);
	src=Pan2.ar(src, pan);
	Out.ar(out, src*env*amp*~masteramp);
}).add;

SynthDef(\reference, {
	|
	freq=900, mul=0.4, add=0, amp=20, out=0, pan=0, rate=3, dur=0.1, gate=1
	|
	var env, env2, src;
	 env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=DynKlank.ar(`[[freq!4], [1, 0.4]], Impulse.ar(4), decayscale:0.5);
	src=GrainIn.ar(1, Impulse.ar(6), dur, src, pan);
	src=LPF.ar(src, 100);
	src=Pan2.ar(src*env, pan);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\software, {
	|
	freq=100, trig=10, pan=0, out=0,  amp=0.8, decay=7, t_gate=1, gate=1, speed=0.1
	|
	var src, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=SinOsc.ar(Stepper.ar(Impulse.ar(freq), 1, 4, 10, 4)*SinOsc.kr(0.1, 0, 50, 100))*LFTri.ar(2);
	src=Decay2.ar(src, 0.03, decay);
	src=Pan2.ar(src, pan);
	Out.ar(out, src*env*amp)
}).add;
)

(
~workTask=Task({|i|
	~timestep1Synth= Synth(\communication, [\freq, ~communication.at(1), \gate, ~communication.at(1), \imp, ~communicationimp.at(1), \amp, ~communicationamp]);
	~timestep3Synth= Synth(\entertainment, [\freq, ~entertainment.at(3), \gate, ~entertainment.at(3), \amp, ~entertainmentamp.at(3)]);
	~timestep4Synth= Synth(\news, [\freq, ~news.at(4), \mul, ~newsmul.at(4), \amp, ~newsamp.at(4)]);
    ~timestep5Synth= Synth(\reference, [\freq, ~reference.at(5), \amp, ~referenceamp.at(5)]);
	~timestep8Synth= Synth(\software, [\freq, ~software.at(8), \amp, ~softwareamp.at(8), ~softwarespeed.at(8)]);
	inf.do({arg item, i;
		var freq0, freq1, freq2, freq3, freq4, freq5, freq6, freq7, freq8, freq9, amp, imp, comamp, comimp, eamp,  newsamp, newsmul, refamp, softamp, softspeed;
		freq1 = ~communication.at(i);
		comamp= ~communicationamp.at(i);
		comimp = ~communicationimp.at(i);
		freq2 = ~entertainment.at(i);
		eamp = ~entertainmentamp.at(i);
		freq4 = ~news.at(i);
		newsmul = ~newsmul.at(i);
		newsamp = ~newsamp.at(i);
		freq5 = ~reference.at(i);
		refamp = ~referenceamp.at(i);
		freq8 = ~software.at(i);
		softamp = ~softwareamp.at(i);
		softspeed = ~softwarespeed.at(i);
		~timestep1Synth.set(\freq, freq1, \gate, freq1, \amp, comamp, \imp, comimp);
		~timestep3Synth.set(\freq, freq2, \gate, freq2, \amp, eamp);
		~timestep4Synth.set(\freq, freq4, \mul, newsmul, \amp, newsamp);
		~timestep5Synth.set(\freq, freq5, \amp, refamp);
		~timestep8Synth.set(\freq, freq8, \gate, freq8, \amp, softamp, \speed, softspeed);
		~timedelta.wait;
	});
});
)

(
~workTask.play;
s.record("/Users/mbk5020/Desktop/onehundreddaysTask.aiff");
)
'
