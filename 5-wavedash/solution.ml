type building = { xstart : int; xend : int; height : int }
type input = { buildings : building list; goal : int }

let c_G = 9.
let c_V0 = 10.

module FloatMath = struct
  let ( + ) = Float.add
  let ( - ) = Float.sub
  let ( * ) = Float.mul
  let ( / ) = Float.div
  let ( ^ ) = Float.pow
end

open FloatMath

let dx_after_t v0 theta t = v0 * cos theta * t
let dy_after_t v0 theta t = (v0 * sin theta * t) - (c_G * (t ^ 2.) / 2.)

let jump_for_1s (x, y) v0 angle =
  (x + dx_after_t v0 angle 1., y + dy_after_t v0 angle 1.)

let solve { buildings; goal } =
  let rec solve' (x, y) goal = function
    | [] ->
        let jumps = ref [] in
        let angle = 0. in
        let rec jump_until_goal (x, y) =
          let x', y' = jump_for_1s (x, y) c_V0 angle in
          jumps := !jumps @ [ angle ];
          if x' >= goal then () else jump_until_goal (x', y')
        in
        jump_until_goal (x, y);
        !jumps
    | building :: xs ->
        let jump = _ in
        jump :: jump_once (_, _) goal xs
  in
  solve' (0, 0) goal buildings
