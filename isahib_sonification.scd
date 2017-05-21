(
s.boot;

~file=CSVFileReader.readInterpret("/Users/matthewkenney/Desktop/Folders/Sonification/StudioLab/isahib-interaction/interactions1.csv").post;

~data=~file.flop;

)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////Data References
////////////////////////////////////////////////////////////////////////////////////////////////Data Prep
(
~buffsize=~file.size;
~lowerMultiple=0.25;
~fund=400;
~lowfund=~fund*~lowerMultiple;
~feelingsMax=log2(1.2);
~feelingsMin=log2(~lowerMultiple);

//////////////////////Time Variables
~id=~data.at(0);
~bust=~data.at(1);
~day=~data.at(2);
~starttime=~data.at(3);
~timedelta=~data.at(4);
~occasion=~data.at(5);
///////////////////////////
~happy=~data.at(6);
~sad=~data.at(7);
~angry=~data.at(8);
~valence=~data.at(9);
~arousal=~data.at(10);
~suppression=~data.at(11);
~reapraisal=~data.at(12);


~happyNorm=~happy-(~happy.minItem);   // offset all values so that the minimum is 0
~sadNorm=~sad-(~sad.minItem);
~angryNorm=~angry-(~angry.minItem);
~valenceNorm=~valence-(~valence.minItem);
~arousalNorm=~arousal-(~arousal.minItem);
~suppressionNorm=~suppression-(~suppression.minItem);
~reapraisalNorm=~reapraisal-(~reapraisal.minItem);


~happyNorm.minItem; // 0
~happyNorm.maxItem; // 82

~happyData=~happyNorm.normalize(~feelingsMin, ~feelingsMax);
~sadData=~sadNorm.normalize(~feelingsMin, ~feelingsMax);
~angryData=~angryNorm.normalize(~feelingsMin, ~feelingsMax);
~valenceData=~valenceNorm.normalize(~feelingsMin, ~feelingsMax);
~arousalData=~arousalNorm.normalize(~feelingsMin, ~feelingsMax);
~suppressionData=~suppressionNorm.normalize(~feelingsMin, ~feelingsMax);
~reapraisalData=~reapraisalNorm.normalize(~feelingsMin, ~feelingsMax);


~happyData.minItem; // -2
~happyData.maxItem;  // 0.263

////////////////////////////////////////////////Questions
~happyData=something.do(|i| ~fund*(2**(~happyData.at(i));
~sadData=somethig.do(|i| ~fund*(2**(~sadData.at(i));
~angryData=something.do(|i| ~fund*(2**(~angryData));
~valenceData=something.do(|i|~fund*(2**(~valenceData));
~suppressionData=something.do(|i| ~fund*(2**(~suppressionData));
~reapraisalData=something.do(|i| ~fund*(2**(~reapraisalData));


~happyData=Buffer.alloc(s, ~buffsize, bufnum: ~happyBuff);
~sadData=Buffer.alloc(s, ~buffsize, bufnum: ~sadBuff);
~angryData=Buffer.alloc(s, ~buffsize, bufnum: ~angryBuff);
~valenceData=Buffer.alloc(s, ~buffsize, bufnum: ~valenceBuff);
~arousalData=Buffer.alloc(s, ~buffsize, bufnum: ~arousalBuff);
~suppressionData=Buffer.alloc(s, ~buffsize, bufnum: ~suppressionBuff);
~reapraisalData=Buffer.alloc(s, ~buffsize, bufnum: ~reapraisalBuff);


~happyData.setn(0,~happyData);
~sadData.setn(0, ~sadData);
~angryData.setn(0, ~angryData);
~valenceData.setn(0, ~valenceData);
~arousalData.setn(0, ~arousalData);
~suppressionData.setn(0, ~suppressionData);
~reapraisalData.setn(0, ~reapraisalData);

~happyVols.normalize(0.05, 0.75);
~sadVols=~sad.normalize(0.05, 0.75);
~angryVols=~angry.normalize(0.05, 0.75);
~valenceVols=~valence.normalize(0.05, 0.75);
~arousalVols=~arousal.normalize(0.05, 0.75);
~suppressionVols=~suppression.normalize(0.05, 0.75);
~reapraisalVols=~reapraisal.normalize(0.05, 0.75);


~timeIncrement=0.18;
)


////////////////////////////////////////////////////////////////////////////////////////////////Synths

(
~happy=SynthDef(\happy, {
	|
	happy=700, happyvol=0.8, valence=8 pan=0, out=0, reap=7, sup=0.1, buf =1, rate=0.1 t_trig =1, amp=0.5
	|
	var src, srclo, srchigh, env, tempo, value;
	env=EnvGen.ar(Env([1, 1], [2, 2]);
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	tempo=Impulse.ar(valence);
	srclo=DynKlank.ar(`[[happy!4], [0.1!4], [1!4]], Decay2.ar(PulseDivider.ar(tempo, 4), 0.005, 0.1));
	srchigh=DynKlank.ar(`[[happy+200!4], [0.2!4], [1!4]], Decay2.ar(tempo , 0.005, 0.5));
	src=Pan2.ar(srclo*srchigh*env*happyvol, SinOsc.kr(0.1, 0, 0.8, 0));
	src=FreeVerb.ar(src, 0.33, 0.9, 0.3);
	Out.ar(out, src)
})).add;

~sad=SynthDef(\sad, {
	|
	sad=100, sadvol=0.2, out=0, pan=0, buf =1, rate=0.1 t_trig =1, amp=0.5
	|
	var env, env2, src, value;
	env=EnvGen.ar(Env.perc(0.01, 3);
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	src=MoogFF.ar(Pulse.ar(sad, rrand(0.3, 0.6)), SinOsc.kr(LFNoise0.kr(0.2, 1, 1.2), 200, 700));
	src=Decay.ar(src, 0.03, 0.3);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*sadvol);
}).add;

~arousal=SynthDef(\arousal, {
	|
	valence=8, out=0, arousal=100, arousalvol=0.2, buf =2, amp=0.3, pan=0, rate=0.1 t_trig =1
	|
	var src, brush, hat, thud, env, tempo, value;
	tempo = Impulse.ar(valence);
	env=EnvGen.ar(Env([1, 1], [2, 2]);
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	brush = BrownNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 8, 1), 0.005, 0.5));
	hat= Mix.ar([WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5))*SinOsc.ar(400)]);
	src=Pan2.ar((brush + hat)*arousalvol*env, pan);
	Out.ar(out, src);
	}).add;

~angry=SynthDef(\angry, {
	|
	angry=70, angryvol=0.2, out=0, pan=0, buf =2, rate=0.1 t_trig =1, amp=0.5
	|
	var env, env2, src;
	env=EnvGen.ar(Env.perc(0.1, 1);
	src=Mix.ar([LFTri.ar(angry, 0, 30, 70)*LFSaw.kr(SinOsc.kr(1, 0, 0.3, 0.4), 0, 0.3, 0.4)]);
	src=Pan2.ar(src, pan);
	Out.ar(0, src*env*angryvol);
}).add;
)

Synth(\happy);
Synth(\sad);
Synth(\arousal);
Synth(\angry);

////////////////////////////////////////////////////////////////////////////////////////////////////////////
~valence=SynthDef(\valence, {|out=0, buf =3, rate=0.1 t_trig =1, amp=0.5|
	var value, synthesis;
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	synthesis= DynKlang.ar(`[[value!4], [0.1, 0.2, 0.3], [1!4]], Mix.ar(SinOsc.ar(value), PinkNoise.ar(0.2)));
	synthesis= FreeVerb.ar(synthesis, 0.5, 0.8, 0.3);
	synthesis=Pan2.ar(synthesis, 0);
	Out.ar(out, synthesis*amp);
}).add;

~suppression=SynthDef(\suppression, {|out=0, buf =4, rate=0.1 t_trig =1, amp=0.5|
	var value, synthesis;
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	synthesis= DynKlang.ar(`[[value!4], [0.1, 0.2, 0.3], [1!4]], Mix.ar(SinOsc.ar(value), PinkNoise.ar(0.06)));
	synthesis= FreeVerb.ar(synthesis, 0.5, 0.8, 0.3);
	synthesis=Pan2.ar(synthesis, 0);
	Out.ar(out, synthesis*amp);
}).add;

~reapraisal=SynthDef(\reapraisal, {|out=0, buf =5, rate=0.1 t_trig =1, amp=0.5|
	var value, synthesis;
	value= PlayBuf.ar(1, buf, rate/SampleRate.ir, t_trig, loop:0);
	synthesis=DynKlang.ar(`[[value!4], [0.1, 0.2, 0.3], [1!4]], Mix.ar(SinOsc.ar(value), PinkNoise.ar(0.03)));
	synthesis= FreeVerb.ar(synthesis, 0.5, 0.8, 0.3);
	synthesis=Pan2.ar(synthesis, 0);
	Out.ar(out, synthesis*amp);
}).add;

Synth(\valence);
Synth(\suppresion);
Synth(\reapreaisal);

////////////////////////////////////////////////////////////////////////////////////////////////Task

(
~feelings=Routine({
s.sync;
~happy=Synth(\happy, [\buf, 0, \vol, ~happyVols0, \rate, 0.1]);
~sad=Synth(\sad, [\buf, 1, \vol, ~sadVols0, \rate, 0.1]);
~angry=Synth(\angry, [\buf, 2, \vol, ~angryVols0, \rate, 0.1]);
~valence=Synth(\valence, [\buf, 3, \vol, ~valenceVols0, \rate, 0.1]);
~arousal=Synth(\arousal, [\buf, 4, \vol, ~arousalVols0, \rate, 0.1]);
});
)

~feelings.play;


~suppression=(\suppression, [\vol, ~suppressionVols.wrapAt(i), \freq, ~fund*(2**(~suppressionData.wrapAt(i)))]);
~reapraisal=Synth(\reapraisal, [\vol, ~reapraisalVols.wrapAt(i), \freq, ~fund*(2**(~reapraisalData.wrapAt(i)))]);
