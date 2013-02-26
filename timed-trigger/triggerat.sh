#! /usr/bin/env bash

# This is probably better in an ENV than an argument
IV=${1:-20}
shift

# Almost certainly this will cause quoting nightmares
COM=${@:-date}

# Work out the offset between real time and 'local' time
boot=$((SECONDS % IV))
time=$(($(date +%s) % IV))
offset=$((IV-(time-boot)))

echo "boot=$boot time=$time offset=$offset"

# Constant-fold these out of the loop
TM2=$((IV-2))
TM1=$((IV-1))

while [ 1 ]; do
    # Sleep until TM2, busy wait until TM1
    while [ $(((SECONDS-offset) % IV)) -lt $TM2 ]; do sleep 1; done
    while [ $(((SECONDS-offset) % IV)) -lt $TM1 ]; do echo >/dev/null; done

    # This might get pre-empted and take longer than 1s
    # The alternative is more busy-waiting at the expense of CPU
    sleep 1

    # Run the command, quit if it fails
    $COM || exit
done
