/**(
   var path = (Platform.userHomeDir +/+ "Downloads/afrodust.wav");
   var startFrame = 0;
   var numFrames = -1;

   var synth;
   var action = { | buffer |
     "Done".postln;
     synth = Synth.new("pullupemu_env",[ \buffnum, buffer, \gate: 1.0 ]);
   };
   var buffer = Buffer.read(s, path, startFrame, numFrames, action);

)**/
(
y = SynthDef(\help_Buffer2, { arg out = 0, startPos = 0, bufnum;
  var x_lin = MouseX.kr(0.0001, 1, 'linear');
  var y_lin = MouseY.kr(0.1, 1, 'linear');
  x_lin.poll(label: [\x_lin]);

  Out.ar(out, SinOsc.ar(x_lin.range(440,660), 0, 0.5)); 
}).play(s,[\out, 0 ]);
)
(
  s.boot;
p = Platform.userHomeDir +/+ "Desktop/Untitled\ Project/Samples/Imported/PARIS.aif";
k = Platform.userHomeDir +/+ "Downloads/afrodust.wav";
b = Buffer.readChannel(s, p, channels: [0, 1]);
c = Buffer.readChannel(s, k, channels: [0, 0]);


// now play it
(
x = SynthDef(\help_Buffer, { arg out = 0, startPos = 2, bufnum;
    var rate_lag = MouseY.kr(0.0001, 0.7, 'exponential');

    //var rate_lag = MouseX.kr(0.01, 0.7, 'exponential');
    var speed = MouseX.kr(0.1, 1.0, 'exponential', rate_lag);

    var lp = 1.0;
    //var y = MouseY.kr(-1, 1, 'exponential', 0.7);

    var rate = Select.kr( 0.5 > speed, [
      (speed-0.5)*2,
      speed * -2
    ]);
    var sound = PlayBuf.ar(
      2,
      bufnum,
      BufRateScale.kr(bufnum) * rate,
      startPos: startPos,
      loop: lp
    );
    rate.poll();
    Out.ar(out, sound);
  }).play(s,[\bufnum, b, \startPos, 2 ]);
)
//x.free; b.free;
)

(
  SynthDef(\pullupemu, {| out = 0, bufnum = 0, gate = 0.0|
    var pitch = 100;
    var minval = pitch * -1;
    var maxval = pitch;
    var wrap = 'exponential';
    var lag = 0.7; 
    
    var rate  = MouseX.kr(minval, maxval, wrap, lag);

    Out.ar(out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, gate, 0.0, 1.0)
    )
  }).add;
)
(
  SynthDef(\pullupemu_env, {| out = 0, bufnum = 0, gate = 0.0|
    var levels = [0, 1, 0.9, 0];
    var times =  [0.1, 0.5, 1];
    //a curvature value for all segments. 0 = linear,  +/- curve the segment up and down.
    var curve = [-5, 0, -5];

    var envelope = Env.new(levels, times, curve);
    var rate     = EnvGen.kr(envelope, gate: gate);

    Out.ar(out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, gate, 0.0, 1.0)
    )
  }).add;
)

(
  var fn = { | server |
    Bus.control(server, 1);
  };

  fn.value(s);
)
