#!/bin/sh

sp=" ‎"

add ()
{
	var=$(ip route get 1 | awk '{print $(NF-2);exit}')
	echo " $var"
}

bat ()
{
	device="BAT1"
	var=$(cat /sys/class/power_supply/${device}/capacity)

	case $var in
		[0-9])  out=" $var%";;
		[1-7]?) out=" $var%";;
		*)      out=" 100%"
	esac
	echo "$out"
}

clk ()
{
	var=$(date +%H:%M\ %P)
	echo " $var"

}

dte ()
{
        var=$(date +%a\ %d\ %b)
        echo " $var"
}

ntw ()
{
	device=$(find /sys/class/net/ -name "wlp*" | grep -o '[^/]\+$')
	status=$(cat /sys/class/net/${device}/operstate)
	quality=$(grep ${device} /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')

	echo " ${quality}%"
}

vol ()
{
	#var=$(amixer get Master | awk '$0~/Left/{print $5}' | tr -d '[]-')
	var=$(amixer get Master | awk '$0~/Mono/{print $4}' | tr -d '[]-')
        echo " $var"
}

wth()
{
	API_KEY="4b3d1ed697c179a6961c7793305a250a"
	# Check on http://openweathermap.org/find
	CITY_ID="2507480"		
	WEATHER_URL="http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric"
	SYMBOL_CELSIUS="°"

	WEATHER_INFO=$(curl -s "${WEATHER_URL}")
	WEATHER_MAIN=$(echo "${WEATHER_INFO}" | grep -o -e '\"main\":\"[a-zA-Z]*\"' | awk -F ':' '{print $2}' | tr -d '"')
	WEATHER_TEMP=$(echo "${WEATHER_INFO}" | grep -o -e '\"temp\":\-\?[0-9]*' | awk -F ':' '{print $2}' | tr -d '"')

	case $WEATHER_MAIN in
		Clear)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Clouds)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Rain)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Drizzle)	out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Thunderstorm)	out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Snow)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Mist)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}";;
		Fog)		out=" ${WEATHER_TEMP}${SYMBOL_CELSIUS}"
	esac
	echo "$out"
}

cpu ()
{
	var=$(sensors | awk '/Core 0/ {print $3}')
	echo " $var"
}

mem ()
{
	var=$(free -h | awk '/Mem/ {print $3}')
	echo " $var"
}

hdd ()
{
	var=$(df -h | grep '/$' | awk '{print $5}')
	echo " $var"
}

while true
do
	BAR_INPUT="$(add) ${sp}‎ $(ntw) ${sp}‎ $(hdd) ${sp}‎ $(mem) ${sp}‎ $(cpu) ${sp}‎ $(bat) ${sp}‎ $(vol) ${sp}‎ $(wth) ${sp}‎ $(dte) ${sp}‎ $(clk) ${sp}‎ "
	echo $BAR_INPUT 2>/dev/null
	sleep 10s
done
