////////////////////////////////////////////////This is done////////////////////////////////////////////////////////

(
//truck sound
~masterAmp=4;
~cartruckcsv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/ForeignAffairs/carlighttruckcombined2.csv").post;
~cartruckdata=~cartruckcsv.flop;
)


 ////////////////////////////////////////////////////Data
(
~timedelta=1.2;
//truckdata
~car = ~cartruckdata.at(0).normalize(200, 400);
~cargate = ~cartruckdata.at(0).normalize(0.1, 8);
~truckfreq = ~cartruckdata.at(1).normalize(0.001, 1);
~truckamp = ~cartruckdata.at(1).normalize(0.4, 1);

)

/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\car, {|car=200, cargate=1, mul=0.3, amp=10, pan=0, bp=150, gate=1|
	var src, env;
	env=EnvGen.kr(Env.perc(0.1, 0.3), Impulse.kr(cargate));
	src=WhiteNoise.ar(mul);
	src=Resonz.ar(src, car);
	src=BPF.ar(src, bp);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp*~masterAmp);
}).add;


SynthDef(\truck, {|truckfreq=0.1, gate=1, truckamp=0.1, pan=0, amp=1|
	var jitterEngine, noise, bufferA, bufferB, fourstroke, engineSpeed, env;

	env=EnvGen.kr(Env.asr(0.1, 1), gate, doneAction:2);

	bufferA = LocalBuf(44100, 1);
	bufferB = LocalBuf(44100, 1);

    noise = WhiteNoise.ar;
	noise = OnePole.ar(noise, exp(-2pi * (20 * SampleDur.ir)));
	noise = OnePole.ar(noise, exp(-2pi * (20 * SampleDur.ir)));
	noise = DelTapWr.ar([bufferA, bufferB], [noise * 0.5, noise * 10]);

	fourstroke = DelTapRd.ar(bufferA, noise[0], [5, 10, 15, 20]/1000);
	fourstroke =
			LFSaw.ar(OnePole.ar((K2A.ar(truckfreq) * 40), exp(-2pi * (0.8 * SampleDur.ir))), 1, 0.5, 0.5)
		 	 + fourstroke
		 	 - [0.75, 0.5, 0.25, 0];
	fourstroke = (fourstroke * 2pi).cos;

	fourstroke =
			fourstroke
			* (DelTapRd.ar(bufferB, noise[1], [5, 10, 15, 20]/1000) + ((1 - truckfreq) * 15 + 7));
	fourstroke = 1 / ((fourstroke * fourstroke) + 1);
	fourstroke = fourstroke.sum!2 * 0.25;
	fourstroke = FreeVerb.ar(fourstroke, 0.3, 0.3);
	fourstroke = Pan2.ar(fourstroke, pan);
	fourstroke = Out.ar(0, fourstroke*env*truckamp*~masterAmp);


}).add;
)


Synth(\truck);
Synth(\car);


///////////////////////////////////////////////////////////////////////Task
(
~cartrucktask=Task({|i|
	~carSynth= Synth(\car, [
		\car, ~car.at(0),
		\cargate, ~cargate.at(0),
	]);
	~truckSynth= Synth(\truck, [
		\truckfreq, ~truckfreq.at(1),
		\truckamp, ~truckamp.at(1)
	]);


	inf.do({arg item, i;
		var truckfreq, truckamp, car, cargate;
		truckfreq= ~truckfreq.at(i).postln;
		truckamp = ~truckamp.at(i);
		car= ~car.at(i);
		cargate= ~cargate.at(i);



		~carSynth.set(\car, car);
		~carSynth.set(\cargate, cargate);
		~truckSynth.set(\truckfreq, truckfreq);
		~truckSynth.set(\truckamp, truckamp);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~cartrucktask.play;
s.record("/Users/mbk5020/Desktop/cartrucksynth.wav");
)












SynthDef(\car, {|freq=0.1, car=100, cargate=100 amp=30, pan=0, out=0, gate=1|
	var  src, src2, strike, env, env2;
	env=EnvGen.kr(Env.asr(0.01, 0.1), gate);
	src2=PinkNoise.ar(0.1)*SinOsc.kr(car);
	//src2=BPF.ar(src2, 500, 1);
	src=LFPar.ar(EnvGen.kr(Env([50, 500], [car], loopNode:1)))*SinOsc.kr(car)*Impulse.kr(cargate);
	src=Mix.ar([src, src2]);
	src=Pan2.ar(src, pan);
	src=Out.ar(out, src*env*amp*~masteramp);
}).add;

SynthDef(\car2,{|mul=0.01, pan=0, amp=1, gate=1|
	var env, env2, src;
	env=EnvGen.kr(Env.perc(0.1, 0.4), gate, doneAction:2);
	src=WhiteNoise.ar(SinOsc.ar(0.01).range(0.3, 0.8));
	src=LPF.ar(src, SinOsc.ar(0.01, 1/2pi).range(300, 700));
	src=Pan2.ar(src, LFPulse.kr(SinOsc.kr(0.1).range(2, 10)).range(-10, 10));
	Out.ar(0, src*env*amp);
}).add;