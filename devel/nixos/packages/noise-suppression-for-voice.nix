# Build with:
#   nix-build -E 'with import <nixpkgs> {}; callPackage ./noise-suppression-for-voice.nix {}'

# Usage:
# pactl list sources short
#   1	alsa_input.pci-0000_02_02.0.analog-stereo	module-alsa-card.c	s16le 2ch 44100Hz	RUNNING
# pacmd load-module module-null-sink sink_name=mic_denoised_out rate=48000
# pacmd load-module module-ladspa-sink sink_name=mic_raw_in sink_master=mic_denoised_out label=noise_suppressor_stereo plugin=/result/lib/librnnoise_ladspa/librnnoise_ladspa.so control=50
# pacmd load-module module-loopback source=alsa_input.pci-0000_02_02.0.analog-stere osink=mic_raw_in channels=2 source_dont_move=true sink_dont_move=true

{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  version = "0.91";
  pname = "noise-suppression-for-voice";
  src = fetchFromGitHub {
    owner = "werman";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-jLcSFQz5kt+PcWetZUQ1NEQ2diI7Z/ZaBe/oyZaO/IY=";
  };

  cmakeFlags = [
    # The install script assumes this path is relative to CMAKE_INSTALL_PREFIX
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  nativeBuildInputs = [ cmake ];
  meta = {      
    description = "real-time noise supression plugins";
    homepage = "https://github.com/werman/${pname}";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    #maintainers = [ lib.maintainers.confus ];
  };
}

