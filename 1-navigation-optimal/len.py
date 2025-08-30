import math

path = [
    (0, 0),
    (35, 5),
    (60, 10),
    (60, 40),
    (59, 85),
    (44, 126),
    (0, 128),
]

sum = 0
for i in range(len(path) - 1):
    (x1, y1), (x2, y2) = path[i], path[i + 1]
    (x1, y1), (x2, y2) = (x1, y1), (x2, y2)
    sum += math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

print(sum) # Best: 147.308770139002

