module NavigationOptimal
	def self.collision?(a, b)
		((ax1, ay1), (ax2, ay2)), ((bx1, by1), (bx2, by2)) = a, b
		u = (ax2-ax1)*(by2-by1) - (bx2-bx1)*(ay2-ay1)
		if u != 0
			ua = ((bx2-bx1)*(ay1-by1) - (by2-by1)*(ax1-bx1))/u
			ub = ((ax2-ax1)*(ay1-by1) - (ay2-ay1)*(ax1-bx1))/u
			0 <= ua and ua <= 1 and 0 <= ub and ub <= 1
		else
			false
		end
	end

	def self.collision(a, b)
		((ax1, ay1), (ax2, ay2)), ((bx1, by1), (bx2, by2)) = a, b
		u = (ax2-ax1)*(by2-by1) - (bx2-bx1)*(ay2-ay1)
		if u != 0
			ua = ((bx2-bx1)*(ay1-by1) - (by2-by1)*(ax1-bx1))/u
			ub = ((ax2-ax1)*(ay1-by1) - (ay2-ay1)*(ax1-bx1))/u
			if 0 <= ua and ua <= 1 and 0 <= ub and ub <= 1
				[ax1+ua*(ax2-ax1), ay1+ua*(ay2-ay1)]
			end
		end
	end

	def self.walls(rect)
		x, y, w, h = rect
		[
			[[x,y], [x+w,y]],   # top
			[[x,y], [x,y+h]],   # left
			[[x+w,y], [x+w,y+h]], # right
			[[x,y+h], [x+w,y+h]], # bottom
		]
	end

	def self.path_length(w)
		l = 0
		n = w.shift
		w.each { |p|
			(x1, y1), (x2, y2) = n, p
			x = x2 - x1
			y = y2 - y1
			l += Math.sqrt x*x + y*y
			n = p
		}
		l
	end

	def self.find_path(s, e, rects)
		path = [s]
		byside = []
		rects = rects.sort_by { |r| r[1] }
		rects.each { |rect|
			x, y, w, h = rect
			t, l, r, b = walls rect
			if collision? [path[-1], e], t
				cx, cy = collision [path[-1], e], t
				(rx, _), (lx, _) = t
				if cx-lx == rx-cx
					lp = find_path path[-1], l[0], byside
					rp = find_path path[-1], r[0], byside
					nl, nr = path_length(lp), path_length(rp)
					wp = nl < nr ? lp : rp
					p = nl < nr ? l[1] : r[1]
				else
					p = cx-lx > rx-cx ? r[0] : l[0]
					wp = find_path path[-1], p, byside
					p = cx-lx > rx-cx ? r[1] : l[1]
					wp.shift
				end
				path += wp << p
				byside = []
			elsif collision? [path[-1], e], l
				w = find_path path[-1], l[1], byside
				w.shift
				path += w
			elsif collision? [path[-1], e], r
				w = find_path path[-1], l[1], byside
				w.shift
				path += w
			else
				byside << rect
			end
		}
		path << e
	end
end
