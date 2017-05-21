/////////////////////////////////////////////////This is done////////////////////////////////////////////////////////


(
//goldcoin
~coincsv=CSVFileReader.readInterpret("/Users/mbk5020/Desktop/ForeignAffairs/groundbeefcheesebacon2.csv").post;
~coindata=~coincsv.flop;
)


 ////////////////////////////////////////////////////Data
(
~timedelta=0.1;
//truckdata
~silvercoin = ~coindata.at(0).abs.normalize(1, 5);
~silvercoinfreq = ~coindata.at(0).normalize(200, 800);
~goldcoin = ~coindata.at(1).normalize(4, 10);
~goldcoinfreq = ~coindata.at(1).normalize(400, 1200);
)

/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\silver, {
	|
	freq1=1100 freq2=1200, freq3=980, silvercoinfreq=960, pan=0, amp=0.2, ring=6, loud=0.5, silvercoin=0.2, attack=2, decay=2, gate=1
	|
	var env, src;
	env=EnvGen.kr(Env.asr(0.01, 0.1), gate);
	src=DynKlank.ar(`[[silvercoinfreq, silvercoinfreq + 10, silvercoinfreq + 120, silvercoinfreq + 240], [loud!4], [ring!4]], Impulse.ar(silvercoin));
	src=Pan2.ar(src, SinOsc.ar(0.04).range(-0.8, 0.8));
	Out.ar(0, src*env*amp*~masterAmp);
}).add;

SynthDef(\gold, {|goldcoin=5, goldcoinfreq=600, amp=6, pan=0, out=0, gate=1|
	var src, env;
	env=EnvGen.kr(Env.asr(0.01, 0.1), gate);
	src=Impulse.ar(goldcoin);
	src=Array.fill(3, Resonz.ar(src, goldcoinfreq, 0.001, 100));
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*amp*~masterAmp);
}).add;
)


///////////////////////////////////////////////////////////////////////Task
(
~cointask=Task({|i|
	~silverSynth= Synth(\silver, [
		\silvercoin, ~silvercoin.at(0),
		\silvercoinfreq, ~silvercoinfreq.at(0),
	]);

	~goldSynth= Synth(\gold, [
		\goldcoin, ~goldcoin.at(1),
		\goldcoinfreq, ~goldcoinfreq.at(1),
	]);

	inf.do({arg item, i;
		var silvercoin, silvercoinfreq, goldcoin, goldcoinfreq;
		silvercoin= ~silvercoin.at(i);
		silvercoinfreq= ~silvercoinfreq.at(i);
	    goldcoin= ~goldcoin.at(i);
		goldcoinfreq= ~goldcoinfreq.at(i).postln;


		~silverSynth.set(\silvercoin, silvercoin);
		~silverSynth.set(\silvercoinfreq, silvercoinfreq);
		~goldSynth.set(\goldcoin, goldcoin);
		~goldSynth.set(\goldcoinfreq, goldcoinfreq);
		~timedelta.wait;
	})
});
)
///////////////////////////////////////////////////////////////////////Play
(
~cointask.play;
s.record("/Users/mbk5020/Desktop/goldandsilversynth.wav");
)