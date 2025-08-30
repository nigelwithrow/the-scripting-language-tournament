#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

// Input
struct rect {
    int32_t x, y;
    uint32_t w, h;
};

const int32_t GOAL = 128;
const struct rect RECTS[] = {
    {-5, 102, 49, 24},
    {-17, 100, 10, 20},
    {-25, 87, 38, 9},
    {-60, 98, 36, 23},
    {-62, 3, 10, 47},
    {-61, 53, 45, 25},
    {-59, 81, 32, 15},
    {-23, 80, 82, 5},
    {9, 5, 26, 33},
    {30, 40, 8, 10},
    {-41, 5, 22, 18},
    {-45, 33, 12, 14},
    {46, 10, 14, 30},
};

const size_t NRECTS = sizeof(RECTS) / sizeof(RECTS[0]);

// Points
struct point {
    int32_t x, y;
    size_t next;
    double dst;
};

int point_cmp_y(const void *point1, const void *point2)  {
    int32_t y1 = ((struct point *)point1)->y;
    int32_t y2 = ((struct point *)point2)->y;
    if (y1 > y2) return  1;
    else if (y1 < y2) return -1;
    else return 0;
}

bool collision_check(struct point p1, struct point p2) {
    if (p1.y == p2.y) {
        for (size_t i = 0; i < NRECTS; i++) {
            if (p1.y <= RECTS[i].y || p1.y >= RECTS[i].y + RECTS[i].h) continue;
            int32_t tx1 = min(p1.x, p2.x), tx2 = max(p1.x, p2.x);
            if (tx1 < RECTS[i].x + RECTS[i].w && tx2 > RECTS[i].x) {
                return true;
            }
        }
        return false;
    }
    double slope = (double)(p2.x - p1.x) / (p2.y - p1.y);
    for (size_t i = 0; i < NRECTS; i++) {
        if (!(p1.y < RECTS[i].y + RECTS[i].h && p2.y > RECTS[i].y)) continue;
        int32_t ty1 = max(p1.y, RECTS[i].y), ty2 = min(p2.y, RECTS[i].y + RECTS[i].h);
        double tx1 = (ty1 - p1.y) * slope + p1.x, tx2 = (ty2 - p1.y) * slope + p1.x;
        if (tx1 > tx2) {
            double tmp = tx1;
            tx1 = tx2;
            tx2 = tmp;
        }
        if (tx1 < (double)RECTS[i].x + RECTS[i].w && tx2 > (double)RECTS[i].x) {
            return true;
        }
    }
    return false;
}

int main() {
    const size_t npoints = NRECTS * 4 + 2;
    struct point points[npoints];

    points[0] = (struct point) {0, 0};
    points[1] = (struct point) {0, GOAL};
    for (size_t i = 0; i < NRECTS; i++) {
        points[i * 4 + 2] = (struct point) {RECTS[i].x, RECTS[i].y};
        points[i * 4 + 3] = (struct point) {RECTS[i].x, RECTS[i].y + RECTS[i].h};
        points[i * 4 + 4] = (struct point) {RECTS[i].x + RECTS[i].w, RECTS[i].y};
        points[i * 4 + 5] = (struct point) {RECTS[i].x + RECTS[i].w, RECTS[i].y + RECTS[i].h};
    }

    qsort(points, npoints, sizeof(struct point), point_cmp_y);

    points[npoints - 1].dst = 0.0;
    for (ssize_t point = npoints - 2; point >= 0; point--) {
        points[point].dst = 1e10;
        for (size_t next = point + 1; next < npoints; next++) {
            if (collision_check(points[point], points[next])) {
                continue;
            }
            int32_t xdiff = points[next].x - points[point].x;
            int32_t ydiff = points[next].y - points[point].y;
            double dst = points[next].dst + sqrt(xdiff * xdiff + ydiff * ydiff);
            if (dst < points[point].dst) {
                points[point].dst = dst;
                points[point].next = next;
            }
        }
        
    }

    size_t p = 0;
    while (true) {
        printf("(%d, %d),\n", points[p].x, points[p].y);
        if (p == points[p].next || p == npoints - 1) break;
        p = points[p].next;
    }
    return 0;
}
