#!/bin/sh
location=""
unit="f"

dcond=0
dfore=0
dss=0
ddays=5

data=""

usage() {
	echo "Usage: $0 [-h] [-l locations] [-u unit] [-a | -c | -d day | -s]"
}

read_conf() {
if [ -e ~/.weather.conf ]; then
	while read line; do
		field=`echo $line | cut -f 1 -d "="`
		value=`echo $line | cut -f 2 -d "="`
		if [ $field = "location" ]; then
			location=$value
		elif [ $field = "unit" ]; then
			unit=$value
		elif [ $field = "condition" ] && [ $value = "true" ]; then
			dcond=1;
		fi
	done < ~/.weather.conf
fi
}

read_forecast() {
	for i in 1 2 3 4 5
	do
		if [ $i -le $ddays ]; then
			text=`echo "$data" | grep "<yweather" | grep forecast | head -$i | tail -1 | tr '\"' '\n'`
			date=`echo "$text" | head -8 | tail -1`
			wkday=`echo "$text" | head -6 | tail -1`
			low=`echo "$text" | head -10 | tail -1`
			high=`echo "$text" | head -12 | tail -1`
			cond=`echo "$text" | head -14 | tail -1`
			echo "$date $wkday $low °$symb ~ $high °$symb $cond"
		fi
	done
}

read_condition() {
	city=`echo "$data" | grep location | tr '\"' '\n' | head -4 | tail -1`
	cond=`echo "$data" | grep condition | tr '\"' '\n' | head -6 | tail -1`
	temp=`echo "$data" | grep condition | tr '\"' '\n' | head -10 | tail -1`
	echo "$city, $cond, $temp °$symb"
}

read_sunriseset() {
	text=`echo "$data" | grep astronomy | tr '\"' '\n'`
	sunrise=`echo "$text" | head -4 | tail -1`
	sunset=`echo "$text" | head -6 | tail -1`
	echo "sunrise: $sunrise, sunset: $sunset"
}

read_conf
#read_arg
while getopts "hl:u:acd:s" option; do
	case "$option" in
		h)
			usage
			exit 0
			;;
		l)
			location="$OPTARG"
			;;
		u)
			unit="$OPTARG"
			;;
		a)
			dcond=1
			dfore=1
			dss=1
			;;
		c)
			dcond=1
			;;
		d)
			dfore=1
			ddays=$OPTARG
			;;
		s)
			dss=1
			;;
	esac
done
if [ "$unit" == "c" ]; then
	symb="C"
else
	symb="F"
fi

#check for invalid arguments
if [ -z "$location" ]; then
	echo "Must specify location"
	exit 1
elif [ $dcond -eq 0 ] && [ $dfore -eq 0 ] && [ $dss -eq 0 ]; then
	echo "Must specify type of information"
	exit 1
fi

#check for single location
ind=`echo "$location" | awk '{ print index($0, ","); }'`
if [ $ind -gt 0 ]; then
	mul=1
else
	mul=0
fi

j=1
tmp=`echo "$location" | cut -f"$j" -d ","`
while [ -n "$tmp" ]; do
#	echo "$tmp"
	data=`curl -s -G "https://query.yahooapis.com/v1/public/yql?diagnostics=true" \
		--data-urlencode "q=select * from weather.forecast where woeid in (select woeid from geo.places where text=\"$tmp\")" \
		--data "u=$unit" \
		| tr ">" "\n" | grep "<yweather"`
#	echo "$data"
	if [ $dcond -eq 1 ]; then
		read_condition
	fi
	if [ $dfore -eq 1 ]; then
		read_forecast
	fi
	if [ $dss -eq 1 ]; then
		read_sunriseset
	fi
	
	if [ $mul -eq 0 ]; then
		break
	fi
	j=$(( $j + 1 ))
	tmp=`echo "$location" | cut -f"$j" -d ","`
done

