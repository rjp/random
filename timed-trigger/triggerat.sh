IV=${1:-20}
shift
COM=${@:-date}
boot=$((SECONDS % IV))
time=$(($(date +%s) % IV))
offset=$((IV-(time-boot)))
echo "boot=$boot time=$time offset=$offset"

IV_T1=$((IV-2))
IV_T2=$((IV-1))

while [ 1 ]; do
	while [ $(((SECONDS-offset) % IV)) -lt $IV_T1 ]; do sleep 1; done
	while [ $(((SECONDS-offset) % IV)) -lt $IV_T2 ]; do echo >/dev/null; done
	sleep 1
	$COM || exit
done
