int last = -1;

void check_line(const char *board, int a, int b, int c, int *move, int *score) {
    // Sort
    int space, i1, i2;
    if (board[a] == ' ') space = a, i1 = b, i2 = c;
    else if (board[b] == ' ') space = b, i1 = a, i2 = c;
    else if (board[c] == ' ') space = c, i1 = a, i2 = b;
    else return;

    // Winning
    if (board[i1] == 'o' && board[i2] == 'o') {
        *move = space, *score = 0;
    }
    // if (tolower(board[i1]) == 'x' && tolower(board[i2]) == 'x') {
    //     if (*score > 1) *move = space, *score = 1;
    // }
    // 'oX ', we'll win next turn unless X will win sooner
    if ((board[i1] == 'o' && board[i2] == 'X' && i1 == last) || (board[i1] == 'X' && board[i2] == 'o' && i2 == last)) {
        if (*score > 2) *move = space, *score = 2;
    }
    // Just luckier
    // 'o  '
    if ((board[i1] == 'o' && board[i2] == ' ') || (board[i1] == ' ' && board[i2] == 'o')) {
        if (*score > 3) *move = space, *score = 3;
    }
    // '   '
    if (board[i1] == ' ' && board[i2] == ' ') {
        if (*score > 4) *move = space, *score = 4;
    }
    // Otherwise
    if (*score > 5) *move = space, *score = 5;
}

int move(const char *board) {
    int move = 0, score = 100;
    for (int i = 0; i < 3; i++) {
        check_line(board, i * 3, i * 3 + 1, i * 3 + 2, &move, &score);
        check_line(board, i, i + 3, i + 6, &move, &score);
    }
    check_line(board, 0, 4, 8, &move, &score);
    check_line(board, 2, 4, 6, &move, &score);
    last = move;
    return move;
}
