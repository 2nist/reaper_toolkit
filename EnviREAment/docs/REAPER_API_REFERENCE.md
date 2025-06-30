# REAPER ReaScript API Reference

This document outlines the simulated REAPER API functions available in the EnviREAment virtual environment (`enhanced_virtual_reaper.lua`).

## Tempo & Time Signature
- `GetTempoTimeSigMarker(proj, index) -> time, measurepos, beatpos, bpm, timesig_num, timesig_denom, linear`
- `GetProjectTimeSignature2(proj) -> timesig_num, timesig_denom`
- `SetProjectTimeSignature2(proj, timesig_num, timesig_denom)`
- `GetTempo(proj) -> bpm`
- `GetTempoAtTime(time) -> bpm`
- `SetTempoTimeSigMarker(proj, index, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, linear)`
- `AddTempoTimeSigMarker(proj, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, linear) -> idx`
- `DeleteTempoTimeSigMarker(proj, index)`
- `CountTempoTimeSigMarkers(proj) -> count`
- `TimeMap_GetDividedBpmAtTime(proj, time, div) -> bpm`
- `TimeMap_GetBpmAtTime(proj, time) -> bpm`
- `TimeMap2_timeToBeats(proj, time) -> beats`
- `TimeMap2_beatsToTime(proj, beats) -> time`

## TODO
Add additional categories:
- Track & Media Items
- FX & Envelopes
- Markers & Regions
- MIDI API
- SWS/JS Extensions
