@Tournament Participant

## _Wavedash_
> \- Let's go! - you scream after winning another game of vanishing Tic-Tac-Toe,
> and right after you feel yourself getting pulled out.
> \- What happened? - You see Nerd and other langauges in front of you
> \- It was a honeypod. - Nerd says - When I realized it was too late.
> But after the portal closed, Steave was passing by - he points at a man in the
> corner, who you didn't even notice - he pulled out his diamond pickaxe
> and we could enter. - Only now you realize that you were in that building.
> \- I scanned through the computer here and there is some cool software.
> I'll take a look at it later, how about we race back? - Nerd tags you and runs away.

Nerd taught you a new ability - dash. And you decided to only use it for your way back.
You can only dash with the power of 10, you will be able to dash again after
at least one second (red part of the graph). You can dash in the air.
The map consists of buildings blocking your way. Each one is defined by (xstart, xend, height).
You start on (0, 0), your goal is to cross `x = goal`.
You are not allowed to go through the side of the building
(don't break through windows, or you will have to pay _5 dollars, 3 quarters, 2 dimes and 4 pennies_),
however you can step on the roof (but you'll have to dash again immediately).
Output all the angles and times you will use.
Visualization of one dash, so you can hopefully understand: https://www.desmos.com/calculator/ei9hwms5o6

I hope this does a better job at explaining: https://www.desmos.com/calculator/bbafnacmaf

### Scoring
This challenge will be scored using the following formula:
```python
((8 / time) * 3 + min(250 / token_count, 1) + elegance_score) / 5
```

#### Results
|  Language  | Time | Token | Elegance | **Result** |
| ---------- | ---- | ----- | -------- | ---------- |
| OCaml      | 1.60 |  0.83 |   0.80   |    0.65    |
| TypeScript | 1.60 |  0.92 |   0.90   |    0.68    |
| BASH       | 2.46 |  1.00 |   0.60   |    0.81    |
| C          | 2.86 |  0.53 |   0.80   |    0.84    |
| Ruby       | 2.42 |  0.87 |   0.90   |    0.84    |

Final test: https://www.desmos.com/calculator/jknjjmc10r

