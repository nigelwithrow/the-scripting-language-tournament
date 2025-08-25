#include <stdio.h>
int move(const char *board) {
    puts(board);
    for (int i = 0; i < 9; i++) {
        if (board[i] == ' ') return i;
    }
    return 0;
}
