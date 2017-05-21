s.boot;
~csv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/sandydata.csv").post;
(
~csv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/sinlakudata.csv").post;
~data=~csv.flop;
)

 ////////////////////////////////////////////////////Data
(
~masteramp=1;
~timedelta=1;
~timestep=~data.at(0);
~time=~data.at(1);
~lat=~data.at(2).normalize(-1, 1);
~lon=~data.at(3).normalize(-1, 1);
~pressure=~data.at(4).normalize(800, 200);
~asymmetry=~data.at(5).normalize(0.3, 1);
~asymmetrychimes=~data.at(5).normalize(0, 10);
~negVTL=~data.at(6).normalize(1, 6);
~negVTU=~data.at(7).normalize(1, 6);
)



/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\hurricane, {|asymmetry=0.5, lon=1, lat=1, pressure=300, negVTL=0.1, negVTU=0.1 gate=1, amp=0.1, pan=0, out=0|
	var src, src2, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=WhiteNoise.ar(asymmetry);
	src2=WhiteNoise.ar(asymmetry);
	src=RLPF.ar(src, pressure, LFNoise1.kr(negVTL, 0.3, 0.5));
	src2=RLPF.ar(src2, pressure, LFNoise1.kr(negVTU, 0.3, 0.5));
	src=Pan4.ar([src, src2], lon, lat);
	Out.ar(out, src*amp*~masteramp)
}).add;


SynthDef(\chimes, {|asymmetrychimes=2, freq=420, lon=1, lat=1, gate=1, amp=0.1, pan=0, out=0, amps=1, phase=1|
	var src, env, env2, chimes;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=DynKlank.ar(`[[freq, freq*3/2, freq*4/3, freq*6/5, freq*16/9],[amps], [phase]], Impulse.ar(asymmetrychimes));
	src=Resonz.ar(src, 600);
	src=CombL.ar(src, 0.8, 0.2, 2);
	src=Pan4.ar(src, lon, lat);
	Out.ar(out, src*amp*~masteramp)
}).add;

SynthDef(\flag, {|freq=400, negVTL=100, negVTU=10, lon=1, lat=1, gate=1, amp=0.2, pan=0, out=0, amps=1, phase=1|
	var src, env, env2, chimes;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=Mix([BrownNoise.ar(0.3)])*LFSaw.kr(negVTL);
	src=src+Mix([LFCub.ar(100)])*LFSaw.kr(negVTU);
	src=Pan4.ar(src, lon, lat);
	Out.ar(out, src*amp*~masteramp)
}).add;
)
Synth(\hurricane);
Synth(\chimes);
Synth(\flag);




///////////////////////////////////////////////////////////////////////Task
(
~hurricanetask=Task({|i|
	~hurricaneSynth= Synth(\hurricane, [
		\lat, ~lat.at(2),
		\lon, ~lon.at(3),
		\pressure, ~pressure.at(4),
		\asymmetry, ~asymmetry.at(5),
		\negVTL, ~negVTL.at(6);
		\negVTU, ~negVTU.at(6);
	]);
	~chimesSynth= Synth(\chimes, [
		\lat, ~lat.at(2),
		\lon, ~lon.at(3),
		\asymmetrychimes, ~asymmetrychimes.at(5),
	]);
	~flagSynth= Synth(\flag, [
		\lat, ~lat.at(2),
		\lon, ~lon.at(3),
		\negVTL, ~negVTL.at(6);
		\negVTU, ~negVTU.at(6);
	]);
	~timestep.size.do({arg item, i;
		var lat,lon, asymmetry, asymmetrychimes, pressure, negVTL, negVTU;
		lat=~lat.at(i);
		lon=~lon.at(i);
		asymmetry=~asymmetry.at(i);
		asymmetrychimes=~asymmetrychimes.at(i).postln;
		pressure=~pressure.at(i);
		negVTL=~negVTL.at(i);
		negVTU=~negVTU.at(i);
		~hurricaneSynth.set(\lat, lat);
		~hurricaneSynth.set(\lon, lon);
		~hurricaneSynth.set(\pressure, pressure);
		~hurricaneSynth.set(\asymmetry, asymmetry);
		~hurricaneSynth.set(\negVTL, negVTL);
		~hurricaneSynth.set(\negVTU, negVTU);
		~chimesSynth.set(\lat, lat);
		~chimesSynth.set(\lon, lon);
		~chimesSynth.set(\asymmetrychimes, asymmetrychimes);
		~flagSynth.set(\lat, lat);
		~flagSynth.set(\lon, lon);
		~flagSynth.set(\negVTL, negVTL);
		~flagSynth.set(\negVTU, negVTU);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~hurricanetask.play;
)
