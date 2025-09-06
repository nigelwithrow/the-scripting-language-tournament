module Wavedash
	V = 10
	G = -9.81

	def self.rad(a) Math::PI*a/180.0 end
	def self.deg(a) 180.0*a/Math::PI end

	def self.a2y(a) Math::sin(rad(a.to_f))*V+G*0.5 end
	def self.a2x(a) Math::cos(rad(a.to_f))*V end
	def self.y2a(y) deg(Math::asin((y.to_f-G*0.5)/V)) end
	def self.x2a(x) deg(Math::acos(x.to_f/V)) end

	def self.dash(goal, buildings)
		d = []
		# p = 0
		x,y = 0,0
		buildings.each { |b|
			dx, dy = b[0]-x, b[2]-y
			# t = dy/dx
			# if t <= p
			# 	p = t
			# 	next
			# end
			(1..Float::INFINITY).each { |j|
				if dx.to_f / j > V then next end
				if x == 6 then puts dx.to_f / j end
				a = x2a(dx.to_f/j)
				ay = a2y(a)*j
				if ay >= dy
					d += [a] * j
					x += dx
					y += ay
					break
				end
			}
			# p = t
		}
		la = y2a(0)
		ld = a2x(la)
		while x < buildings[-1][1]
			d << la
			x += ld
		end
		d << 0
	end
end
