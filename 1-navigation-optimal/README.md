@Tournament Participant
Get ready for silly names :)
We'll start with something relatively standard and pretty boring.
But this will show your languages in action!

## _Navigation optimal_
> C, OCaml, Ruby, Typescript and BASH were sitting in a bar,
> when a stranger rushed in with a piece of paper in their hands.
> \- I'm Nerd and I need your help - he slammed the map on the table.

You are at `(0, 0)` on the map and you see a red cross on the very edge at `(0, goal)` (goal > 0).
But there are buildings blocking your way! Each one is a rectangle
described as `(x, y, width, height)` (0 < y and y + height < goal).
You want to find a set of points which form a path that you will follow,
you must not go through any buildings, as they will kick you out and possibly arrest.

Map will be inserted directly into variables (I will probably regret this).

### Sample
Here is a sample map:
```python
goal = 48
rects = [
    (-6, 10, 22, 8),
    (-18, 31, 22, 8),
]
```
and a sample solution:
```python
path = [
    (0, 0),
    (-7, 9),
    (-7, 19),
    (5, 30),
    (5, 40),
    (0, 48),
]
```
If you need more, they are pretty easy to make with an SVG editor
(I used https://boxy-svg.com/app/ with grid set to 1px and custom view box).
I also attached the sample map SVG.

### Scoring
This challenge will be scored using the following formula:
```python
(path_length/min_path_length + min(100 / runtime_ms, 1) + elegance_score) / 3
```

-# Italic text is used for references that only I can understand

#### Results
|  Language  | Path | Time | Elegance | **Result** |
----------------------------------------------------
| OCaml      | 1.00 | 1.00 |   0.80   |    0.93    |
| TypeScript | 0.59 | 1.00 |   0.70   |    0.76    |
| BASH       | 0.66 | 0.19 |   0.67   |    0.50    |
| C          | 1.00 | 1.00 |   0.80   |    0.93    |
| Ruby       | 0.88 | 0.91 |   0.83   |    0.87    |
