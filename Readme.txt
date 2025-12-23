NeoLemmix Community Edition

by William James
based on NeoLemmix by Namida Verasche and Stephan Neupert,
itself based on Lemmix by Eric Langedijk,
inspired by Lemmings by DMA.

The main branch is "master", which gives users access to most data files 
allowing them to easily mod their copy of the game.

Release builds are compiled using Delphi 10.4.2.

No version currently exists that can be compiled on Lazarus. This implies in 
particular that the only way to play NeoLemmix on Linux systems is via Wine.

Whether the game compiles on other Delphi versions is unknown. Past versions
of NeoLemmix were compiled on Delphi 7 and/or Delphi XE6; it is known that
NeoLemmix has not been compilable on Delphi 7 for a long time, but it may
still work on XE6 (and inbetween versions).

Compile instructions for the NeoLemmix player:
- NeoLemmix requires the Graphics32 library, including GR32PNG.
  Graphics32 can be downloaded here:
    https://github.com/graphics32/graphics32
  GR32PNG can be downloaded here:
    https://github.com/graphics32/GR32PNG
- Run MakeSymLinks.bat. This creates symbolic links inside the "bin" folder
  to various subfolders of "data/external".
- Build NeoLemmix.dproj. No special build scripts are required.

Further comments:
- Compiled versions of NeoLemmix will be placed in the subfolder "bin".


