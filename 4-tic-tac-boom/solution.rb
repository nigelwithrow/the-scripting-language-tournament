def move(board)
  puts board
  for i in 0..5 do
    if board[i] == ' ' then
      return i
    end
  end
end
