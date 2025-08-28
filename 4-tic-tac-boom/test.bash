# play until O loses
count=0
while true; do
  ((count++))
  output=$(./target/release/tic-tac-boom ./solution.js)
  winner=$(echo "$output" | tail -n 1)
  if [ "$winner" = "Winner: x" ]; then
    echo "$output"
    echo
    echo "Failed at $count"
    break
  fi
done
