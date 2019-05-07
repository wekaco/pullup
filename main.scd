(
  var samples = [
    "stan.wav",
    //"SC_190505_003417_amp.wav" 
  ];

  var main = { | server, project_name = "code/sc-pullup" |
    var load_timeout = 9;
    var loaded = Set[];
    
    var buffers = samples.collect({ | name |
      var path = (
        Platform.userHomeDir +/+
        project_name +/+
        "Samples/Imported/" +/+
        name
      );
      Buffer.read(server, path, action: { |buffer| 
        ("好" +name ).postln;
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

    server.record;
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

      var trig = Impulse.kr(XLine.kr(0.1, 6, 30));
      var rate = XLine.kr(1, 2, 6) * -1;

      var sound = PlayBuf.ar(
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
    main.value(s);
  });
)
Server.default.stopRecording;
