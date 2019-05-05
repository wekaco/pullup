(
  var samples = [
    "PARIS.aif" 
  ];

  var main = { | server, project_name = "code/sc-pullup" |
    var loaded = Set[];
    var buffers = samples.collect({ | name |
      var path = (Platform.userHomeDir +/+ project_name +/+ "Samples/Imported/" +/+ name);
      Buffer.read(server, path, action: { |buffer| 
        ("Loaded:" +name + "\n" + buffer).postln;
        loaded.add(buffer);
      });
    });
    
    fork {
      loop {
        if (loaded.size > 0) {
          "pop".postln;
          Synth.new("wdj", [ \bufnum, loaded.pop() ]);
        };
        1.wait;
      }
    }
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
