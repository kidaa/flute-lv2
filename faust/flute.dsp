// Waveguide flute
import("flute.lib");
import("instrument.lib");
import("params.lib");

process = flute : scale : stereo
with {

   scale = _ * 0.3 * effectiveGain;

   effectiveGain = select3(gainSelect, gain, constantGain, breathControl);

   stereo = stereoizer(SR/freq);

};

 
