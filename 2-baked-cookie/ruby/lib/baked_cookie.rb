require "mini_magick"

module BakedCookie
	include MiniMagick

	def self.bakers_map(x, y, w, h)
		if y < h / 2
			x = (x+w)/2
			y = y*2+x%2
		else
			x = x/2
			y = y*2+x%2-h
		end
		[(x%w).to_i, (y%h).to_i]
	end

	def self.unbake(filename, iter)
		image = Image.new filename
		pixels = image.get_pixels
		unbaked = Array.new(image.width) { Array.new(image.height) { [0, 0, 0] } }
		image.width.times { |x|
			image.height.times { |y|
				ox, oy = [x, y]
				iter.times {
					ox, oy = bakers_map ox, oy, image.width, image.height
				}
				unbaked[x][y] = pixels[ox][oy]
			}
		}
		result = Image.get_image_from_pixels unbaked, image.dimensions, 'rgb', 8, 'png'
		result.write "assets/unbaked.png"
	end
end
