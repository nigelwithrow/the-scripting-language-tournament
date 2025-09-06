require "lib/wavedash"

module WavedashTest
	goal = 10
	buildings = [
		[2, 4, 3],
		[5, 6, 4],
	]

	dash = Wavedash.dash goal, buildings
	dash.each_index { |i| puts "(#{i}, #{dash[i]})" }
end
