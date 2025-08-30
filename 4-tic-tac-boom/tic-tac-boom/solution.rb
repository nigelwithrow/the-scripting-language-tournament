LINES = [
	[0, 1, 2],
	[3, 4, 5],
	[6, 7, 8],
	[0, 3, 6],
	[1, 4, 7],
	[2, 5, 8],
	[0, 4, 8],
	[2, 4, 6],
]
$line = nil

def check(board, line)
	a, b, c = board[line[0]], board[line[1]], board[line[2]]
	"Xx".include?a or "Xx".include?b or "Xx".include?c
end

def move(board)
	lines = LINES.filter { |line| not check board, line }
	$line = lines[Random.rand(lines.length)] if not lines.include?$line
	points = [$line[0], $line[2], $line[1]]
	points = points.filter { |p| not "Oo".include?board[p] }
	# points[Random.rand(points.length)]
	points[-1]
end
