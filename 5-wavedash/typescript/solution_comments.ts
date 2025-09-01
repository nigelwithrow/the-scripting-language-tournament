/*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 4 - Wavedash
  Date: 1st September 2025

  Entry:  Typescript
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ cd 5-wavedash/typescript`
  + `$ yarn`
  + `$ yarn tsc`
  + `$ node solution.js`
*/
type building = {
  xstart: number,
  xend: number,
  height: number,
}
type jump = {
  angle: number,
  time: number,
}

const G = 9.81
const U = 10.
const deg_to_radians = (x: number) => (x / 180) * Math.PI

const dx_after_t = (v0: number, rad: number, t: number) => v0 * Math.cos(rad) * t
const dy_after_t = (v0: number, rad: number, t: number) =>
  v0 * Math.sin(rad) * t - (G * Math.pow(t, 2) / 2)
const jump_for_t = (
  t: number,
  [x, y]: [number, number],
  v0: number,
  rad: number
): [number, number] =>
  [x + dx_after_t(v0, rad, t), y + dy_after_t(v0, rad, t)]

function solve(buildings: building[], goal: number) {

  // Find the tallest building
  let max_building_height: number | undefined;
  for (let { height } of buildings) {
    max_building_height = (max_building_height) ? Math.max(max_building_height, height) : height;
  }
  if (!max_building_height)
    throw new Error("No buildings passed");
  console.log("Max building height: ", max_building_height);

  // Find the number of 0-deg jumps needed to clear the horizontal distance from x=0 to x=goal
  const hor_dist_per_jump = U // u*cos(theta) = u for theta = 0
  const num_hor_jumps = Math.ceil(goal / hor_dist_per_jump)

  // Find the total decrease in height brought about by `num_hor_jumps` jumps
  const fall_per_hor_jump = G / 2 // g * t ^ 2 / 2 = g / 2 for t = 1
  const descent_hor_jumps = fall_per_hor_jump * num_hor_jumps

  // Find sum of the height of the tallest building and `descent_hor_jumps`
  const ascent_vert_jumps = max_building_height + descent_hor_jumps

  // Find the number of 90-deg jumps needed to reach a height of `ascent_vert_jumps`
  const rise_per_vert_jump = U - (G / 2.0) // u * sin(theta) - g * t ^ 2 / 2 = u - g / 2 for theta = 90 & t = 1
  const num_vert_jumps = Math.ceil(ascent_vert_jumps / rise_per_vert_jump)

  /*
  Assemble jumps:
    1. Make `num_vert_jumps` 90 - deg 1 - sec jumps to reach a height of`ascent_vert_jumps`
    2. Make `num_hor_jumps` 0 - deg 1 - sec jumps to reach x = goal without being blocked by any building
  */
  return (Array(num_vert_jumps) as jump[]).fill({ angle: 90, time: 1 })
    .concat((Array(num_hor_jumps)).fill({ angle: 0, time: 1 }))
}

const pos: [number, number] = [0, 0];
solve([
  { xstart: 2, xend: 4, height: 3 }, { xstart: 5, xend: 6, height: 4 },
], 10)
  .forEach(({ angle, time }, i) => {
    const [x, y] = pos
    const [x_, y_] = jump_for_t(time, [x, y], U, deg_to_radians(angle))
    console.log(`Jump ${i + 1}: ${angle} degrees, ${time} seconds, New position: (${x_}, ${y_})`)

    pos[0] = x_
    pos[1] = y_
  })
