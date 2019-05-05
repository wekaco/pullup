(
  var samples = [
    "PARIS.aif",
    "SC_190505_003417_amp.wav" 
  ];

  var main = { | server, project_name = "code/sc-pullup" |
    var load_timeout = 9;
    var loaded = Set[];
    
    var buffers = samples.collect({ | name |
      var path = (Platform.userHomeDir +/+ project_name +/+ "Samples/Imported/" +/+ name);
      Buffer.read(server, path, action: { |buffer| 
        ("好" +name ).postln;
        loaded.add(buffer);
      });
    });
   
    var f = fork {
      loop {
        if (loaded.size > 0) {
          var synth = Synth.new("wdj", [ \bufnum, loaded.pop() ]);
          synth.postln;
        } {
          1.wait;
        };
      }
    };

    load_timeout.wait;
    f.stop;
    "done".postln;
  };
  
  s.waitForBoot({
    var wdj = SynthDef(\wdj, { | out = 0, bufnum, rate = 1.0, startPos = 1, loop = 1.0 |
      var sound = PlayBuf.ar(
        2,
        bufnum,
        BufRateScale.kr(bufnum) * rate,
        startPos: startPos,
        loop: loop
      );
      Out.ar(out, sound);
    });
    wdj.add;
    main.value(s);
  });
)
