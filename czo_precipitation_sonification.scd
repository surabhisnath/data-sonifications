(
~csv=CSVFileReader.readInterpret("/Users/mtssuser/Desktop/assistantship/2011sgp.csv").post;
~data=~csv.flop;
~masteramp=2;
)

 ////////////////////////////////////////////////////Data
(
~timedelta=1;
~close = ~data.at(2).normalize(0.001, 0.4);
~far = ~data.at(2).normalize(0.001, 0.4);
~gate = ~data.at(2).abs;
~pan = ~data.at(2).normalize(-1, 0.8);
~amp = ~data.at(2).normalize(0.01, 1.5);
)

/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\thunder, {|amp=4, gate=1, pan=0, low=200, high=2500|
	var src, env, env2;
	env=EnvGen.kr(Env.asr(0.01, 1, 10), gate);
	env2=EnvGen.kr(Env.perc(0.01, 20), gate);
	src=PinkNoise.ar(LFNoise1.kr(0.5))*env2;
	src=HPF.ar(src, 20);
	src=LPF.ar(src,LFNoise1.kr(1).exprange(200, 2500));
	src=GVerb.ar(src, 250, 30, 0.7, drylevel:0.3);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp);
}).add;

SynthDef(\rain, {|close=0.01, far=0.4, drips=0.2, amp=1, gate=1, pan=0|
	var src, src2, env, env2;
	env=EnvGen.kr(Env.asr(0.01, 1), gate);
	env2=EnvGen.kr(Env.perc(0.01, 2), gate);
	src=PinkNoise.ar(far, LFNoise1.kr(0.3, 0.02))*env2;
	src2=LPF.ar(Dust2.ar(LFNoise1.kr(close).range(30, 70)), 7000);
	src=HPF.ar(src+src2, 500);
	src=GVerb.ar(src, 250, 0.25, drylevel:0.3);
	src=Limiter.ar(src);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp);
}).add;
)

///////////////////////////////////////////////////////////////////////Task
(
~preciptask=Task({|i|
	~precipSynth= Synth(\thunder, [\gate, ~gate.at(2), \pan, ~pan.at(2), \amp, ~amp.at(2)]);
	~rainSynth= Synth(\rain, [ \close, ~close.at(2), \far, ~far.at(2), \gate, ~gate.at(2), \pan, ~pan.at(2), \amp, ~amp.at(2)]);
	inf.do({arg item, i;
		var closeprecip, farprecip, gateprecip,ampprecip, panprecip;
		closeprecip=~close.at(i);
		farprecip=~far.at(i);
		gateprecip= ~gate.at(i).postln;
		ampprecip= ~amp.at(i);
		panprecip= ~pan.at(i);
		~precipSynth.set(\gate, gateprecip);
		~precipSynth.set(\amp, ampprecip);
		~precipSynth.set(\pan, panprecip);
		~rainSynth.set(\close, closeprecip);
		~rainSynth.set(\far, farprecip);
		~rainSynth.set(\gate, gateprecip);
		~rainSynth.set(\amp, ampprecip);
		~rainSynth.set(\pan, panprecip);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~preciptask.play;
s.record;
)