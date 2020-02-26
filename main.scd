(
var main = { | server, sample_paths |
	var load_timeout = 9;
	var loaded = Set[];

	var buffers = sample_paths.collect({ | relative_homedir_path |
		var path = (
			// Platform.userHomeDir +/+
			relative_homedir_path
		);
		Buffer.read(server, path, action: { |buffer|
			("好" + relative_homedir_path ).postln;
			loaded.add(buffer);
		});
	});

	var thread = fork {
		loop {
			if (loaded.size > 0) {
				var synth = Synth.new("wdj", [ \bufnum, loaded.pop() ]);
				synth.postln;
			} {
				1.wait;
			};
		}
	};

	//server.record;
	load_timeout.wait;
	thread.stop;
	"done".postln;
};

s.waitForBoot({
	var wdj = SynthDef(\wdj, { |
		out = 0,
		bufnum,
		//rate = 1.0,
		startPos = 234800,
		loop = 0.0 |

		var mouse= LFNoise0.kr(4).range(0.1,10);
		var sound, rate;
		/*		var trig = Impulse.kr(XLine.kr(0.1, 6, 30));
		var rate = XLine.kr(1, 12, 30);*/
		//var rate = LFNoise2.kr(800).range(0.1,10);

		var trig = Impulse.ar(mouse);
		rate= EnvGen.ar(Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]),Impulse.ar(mouse),timescale:1/mouse)*LFNoise2.kr(10).range(-1,0);
		startPos=LFNoise0.kr(1).range(1,1000000);

		//rate= EnvGen.ar(Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]),Impulse.ar(mouse),timescale:1/mouse)*LFNoise2.kr(LFNoise2.kr(1).range(1,10)).range(-1,0);

		sound = PlayBuf.ar(
			numChannels: 2,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * rate,
			trigger: trig,
			startPos: startPos,
			loop: loop
		);
		startPos.postln;
		Out.ar(out, sound);
	});
	wdj.add;
	main.value(s, [
		//"path/relative/toHomeDir.wav"
		"/Users/sofokliskoutsourelis/Desktop/PALLADOS guns_out_2d_2b_amp.aiff"
	]);
});
)
Server.default.stopRecording;
