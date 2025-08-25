function move(board: string): number {
  print(board);
  for (let i = 0; i < 9; i++) {
    if (board[i] == ' ') return i;
  }
  return 0;
}
