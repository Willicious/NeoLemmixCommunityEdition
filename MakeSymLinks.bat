REM ==== this creates and populates all necessary folders for NL-CE to run ====

if not exist "bin" mkdir "bin"

mklink /J bin\data data\external\data
mklink /J bin\gfx data\external\gfx
mklink /J bin\music data\external\music
mklink /J bin\rulers data\external\rulers
mklink /J bin\sounds data\external\sounds
mklink /J bin\styles data\external\styles
mklink /H bin\bass.dll data\external\bass.dll
mklink /H bin\NLPackerDefaultData.ini data\external\NLPackerDefaultData.ini

if not exist "bin\levels" mkdir "bin\levels"
mklink /J "bin\levels\Lemmings_Redux" "data\external\levels\Lemmings_Redux"
mklink /J "bin\levels\NeoLemmix_Introduction_Pack" "data\external\levels\NeoLemmix_Introduction_Pack"
mklink /J "bin\levels\Original_Lemmings" "data\external\levels\Original_Lemmings"
