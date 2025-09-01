#!/usr/bin/env bash
goal=10
buildings=(
	"2 4 3"
	"5 6 4"
)

y=0
t=0
for building in "${buildings[@]}"; do
	building=(${building//,/})

	while [ "$y" -lt "${building[2]}" ]; do
		y=$((y+5))
		printf "(%d, 90), " $t
		t=$((t+1))
	done
done

x=0
goal=$((goal * 10))
while [ "$x" -lt "$goal" ]; do
	x=$((x+87))
	printf "(%d, 29.4), " $t
	t=$((t+1))
done
printf "(%d, 0)\n" $t
