type Cell = null | ["O", number] | ["X", number]

class Game {
  str: string
  board: Cell[]
  constructor() {
    this.str = " ".repeat(9)
    this.board = [null, null, null, null, null, null, null, null, null]
  }
  tickX() {
    for (let i = 0; i < 9; i++) {
      const cell = this.board[i]
      if (cell === undefined) throw new Error("unreachable at tickX")
      if (cell === null || (cell[0] === "X" && cell[1] === 1))
        this.board[i] = null
      else if (cell[0] === "X")
        this.board[i] = ["X", cell[1] - 1]
    }
  }
  tickO() {
    for (let i = 0; i < 9; i++) {
      const cell = this.board[i]
      if (cell === undefined) throw new Error("unreachable at tickO")
      if (cell === null || (cell[0] === "O" && cell[1] === 1))
        this.board[i] = null
      else if (cell[0] === "O")
        this.board[i] = ["O", cell[1] - 1]
    }
  }
  moveX(i: number) {
    if (this.board[i] !== null)
      throw new Error("X trying to play at occupied space")
    this.board[i] = ["X", 4]
  }
  moveO(i: number) {
    if (this.board[i] !== null)
      throw new Error("O trying to play at occupied space")
    this.board[i] = ["O", 4]
  }
  updateStr() {
    this.str = this.board.map((cell) => (cell === null) ? " " : cell[0]).join("")
  }
}

function match3(
  board: Cell[],
  [a, b, c]: [(c: Cell) => boolean, (c: Cell) => boolean, (c: Cell) => boolean]
): [number, number, number] | null {
  const permutations: [number, number, number][] = [
    [0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0],
    [3, 4, 5], [3, 5, 4], [4, 3, 5], [4, 5, 3], [5, 3, 4], [5, 4, 3],
    [6, 7, 8], [6, 8, 7], [7, 6, 8], [7, 8, 6], [8, 6, 7], [8, 7, 6],
    [0, 3, 6], [0, 6, 3], [3, 0, 6], [3, 6, 0], [6, 0, 3], [6, 3, 0],
    [1, 4, 7], [1, 7, 4], [4, 1, 7], [4, 7, 1], [7, 1, 4], [7, 4, 1],
    [2, 5, 8], [2, 8, 5], [5, 2, 8], [5, 8, 2], [8, 2, 5], [8, 5, 2],
    [0, 4, 8], [0, 8, 4], [4, 0, 8], [4, 8, 0], [8, 0, 4], [8, 4, 0],
    [2, 4, 6], [2, 6, 4], [4, 2, 6], [4, 6, 2], [6, 2, 4], [6, 4, 2],
  ]
  for (let i = 0; i < permutations.length; i++) {
    const permutation = permutations[i]
    if (!permutation)
      throw new Error("unreachable")
    const [a_, b_, c_] = permutation
    if (a(board[a_] as Cell) && b(board[b_] as Cell) && c(board[c_] as Cell))
      return [a_, b_, c_]
  }
  return null
}

const Strategy = {
  win: function(board: Cell[]) {
    if (board.length !== 9) throw new Error("board not length 9")
    return match3(board, [
      (c) => c === null,
      (c) => c !== null && c[0] == "O" && c[1] > 1,
      (c) => c !== null && c[0] == "O" && c[1] > 1,
    ])?.[0];
  },
  dontLose: function(board: Cell[]) {
    if (board.length !== 9) throw new Error("board not length 9")
    return match3(board, [
      (c) => c === null,
      (c) => c !== null && c[0] == "X" && c[1] > 1,
      (c) => c !== null && c[0] == "X" && c[1] > 1,
    ])?.[0];
  },
  dontGetTrapped: function(board: Cell[]) {
    if (board.length !== 9) throw new Error("board not length 9")
    return match3(board, [
      (c) => c === null,
      (c) => c !== null && c[0] == "O" && c[1] === 2,
      (c) => c !== null && c[0] == "X" && c[1] > 2,
    ])?.[0];
  },
  prepareWin: function(board: Cell[]) {
    if (board.length !== 9) throw new Error("board not length 9")
    return match3(board, [
      (c) => c === null,
      (c) => c === null || (c[0] == "X" && c[1] === 1),
      (c) => c !== null && c[0] == "O" && c[1] > 2,
    ])?.[0];
  },
  findEmpty: function(board: Cell[]) {
    let index = 0
    while (true) {
      if (board[index] === null)
        return index
      index = (index + 4) % 9;
    }
  }
}

function detectXMove(str: string, newStr: string): number | null {
  for (let i = 0; i < 9; i++) {
    if (str[i]?.toLowerCase() !== 'x' && newStr[i]?.toLowerCase() === 'x')
      return i
  }
  return null
}

const game = new Game()

function move(str_: string): number {
  const xMove = detectXMove(game.str, str_)
  if (xMove === null)
    throw new Error("X didn't play a move")
  game.moveX(xMove)
  game.tickX()
  const strategies = [
    Strategy.win,
    Strategy.dontLose,
    Strategy.dontGetTrapped,
    Strategy.prepareWin,
    Strategy.findEmpty
  ];
  let oMove: number | undefined
  for (let i = 0; i < strategies.length; i++) {
    oMove = strategies[i]?.(game.board)
    if (oMove !== undefined) break
  }
  if (oMove === undefined)
    throw new Error("Last strategy should always apply")
  game.moveO(oMove)
  game.tickO()
  game.updateStr()
  return oMove;
}
export { move }

