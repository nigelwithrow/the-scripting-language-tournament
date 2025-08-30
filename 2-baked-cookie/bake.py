from PIL import Image
import numpy as np

def bake(img):
    w, h = img.size
    img = np.array(img)
    l, r = img[:, :w//2], img[:, w//2:]
    i2 = Image.fromarray(np.vstack((r, l)))
    i2 = i2.resize((w, h), Image.Resampling.BICUBIC)
    return i2

def unbake(img):
    w, h = img.size
    img = np.array(img)
    t, b = img[:h//2, :], img[h//2:, :]
    i2 = Image.fromarray(np.hstack((b, t)))
    i2 = i2.resize((w, h), Image.Resampling.BICUBIC)
    return i2

image = Image.open("raw.png")
iterations = 4

for _ in range(iterations):
    image = bake(image)

image.save("baked.png")

for _ in range(iterations):
    image = unbake(image)
image.save("unbaked.png")
