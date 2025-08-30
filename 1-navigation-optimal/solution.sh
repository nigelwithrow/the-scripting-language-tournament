#!/usr/bin/env bash
goal=128
rects=(
    "-5, 102, 49, 24"
    "-17, 100, 10, 20"
    "-25, 87, 38, 9"
    "-60, 98, 36, 23"
    "-62, 3, 10, 47"
    "-61, 53, 45, 25"
    "-59, 81, 32, 15"
    "-23, 80, 82, 5"
    "9, 5, 26, 33"
    "30, 40, 8, 10"
    "-41, 5, 22, 18"
    "-45, 33, 12, 14"
    "46, 10, 14, 30"
)

points=()
for rect in "${rects[@]}"; do
	rect=(${rect//,/})
	points+=(
		"${rect[0]} ${rect[1]}"
		"${rect[0]} $((rect[1] + rect[3]))"
		"$((rect[0] + rect[2])) ${rect[1]}"
		"$((rect[0] + rect[2])) $((rect[1] + rect[3]))"
	)
done

function slope() {
	p1=($1)
	p2=($2)
	if [[ ${p2[1]} == ${p1[1]} ]]; then
		echo $(( (p2[0] - p1[0]) * 10000 ))
		return
	fi
	echo $(( (p2[0] - p1[0]) * 10000 / (p2[1] - p1[1]) ))
}

current=(0 0)
echo "${current[@]}"
while [[ ${current[1]} != $goal ]]; do
	next=(0 $goal)
	for point in "${points[@]}"; do
		point=($point)
		if [[ ${point[1]} -le ${current[1]} ]]; then continue; fi

		old_slope=$(slope "${current[*]}" "${next[*]}")
		new_slope=$(slope "${current[*]}" "${point[*]}")
	
		if [[ $new_slope -gt $old_slope ]]; then
			next=(${point[@]})
		fi
	done
	echo "${next[@]}"
	current=(${next[@]})
done
