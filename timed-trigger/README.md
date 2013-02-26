# Timed trigger

## How you call it

    ./triggerat.sh [interval] [command]

## What it does

Reliably triggers command (which obviously needs to take less time than `interval`) when `$time % interval == 0`.

I've been using this to trigger my webcam fetches at 00,20,40 seconds and it's only missed one (21 instead of 20) out of 94,000 events.

## How it works

First we get the offset between system time in seconds and the `$SECONDS` variable provided to us by bash - this avoids a certain amount of CPU / IO involved in running the date command frequently.

Then we sleep our way in one second increments until it's almost time to trigger (2 seconds before) and drop into a busy wait until it's almost-almost time to trigger (1 second before).  Then we sleep for 1 second before triggering our command.

On my (mildly loaded) odroidx, even a 2s interval works reliably over 2000+ iterations.
