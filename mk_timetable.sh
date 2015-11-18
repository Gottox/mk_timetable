#! /bin/bash
export LC_ALL=C

year=$1
month=$(($2))
month_name="$(date -d "1-Dec-1970 +$month months" +"%b")"
weekdays=$(printf '%s\|' $3 | sed "s/\\\|$//")
starthour=$4
hours_per_month=$5
name=$6
free="$(curl "http://feiertage.jarmedia.de/api/?jahr=$year&nur_daten=1" | json_pp | grep -a -v "^[{}]$" | cut -d'"' -f 4)
$year-12-24
$year-12-27
$year-12-28
$year-12-29
$year-12-30
$year-12-31"

dates=$(printf "1-$month_name-$year +%s days\n" `seq 0 6` | xargs -d'\n' -n1 date -d | grep "^\($weekdays\) ")

workdates=$(for i in $(seq 0 5); do
	echo "$dates" | xargs -d'\n' printf "%s +$i weeks\n" | xargs -d'\n' -n1 date -d
done | while read; do
	date -d "$REPLY" +"%b" | grep -q "^$month_name$" || continue;
	date=$(date +"%Y-%m-%d" -d "$REPLY")
	grep -q "^$date$" <<< "$free" && continue;
	echo "$REPLY"
done)

input=$(cat input.svg)
workdatescnt=$(wc -l <<< "$workdates")
i=0
while read; do

	hours=$(($hours_per_month / $workdatescnt))
	hours_per_month=$(($hours_per_month - $hours))
	workdatescnt=$(($workdatescnt - 1))

	fdate=$(date +"%d.%m.%Y" -d "$REPLY")
	fstart=$(date +"%H:%M" -d "$REPLY +$starthour hours")
	endhour=$(($starthour + $hours))
	fend=$(date +"%H:%M" -d "$REPLY +$endhour hours")
	i=$(($i+1))

	input=$(sed "s#%DATUM$i%#$fdate#; s#%BEGIN$i%#$fstart#; s#%ENDE$i%#$fend#; s#%ZEIT$i%#$hours#;" <<< "$input")
done <<< "$workdates"

i="[0-9]\+"
input=$(sed "s#%DATUM$i%##; s#%BEGIN$i%##; s#%ENDE$i%##; s#%ZEIT$i%##; s#%NAME%#$name $month_name $year#" <<< "$input")

echo "$input" > table-$year-$month.svg
inkscape -f table-$year-$month.svg -A table-$year-$month.pdf
