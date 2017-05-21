
s.options.sampleRate = 48000;
s.reboot;
(
s.boot;
~buffer1=Buffer.alloc(s, 512, 1, {arg buf; buf.sine1Msg(1.0/[3, 4, 7, 8, 1, 2])});
~path="/Users/mbk5020/Desktop/SONIFICATION/polar day/polar iterations/";

~polardata=CSVFileReader.read(~path ++ "polardata.csv", true, true).asFloat;
~data=~polardata.flop;
///basaltemp
~basalTemperatures=thisProcess.interpreter.executeFile(~path ++ "basal_temp_info");
~basaltemps=Array.newClear(~basalTemperatures.size);
~basalTemperatures.do({ arg item, i; ~basaltemps.put(i, item[1]) });
~masterAmp=1;
)
////////////////////////////////////////////////////Data
(
~size=4001;
~timedelta=0.1;

///matt grounded ice
~groundedIceArea = ~data.at(4).normalize(30, 90);
~groundedIceVolume = ~data.at(1).normalize(0, 0.2);

//matt floating ice
~floatingIceArea  = ~data.at(5).normalize(0, 1);
~floatingIceVolume = ~data.at(2).normalize(0.1, 6);
~floatingIceVLFP = ~data.at(2).normalize(1200, 1600);

///matt sealevel
~sealevel = ~data.at(7).normalize(1, 4);
~sealevelAmp = ~data.at(7).normalize(0.01, 1);

////ballora totalice (area + volume)
~trigrates=~data.at(3).normalize(7, 25);
~attacks=~data.at(3).normalize(0.02, 0.2);
~spreads=~data.at(3).normalize(0.25, 1);
~damps=~data.at(0).normalize(0.25, 1);
~roomsizes=~data.at(0).normalize(0.5, 0.7);
~freqscales=~data.at(0).reciprocal.normalize(0.5, 1.25);
~noiselevs=~data.at(0).normalize(0, 0.0025);
~levels=~data.at(0).normalize(0.5, 2);

///////ballora solar radiation
~earthFundamental=7.83; // lowest Schumann resonance
~fund=~earthFundamental*32;
//~sunPitches=~solarRadiationDeltaJan.normalize(~fund*(2**(8/9)), ~fund*(2**(9/8)));
~sunPitches=~data.at(6).normalize(~fund*(5/6), ~fund*(6/5));
~sunCutoffs=~data.at(6).normalize(2500, 10000);
~sunDetunes=~data.at(6).normalize(-1, 5);

////ballora basil temps
~groundarea=~data.at(4).normalize(60, 90);
~noiserqs=~data.at(4).normalize(0.005, 0.02);
~temperaturesSawVol=~basaltemps.normalize(0.01, 0.035);
~temperaturepitches=~basaltemps.normalize(30, 45);
~temperaturesSawDetunes=~basaltemps.normalize(0.1, 1);
~temperaturesSawCutoffs=~basaltemps.normalize(180, 1000);
)

/////////////////////////////////////////////////////////////////////Synth
(
SynthDef(\totalicev, { arg level=0.2,mix=0.5, attackmax=0.1, spread=1, trigrate=4, freqscale=1, size=0.2, damp=0.2, gate=1, noiselev=0.025;
var trig, attack;

	trig=Dust.ar(trigrate, 0.35);
	attack=TRand.ar(0.5, attackmax, trig);
	e=Env.asr(0.1, 1, 1);
d=Pan2.ar(
		DynKlank.ar(`[
			[TRand.ar(740, 780, trig), 2100, TRand.ar(2200, 2300, trig), 4830, TRand.ar(6000, 6150, trig)],
			[TRand.ar(50, 50, trig), TRand.ar(65,80, trig), TRand.ar(100, 125, trig), TRand.ar(12,20, trig), TRand.ar(70,85,trig)]*0.0035,
			[TRand.ar(0.05, 0.1, trig), TRand.ar(0.05, 0.15, trig), TRand.ar(0.05, 0.15, trig), TRand.ar(0.07, 0.14, trig), TRand.ar(0.07, 0.14, trig)]
			],
			Decay2.ar(trig, attack, 0.5, GrayNoise.ar(0.025), BrownNoise.ar(noiselev)),
			freqscale),
	TRand.ar(spread.neg, spread, trig) );
	//c=CombL.ar(d, 0.2, 0.2, 1);
	d=LPF.ar(d, 2000);
	l=Limiter.ar(d, 0.35, 0.001);
	g=FreeVerb.ar(l, mix, size, damp);
	Out.ar(0, level*g*EnvGen.ar(e, gate: gate, doneAction:2)) }, [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]).add;

SynthDef(\groundice, {|freq=200, attack=1, sus=10, decay=1 low=70, high=75 amp=0.1, gate=1, out=0, pan= 10, room=30, rev=1, damp=0.6, bpf=400, modulate=0.01|
	var  src, env, mod;
	env=EnvGen.ar(Env.asr(attack, sus, decay, \sin), doneAction:2);
	mod=SinOsc.kr(modulate).range(0.1, 0.2);
	src=COsc.ar(~buffer1, SinOsc.ar(200).range(low, high+40), 0.7, 0.2)*mod;
	src=BPF.ar(src, bpf, 0.5);
	src=GVerb.ar(src, room, rev, 0.6, 0.3);
	src=Pan2.ar(src, pan);
	Out.ar(out, src*env*amp*~masterAmp);
}).add;

SynthDef(\floatingicev, {|freq=300, imp=3, amp=0.8, pan= -10, gate=1 out=0, time=1.2, lpf=300|
	var src, env1, env2;
	env1 = EnvGen.kr(Env.asr(0.1, 1, 1), gate);
	src=Dust.ar(imp);
	src=GVerb.ar(src, 5, 1, 0.6);
	src=LPF.ar(src, lpf);
	src=Pan2.ar(src, pan);
	Out.ar(out, src*env1*amp);
}).add;

SynthDef(\sealevel, {| gate=1, amp=20, pan=0, mul=0.005, rq=0.03, pitch1=500, pitch2=800, lpf1=14, lpf2=30, noise1=1, noise2=1, bubble1=1, bubble2=1, delay=0.002|
	var src, src2, out, env;
	env=EnvGen.kr(Env.asr(0.01, 1), gate, doneAction:2);
	src=OneZero.ar(Impulse.ar(noise1), 0.99);
	src=RHPF.ar(src, LPF.ar(BrownNoise.ar(bubble1), lpf1)*600 + pitch1, rq, mul);
	src2=OneZero.ar(Impulse.ar(noise2), 0.99);
	src2=DelayL.ar(RHPF.ar(src2, LPF.ar(BrownNoise.ar(bubble2), lpf2)*600 + pitch2, rq, mul), 0.2, delay);
	out=Mix.ar([src, src2]);
	out=GVerb.ar(out, 20, 3, drylevel:0.01);
	out=Pan2.ar(src+src2, pan);
	Out.ar(0, out*env*amp*~masterAmp)
}).add;

SynthDef(\solarrad, {| rate=2, dur=1, freq=235, vol=0.9, mod=15, detune=0.1, cutoff=1000, out=0, gate=1 |
	var freqdev=WhiteNoise.kr(70), pulser;
	var winenv=Env.perc(1.9, 1.5, 1, 8);
	//pulser=Impulse.ar(rate, vol*1.5);
	e=Env.asr(0.1, 1, 1);
	pulser=Dust.ar(rate, vol*0.7);
	z = Buffer.sendCollection(s, winenv.discretize, 1);
	//f=235;
	o=Lag.ar(
		GrainFM.ar(2, pulser, dur, freq, (freq*mod)+WhiteNoise.kr(0.7), 3, TRand.kr(pulser, -1, 1), z.bufnum, 512, 0.85)
		+
	    GrainFM.ar(2, pulser, dur, freq+detune, ((freq+detune)*mod)+WhiteNoise.ar(0.7), 3, TRand.kr(pulser, -1, 1), z.bufnum, 512)
		,0.1
	)
	;
	p=CombC.ar(o, 0.35, 0.2, 3.0, 0.7);
	q=CombC.ar(o, 0.35, 0.153, 3.0, 0.7);
	r=CombC.ar(o, 0.35, 0.257, 3.0, 0.7);
	t=CombC.ar(o, 0.35, 0.343, 3.0, 0.7);
	u=o+p+q+r;
	f=HPF.ar(u, 1000);
	f=LPF.ar(u, cutoff);
	Out.ar(out, f*EnvGen.ar(e, gate: gate, doneAction: 2) !2)
},[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1] ).add;

SynthDef(\basalTemp, { | sawfreq=75, detune=0.1, sawcutoff=150, sawvol=0.03, cutoff=1000, pan=0, dur=6, noiserq=0.005, fund=75, resonance=150, f1=350, f2=750, f3=2400, f4=2675, f5=2950, volume=1, gate=1 out=0 |
	var genv, gravenv, output;
	genv=Env.asr(0.1, 1, 1);
	gravenv=Env.new([67.6, 160, 65, 70, 60 ]*5, 0.4, \sine);

	o=Mix.ar(Resonz.ar(
		RHPF.ar(
			Blip.ar(fund, 50, 0.25)+BrownNoise.ar(0.07),
			resonance,
			0.1),
		[f1, f2, f3, f4, f5], // formants
		0.1, //rq
		[0, -12, -29, -26, -35].dbamp //formant amplitudes
	));
	4.do({ o=AllpassN.ar(o, 0.03, [(0.02.rand)+0.01, (0.02.rand)+0.01], dur, 0.75) });

	r=Resonz.ar(BrownNoise.ar(0.9), fund, noiserq,
		0.2;
		);
	d=DelayN.ar(r, 0.01);
	c=r+d;
	8.do({ c=AllpassN.ar(c, 0.03, [(0.02.rand)+0.01, (0.02.rand)+0.01], 2, 1.1) });

	b=RLPF.ar(Saw.ar([sawfreq, sawfreq+detune], sawvol), sawcutoff, 0.1);

	output=Pan2.ar(c+b, pan);
	//DetectSilence.ar(c, doneAction: 2);
	Out.ar(out, (output)*EnvGen.ar(genv, gate: gate, levelScale: volume));
}, [1, 1, 1, 1]).add;
)


Synth(\totalicev);
Synth(\groundedicev);
Synth(\floatingicev);
Synth(\totalicea);
Synth(\groundedicea);
Synth(\floatingicea);
Synth(\solarrad);
Synth(\sealevel);


Synth(\groundice);
(
~polardata=Task({
	~totalice= Synth(\totalicev, [\size, ~roomsizes[0], \damp, ~damps[0], \freqscale, ~freqscales[0], \spread, ~spreads[0], \attackmax, ~attacks[0], \trigrate, ~trigrates[0], \noiselev, ~noiselevs[0], \level, ~levels[0]]);

	~groundedice= Synth(\groundice, [\low, ~groundedIceArea.at(4), \high, ~groundedIceArea.at(4), \amp, ~groundedIceVolume.at(1)]);

	~floatingice= Synth(\floatingicev, [\imp, ~floatingIceVolume.at(2), \lpf, ~floatingIceVLFP.at(2), \amp, ~floatingIceArea.at(5)]);


	~sealevelSynth= Synth(\sealevel, [\noise1, ~sealevel.at(7), \noise2, ~sealevel.at(7), ~sealevelAmp.at(7)]);

	~solarrad= Synth(\solarrad, [\rate, 25, \dur, 0.5, \freq, ~sunPitches.at(6), \cutoff, ~sunCutoffs.at(6)]);

	~basalTempSynth= Synth(\basalTemp, [\fund, ~groundarea[0], \noiserq, ~noiserqs[0], \sawfreq,   ~temperaturepitches[0], \sawvol, ~temperaturesSawVol[0], \detune, ~temperaturesSawDetunes[0]]);

	/////////////////
	~size.do({ arg item, i;
		var totalIceV, groundIceV, floatingIceV, floatingIceVLPF, totalIceA, groundIceA, floatingIceA, solarrad, sealevel, sunPitches, sunCuttoffs, sunDetunes, fundamental;

		totalIceA = ~totalIceArea.at(i).postln;

		groundIceA = ~groundedIceArea.at(i);
		groundIceV = ~groundedIceVolume.at(i);

		floatingIceV = ~floatingIceV.at(i);
	    floatingIceVLPF = ~floatingIceVLFP.at(i);
		floatingIceA = ~floatingIceArea.at(i);

		sealevel = ~sealevel.at(i);

		sunPitches = ~sunPitches.at(i);
		sunCuttoffs = ~sunCutoffs.at(i);
		sunDetunes = ~sunDetunes.at(i);
		fundamental= ~groundarea[i];
		/////////////////////////////
		~totalice.set(\size, ~roomsizes[i], \damp, ~damps[i], \freqscale, ~freqscales[i], \spread, ~spreads[i], \attackmax, ~attacks[i], \trigrate, ~trigrates[i], \noiselev, ~noiselevs[i], \level, ~levels[i]);

		~groundedice.set(\low, groundIceA, \high, groundIceA, \amp, groundIceV);

		~floatingice.set(\imp, floatingIceV, \lpf, floatingIceVLPF, \amp, floatingIceA);

		~sealevelSynth.set(\noise1, sealevel, \noise2, sealevel);

		~solarrad.set(\freq, sunPitches, \cutoff, sunCuttoffs, \detune, sunDetunes);

		~basalTempSynth.set(\fund, fundamental, \noiserq, ~noiserqs[i]);
				if ( ((i%10) == 0),
			{ j=i/10;
				~basalTempSynth.set(\sawfreq, fundamental*0.5, \sawvol, ~temperaturesSawVol[j], \detune, ~temperaturesSawDetunes[j], \sawcutoff, ~temperaturesSawCutoffs[j] );

		});
		~timedelta.wait;
	})
});
)
(
c=ClockFace.new;
c.play;
s.meter;
~polardata.start;
s.record;
)
~polardata.pause;
~polardata.stop;

