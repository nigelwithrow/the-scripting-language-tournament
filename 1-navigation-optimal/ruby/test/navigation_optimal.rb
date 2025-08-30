require "lib/navigation_optimal"
require "util/svg"

module NavigationOptimalTest
	puts "TODO: #{self.name} random generated testscases"

	cases = [
		{
			goal: 48,
			rects: [
				[-18, 31, 22, 8],
				[-6, 10, 22, 8],
			],
			path: [
				[0, 0],
				[-6, 10],
				[-6, 18],
				[4, 31],
				[4, 39],
				[0, 48],
			],
		},
		{
			goal: 48,
			rects: [
				[10, 10, 10, 10],
				[-10, 25, 20, 10],
			],
			path: [
				[0, 0],
				[-10, 25],
				[-10, 35],
				[0, 48],
			],
		},
		{
			goal: 100,
			rects: [
				[10, 10, 20, 40],
				[40, 40, 20, 40],
			],
			path: [
				[0, 0],
				[0, 100],
			],
		},
		{
			goal: 48,
			rects: [
				[10, 10, 10, 10],
				[-17, 100, 10, 20],
				[-25, 87, 38, 9],
				[-60, 98, 36, 23],
				[-62, 3, 10, 47],
				[-61, 53, 45, 25],
				[-59, 81, 32, 15],
				[-23, 80, 82, 5],
				[9, 5, 26, 33],
				[30, 40, 8, 10],
				[-41, 5, 22, 18],
				[-45, 33, 12, 14],
				[46, 10, 14, 30],
			],
			path: [
				[0, 0],
				[0, 128],
			],
		},
	]
	i = 0

	cases.each { |c|
		goal = c[:goal]
		rects = c[:rects]
		path = c[:path]
		result = NavigationOptimal.find_path([0,0], [0,goal], rects)
		puts "#{result}"
		if path == path
			puts "\e[1;32m#{self.name} OK!\e[0m"
			SVG.export "assets/sample#{i}.svg", rects, goal
		else
			STDERR.puts "\e[1;31m#{self.name} ERROR!\e[0m"
			exit 1
		end
		i += 1
	}
end
