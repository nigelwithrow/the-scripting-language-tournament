import { Jimp, Bitmap } from "jimp";

const image = await Jimp.read("baked.png")
const permutation = [15, 7, 11, 3, 13, 5, 9, 1, 14, 6, 10, 2, 12, 4, 8, 0];
const blockHeight = image.height / permutation.length;

let lines = new Array(image.height);
const stride = image.bitmap.data.length / image.bitmap.height;
for (let y = 0; y < image.height; y++) {
  const line = image.bitmap.data.slice(y * stride, y * stride + stride);
  const index = y % blockHeight * permutation.length + permutation[Math.floor(y / blockHeight)];
  lines[index] = line;
}

Jimp.fromBitmap({
  width: image.width * permutation.length,
  height: image.height / permutation.length,
  data: Buffer.concat(lines),
})
.resize({ w: image.width, h: image.height })
.write("unbaked.png");

