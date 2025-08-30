require "lib/navigation_optimal"

module SVG
	SCALE = 8

	def self.export(filename, rects, goal)
		xmin = rects.min { |a, b| a[0] <=> b[0] }
		xmax = rects.max { |a, b| a[0]+a[2] <=> b[0]+b[2] }
		path = NavigationOptimal.find_path [0, 0], [0, goal], rects
		h = goal * SCALE
		w = (xmax[0] + xmax[2] - xmin[0]) * SCALE
		svg = File.open filename, 'w'
		svg.write "<svg xmlns='http://www.w3.org/2000/svg' width='#{w}' height='#{h}'>\n"
		rects.each { |r|
			x, y, w, h = r.map { |v| v*SCALE }
			x -= xmin[0] * SCALE
			svg.write "\t<rect x='#{x}' y='#{y}' width='#{w}' height='#{h}' fill='#000' stroke='none' />\n"
		}
		svg.write "\t<polyline fill='none' stroke='#f00' stroke-width='#{SCALE}' points='"
		path.each { |p|
			x, y = p.map { |v| v*SCALE }
			x -= xmin[0] * SCALE
			svg.write "#{x} #{y} "
		}
		svg.write "' />\n</svg>\n"
		svg.close
	end
end
