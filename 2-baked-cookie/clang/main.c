// 281 tokens
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

void transform(int w, int h, int *x, int *y) {
    if (*y >= h / 2) {
        // Bottom half
        *y = *y * 2 - h + *x % 2;
        *x = *x / 2;
    } else {
        // Top half
        *y = *y * 2 + *x % 2;
        *x = *x / 2 + w / 2;
    }
}

int main() {
    int w, h, channels;
    unsigned char *data = stbi_load("baked.png", &w, &h, &channels, 0);
    unsigned char *new_data = malloc(w * h * channels);

    const int iterations = 4;
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int nx = x, ny = y;
            for (int i = 0; i < iterations; i++) transform(w, h, &nx, &ny);
            for (int i = 0; i < channels; i++)
                new_data[(nx + ny * w) * channels + i] = data[(x + y * w) * channels + i];
        }
    }

    stbi_write_png("unbaked.png", w, h, channels, new_data, w * channels);
    stbi_image_free(data);
    return 0;
}
