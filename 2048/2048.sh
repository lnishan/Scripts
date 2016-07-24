#!/bin/sh

tempfile="$HOME/2048.tmp"
colwidth=5
key=""
rno=0
val=""
emp="     "
win=false
smtxt=""
sel=0
ingame=false

a00=$emp	a01=$emp	a02=$emp	a03=$emp
a10=$emp	a11=$emp	a12=$emp	a13=$emp
a20=$emp	a21=$emp	a22=$emp	a23=$emp
a30=$emp	a31=$emp	a32=$emp	a33=$emp

m00=false	m01=false	m02=false	m03=false
m10=false	m11=false	m12=false	m13=false
m20=false	m21=false	m22=false	m23=false
m30=false	m31=false	m32=false	m33=false

get_key() {
	stty cbreak -echo; key=$(dd bs=1 count=1 2>/dev/null); stty -cbreak echo
}

get_rand() {
	rno=`od -An -N2 -i /dev/random`
	rno=$(( $rno % $1 ))
}

install() {
	for i in 1 2 3 4 5
	do
		if [ ! -e "save_$i" ]; then
			touch save_$i
		fi
	done
}

welcome() {
	 dialog --ok-label "Play a Game" --msgbox "   _________    __  _________\n  / ____/   |  /  |/  / ____/\n / / __/ /| | / /|_/ / __/ \n/ /_/ / ___ |/ /  / / /___   \n\____/_/  |_/_/  /_/_____/\n\n   ___   ____  __ __  ____ \n  |__ \ / __ \/ // / ( __ )\n  __/ // / / / // /_/ __  |\n / __// /_/ /__  __/ /_/ / \n/____/\____/  /_/  \____/  " 16 34
}

gg() {
	 dialog --ok-label "You Win" --msgbox "   _____                            _         _       _   _                 \n  / ____|                          | |       | |     | | (_)                \n | |     ___  _ __   __ _ _ __ __ _| |_ _   _| | __ _| |_ _  ___  _ __  ___ \n | |    / _ \\| '_ \\ / _\` | '__/ _\` | __| | | | |/ _\` | __| |/ _ \\| '_ \\/ __|\n | |___| (_) | | | | (_| | | | (_| | |_| |_| | | (_| | |_| | (_) | | | \\__ \\\n  \\_____\\___/|_| |_|\\__, |_|  \\__,_|\\__|\\__,_|_|\\__,_|\\__|_|\\___/|_| |_|___/\n                     __/ |                                                  \n                    |___/                                                   " 16 85
}

save_game_ok() {
	dialog --ok-label "OK." --msgbox "Your game progress has been saved." 5 40
}

load_game_ok() {
	dialog --ok-label "OK." --msgbox "Game have been loaded." 5 40
}

save_menu() {
	smtxt=""
	for i in 1 2 3 4 5
	do
		data=`cat save_$i`
		if [ -z "$data" ]; then
			smtxt="$smtxt $i \"<NONE>\""
		else
			tme=`stat -f "%Sm" save_$i`
			smtxt="$smtxt $i \"$tme\""
		fi
	done
	smtxt="dialog --stdout --menu \"command line 2048 :: saves\" 20 50 6$smtxt"
	sel=`eval "$smtxt"`
}

save_game() {
	if $ingame; then
		save_menu
		if [ -n "$sel" ]; then
			printf "$a00\n$a01\n$a02\n$a03\n$a10\n$a11\n$a12\n$a13\n$a20\n$a21\n$a22\n$a23\n$a30\n$a31\n$a32\n$a33\n" > save_$sel
			save_game_ok
		fi
	fi
}

load_game() {
	save_menu
	data=`cat save_$sel`
	if [ -z "$data" ]; then
		clear_board
		ingame=false
		return
	fi
	a00=`echo "$data" | head -1 | tail -1`
	a01=`echo "$data" | head -2 | tail -1`
	a02=`echo "$data" | head -3 | tail -1`
	a03=`echo "$data" | head -4 | tail -1`
	a10=`echo "$data" | head -5 | tail -1`
	a11=`echo "$data" | head -6 | tail -1`
	a12=`echo "$data" | head -7 | tail -1`
	a13=`echo "$data" | head -8 | tail -1`
	a20=`echo "$data" | head -9 | tail -1`
	a21=`echo "$data" | head -10 | tail -1`
	a22=`echo "$data" | head -11 | tail -1`
	a23=`echo "$data" | head -12 | tail -1`
	a30=`echo "$data" | head -13 | tail -1`
	a31=`echo "$data" | head -14 | tail -1`
	a32=`echo "$data" | head -15 | tail -1`
	a33=`echo "$data" | head -16 | tail -1`
	ingame=true
	load_game_ok
}

clear_board() {
	win=false
	ingame=false
	a00=$emp	a01=$emp	a02=$emp	a03=$emp
	a10=$emp	a11=$emp	a12=$emp	a13=$emp
	a20=$emp	a21=$emp	a22=$emp	a23=$emp
	a30=$emp	a31=$emp	a32=$emp	a33=$emp
}

clear_merge() {
	m00=false	m01=false	m02=false	m03=false
	m10=false	m11=false	m12=false	m13=false
	m20=false	m21=false	m22=false	m23=false
	m30=false	m31=false	m32=false	m33=false
}

getn() {
	if [ $1 -eq 0 ] && [ $2 -eq 0 ]; then
		val=$a00
	elif [ $1 -eq 0 ] && [ $2 -eq 1 ]; then
		val=$a01
	elif [ $1 -eq 0 ] && [ $2 -eq 2 ]; then
		val=$a02
	elif [ $1 -eq 0 ] && [ $2 -eq 3 ]; then
		val=$a03
	elif [ $1 -eq 1 ] && [ $2 -eq 0 ]; then
		val=$a10
	elif [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
		val=$a11
	elif [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
		val=$a12
	elif [ $1 -eq 1 ] && [ $2 -eq 3 ]; then
		val=$a13
	elif [ $1 -eq 2 ] && [ $2 -eq 0 ]; then
		val=$a20
	elif [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
		val=$a21
	elif [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
		val=$a22
	elif [ $1 -eq 2 ] && [ $2 -eq 3 ]; then
		val=$a23
	elif [ $1 -eq 3 ] && [ $2 -eq 0 ]; then
		val=$a30
	elif [ $1 -eq 3 ] && [ $2 -eq 1 ]; then
		val=$a31
	elif [ $1 -eq 3 ] && [ $2 -eq 2 ]; then
		val=$a32
	elif [ $1 -eq 3 ] && [ $2 -eq 3 ]; then
		val=$a33
	fi
}

getm() {
	if [ $1 -eq 0 ] && [ $2 -eq 0 ]; then
		val=$m00
	elif [ $1 -eq 0 ] && [ $2 -eq 1 ]; then
		val=$m01
	elif [ $1 -eq 0 ] && [ $2 -eq 2 ]; then
		val=$m02
	elif [ $1 -eq 0 ] && [ $2 -eq 3 ]; then
		val=$m03
	elif [ $1 -eq 1 ] && [ $2 -eq 0 ]; then
		val=$m10
	elif [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
		val=$m11
	elif [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
		val=$m12
	elif [ $1 -eq 1 ] && [ $2 -eq 3 ]; then
		val=$m13
	elif [ $1 -eq 2 ] && [ $2 -eq 0 ]; then
		val=$m20
	elif [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
		val=$m21
	elif [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
		val=$m22
	elif [ $1 -eq 2 ] && [ $2 -eq 3 ]; then
		val=$m23
	elif [ $1 -eq 3 ] && [ $2 -eq 0 ]; then
		val=$m30
	elif [ $1 -eq 3 ] && [ $2 -eq 1 ]; then
		val=$m31
	elif [ $1 -eq 3 ] && [ $2 -eq 2 ]; then
		val=$m32
	elif [ $1 -eq 3 ] && [ $2 -eq 3 ]; then
		val=$m33
	fi
}

setn() {
	n=$3
	l=$(( $colwidth - ${#n} ))
	case "$l" in
		1)
			n=" $n"
			;;
		2)
			n=" $n "
			;;
		3)
			n="  $n "
			;;
		4)
			n="  $n  "
			;;
		5)
			n="   $n  "
	esac

	if [ $1 -eq 0 ] && [ $2 -eq 0 ]; then
		a00="$n"
	elif [ $1 -eq 0 ] && [ $2 -eq 1 ]; then
		a01="$n"
	elif [ $1 -eq 0 ] && [ $2 -eq 2 ]; then
		a02="$n"
	elif [ $1 -eq 0 ] && [ $2 -eq 3 ]; then
		a03="$n"
	elif [ $1 -eq 1 ] && [ $2 -eq 0 ]; then
		a10="$n"
	elif [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
		a11="$n"
	elif [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
		a12="$n"
	elif [ $1 -eq 1 ] && [ $2 -eq 3 ]; then
		a13="$n"
	elif [ $1 -eq 2 ] && [ $2 -eq 0 ]; then
		a20="$n"
	elif [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
		a21="$n"
	elif [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
		a22="$n"
	elif [ $1 -eq 2 ] && [ $2 -eq 3 ]; then
		a23="$n"
	elif [ $1 -eq 3 ] && [ $2 -eq 0 ]; then
		a30="$n"
	elif [ $1 -eq 3 ] && [ $2 -eq 1 ]; then
		a31="$n"
	elif [ $1 -eq 3 ] && [ $2 -eq 2 ]; then
		a32="$n"
	elif [ $1 -eq 3 ] && [ $2 -eq 3 ]; then
		a33="$n"
	fi
}

setm() {
	if [ $1 -eq 0 ] && [ $2 -eq 0 ]; then
		m00=true
	elif [ $1 -eq 0 ] && [ $2 -eq 1 ]; then
		m01=true
	elif [ $1 -eq 0 ] && [ $2 -eq 2 ]; then
		m02=true
	elif [ $1 -eq 0 ] && [ $2 -eq 3 ]; then
		m03=true
	elif [ $1 -eq 1 ] && [ $2 -eq 0 ]; then
		m10=true
	elif [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
		m11=true
	elif [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
		m12=true
	elif [ $1 -eq 1 ] && [ $2 -eq 3 ]; then
		m13=true
	elif [ $1 -eq 2 ] && [ $2 -eq 0 ]; then
		m20=true
	elif [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
		m21=true
	elif [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
		m22=true
	elif [ $1 -eq 2 ] && [ $2 -eq 3 ]; then
		m23=true
	elif [ $1 -eq 3 ] && [ $2 -eq 0 ]; then
		m30=true
	elif [ $1 -eq 3 ] && [ $2 -eq 1 ]; then
		m31=true
	elif [ $1 -eq 3 ] && [ $2 -eq 2 ]; then
		m32=true
	elif [ $1 -eq 3 ] && [ $2 -eq 3 ]; then
		m33=true

	fi
}


print_board() {
	dialog --infobox "+-------+-------+-------+-------+\n|       |       |       |       |\n| $a00 | $a01 | $a02 | $a03 |\n|       |       |       |       |\n+-------+-------+-------+-------+\n|       |       |       |       |\n| $a10 | $a11 | $a12 | $a13 |\n|       |       |       |       |\n+-------+-------+-------+-------+\n|       |       |       |       |\n| $a20 | $a21 | $a22 | $a23 |\n|       |       |       |       |\n+-------+-------+-------+-------+\n|       |       |       |       |\n| $a30 | $a31 | $a32 | $a33 |\n|       |       |       |       |\n+-------+-------+-------+-------+" 20 43
}

place_rand24() {
	if [ "$a00" != "$emp" ] && [ "$a01" != "$emp" ] && [ "$a02" != "$emp" ] && [ "$a03" != "$emp" ] && [ "$a10" != "$emp" ] && [ "$a11" != "$emp" ] && [ "$a12" != "$emp" ] && [ "$a13" != "$emp" ] && [ "$a20" != "$emp" ] && [ "$a21" != "$emp" ] && [ "$a22" != "$emp" ] && [ "$a23" != "$emp" ] && [ "$a30" != "$emp" ] && [ "$a31" != "$emp" ] && [ "$a32" != "$emp" ] && [ "$a33" != "$emp" ]; then
		echo "Full!" >> 2048.lo 
	else
		while :; do
			get_rand 4
			x=$rno
			get_rand 4
			y=$rno
			getn $x $y
			if [ "$val" == "$emp" ]; then
				break
			fi
		done
		get_rand 10
		if [ $rno -lt 9 ]; then
			setn $x $y "2"
		else
			setn $x $y "4"
		fi
	fi
}

left() {
	clear_merge
	drop=true
	while $drop; do
		drop=false
		for i in 0 1 2 3
		do
			for j in 0 1 2
			do
				getm $i $j
				mer1=$val
				getm $i $(( $j + 1 ))
				mer2=$val
				
				if ! $mer1 && ! $mer2; then
					getn $i $j
					val1=$val
					getn $i $(( $j + 1 ))
					val2=$val
					if [ "$val1" == "$emp" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$val2"
						setn $i $(( $j + 1 )) "$emp"
						drop=true
					elif [ "$val1" == "$val2" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$(( $val1 + $val2 ))"
						setn $i $(( $j + 1 )) "$emp"
						setm $i $j
					fi
				fi
			done
		done
	done
}

right() {
	clear_merge
	drop=true
	while $drop; do
		drop=false
		for i in 0 1 2 3
		do
			for j in 3 2 1
			do
				getm $i $j
				mer1=$val
				getm $i $(( $j - 1 ))
				mer2=$val
				
				if ! $mer1 && ! $mer2; then
					getn $i $j
					val1=$val
					getn $i $(( $j - 1 ))
					val2=$val
					if [ "$val1" == "$emp" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$val2"
						setn $i $(( $j - 1 )) "$emp"
						drop=true
					elif [ "$val1" == "$val2" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$(( $val1 + $val2 ))"
						setn $i $(( $j - 1 )) "$emp"
						setm $i $j
					fi
				fi
			done
		done
	done
}

up() {
	clear_merge
	drop=true
	while $drop; do
		drop=false
		for j in 0 1 2 3
		do
			for i in 0 1 2
			do
				getm $i $j
				mer1=$val
				getm $(( $i + 1 )) $j
				mer2=$val
				
				if ! $mer1 && ! $mer2; then
					getn $i $j
					val1=$val
					getn $(( $i + 1 )) $j
					val2=$val
					if [ "$val1" == "$emp" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$val2"
						setn $(( $i + 1 )) $j "$emp"
						drop=true
					elif [ "$val1" == "$val2" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$(( $val1 + $val2 ))"
						setn $(( $i + 1 )) $j "$emp"
						setm $i $j
					fi
				fi
			done
		done
	done
}

down() {
	clear_merge
	drop=true
	while $drop; do
		drop=false
		for j in 0 1 2 3
		do
			for i in 3 2 1
			do
				getm $i $j
				mer1=$val
				getm $(( $i - 1 )) $j
				mer2=$val
				
				if ! $mer1 && ! $mer2; then
					getn $i $j
					val1=$val
					getn $(( $i - 1 )) $j
					val2=$val
					if [ "$val1" == "$emp" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$val2"
						setn $(( $i - 1 )) $j "$emp"
						drop=true
					elif [ "$val1" == "$val2" ] && [ "$val2" != "$emp" ]; then
						setn $i $j "$(( $val1 + $val2 ))"
						setn $(( $i - 1 )) $j "$emp"
						setm $i $j
					fi
				fi
			done
		done
	done
}

check_win() {
	for i in 0 1 2 3
	do
		for j in 0 1 2 3
		do
			getn $i $j
			if [ "$val" != "$emp" ] && [ $val -eq 2048 ]; then
				win=true
			fi
		done
	done
}

game() {
	ingame=true
	while :; do
		print_board
		get_key
		if  [ "$key" == "q" ]; then
			break;
		else
			case "$key" in
				a)
					left
					;;
				d)
					right
					;;
				w)
					up
					;;
				s)
					down
					;;
			esac
			check_win
			if $win; then
				clear_board
				gg
				break;
			fi
			place_rand24
		fi
	done
}

echo > 2048.log

install

welcome

while :; do
	dialog --menu "Command line 2048" 20 50 5 N "New Game - Start a new 2048 game" R "Resume - Resume previous game" L "Load - Load from previous save game" S "Save - Save current game state" Q "Quit" 2> $tempfile 
	menukey=`cat $tempfile`
	if [ "$menukey" == "Q" ] || [ -z "$menukey" ]; then
		break
	else
		case "$menukey" in
			"N")
				clear_board
				place_rand24
				place_rand24
				game
				;;
			"R")
				if $ingame; then
					game
				fi
				;;
			"L")
				load_game
				;;
			"S")
				save_game
				;;
		esac
	fi
done
