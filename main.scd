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

        var bus = Bus.control(server, 1);
        var thread;
        
        bus.set(1);
	thread = fork {
		loop {
			if (loaded.size > 0) {
				var synth = Synth.new("wdj", [
                                  \bufnum, loaded.pop()
                                ]);
                                synth.map(\rate, bus.index);
				synth.postln;
			} {
				1.wait;
			};
		}
	};

        // default addToHead, should work with groups for performance
        Synth.new("gesture", [ \bus, bus.index ]);
	//server.record;
	load_timeout.wait;
	thread.stop;
	"done".postln;
};

s.waitForBoot({
        var gesture = SynthDef(\gesture, { | bus |
            Out.kr(bus, XLine.kr(1, 12, 30));
        });
	var wdj = SynthDef(\wdj, { |
		out = 0,
		bufnum,
		rate = 1,
		startPos = 234800,
		loop = 0.0 |

                var trig = 1;

		var sound = PlayBuf.ar(
			numChannels: 2,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * rate,
			trigger: trig,
			startPos: startPos,
			loop: loop
		);
                rate.scope;
		startPos.postln;
		Out.ar(out, sound);
	});
        gesture.add;
	wdj.add;
	main.value(s, [
		//"path/relative/toHomeDir.wav"
		"/Users/dmtrs/Desktop/STORMZYx DJLAG.wav"
	]);
});
)

Server.default.stopRecording;
