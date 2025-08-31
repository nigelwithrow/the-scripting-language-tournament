#include <math.h>
#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint32_t xstart, xend, height;
} building;

const double g = -9.81, v = 10.0;

double deg(double rad) {
    return rad * 180.0 / M_PI;
}

double rad(double deg) {
    return deg * M_PI / 180.0;
}

double ydiff_to_angle(double ydiff) {
    return deg(asin((ydiff - g / 2.0) / v));
}

double angle_to_ydiff(double angle) {
    return sin(rad(angle)) * v + g / 2.0;
}

double xdiff_to_angle(double xdiff) {
    return deg(acos(xdiff / v));
}

double angle_to_xdiff(double angle) {
    return cos(rad(angle)) * v;
}

int main() {
    const uint32_t goal = 10;
    const building buildings[] = {
        { 2, 4, 3 },
        { 5, 6, 4 },
    };
    const size_t nbuildings = sizeof(buildings) / sizeof(buildings[0]);

    const double leap_angle = ydiff_to_angle(0.0);
    const double leap_distance = angle_to_xdiff(leap_angle);

    double x = 0.0, y = 0.0; // Current position
    size_t building = 0; // Current building
    uint32_t time = 0;
    while (building < nbuildings) {
        while (building + 1 < nbuildings && (buildings[building + 1].height - y) / (buildings[building + 1].xstart - x) > (buildings[building].height - y) / (buildings[building].xstart - x)) building++;
        const double xdiff = buildings[building].xstart - x;
        const double ydiff = buildings[building].height - y;
       
        for (size_t jumps = 1;; jumps++) {
            double angle = xdiff_to_angle(xdiff / jumps);
            const double yinc = angle_to_ydiff(angle) * jumps;
            if (yinc > ydiff) {
                for (size_t i = 0; i < jumps; i++)
                    printf("(%u, %f), ", time++, angle);
                x += xdiff;
                y += yinc;
                break;
            }
        }

        while (building < nbuildings && buildings[building].height < y)
            building++;
    }

    while (x < buildings[nbuildings - 1].xend) {
        printf("(%u, %f), ", time++, leap_angle);
        x += leap_distance;
    }

    printf("(%u, %f)", time, 0.0);
    return 0;
}
