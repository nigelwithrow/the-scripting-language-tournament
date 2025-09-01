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

function solve(buildings: building[], goal: number) {
  let max_building_height: number | undefined;
  for (let { height } of buildings)
    max_building_height = (max_building_height) ? Math.max(max_building_height, height) : height;
  if (!max_building_height)
    throw new Error("No buildings passed");
  const hor_dist_per_jump = U
  const num_hor_jumps = Math.ceil(goal / hor_dist_per_jump)
  const fall_per_hor_jump = G / 2
  const descent_hor_jumps = fall_per_hor_jump * num_hor_jumps
  const ascent_vert_jumps = max_building_height + descent_hor_jumps
  const rise_per_vert_jump = U - (G / 2.0)
  const num_vert_jumps = Math.ceil(ascent_vert_jumps / rise_per_vert_jump)

  return (Array(num_vert_jumps) as jump[]).fill({ angle: 90, time: 1 })
    .concat((Array(num_hor_jumps)).fill({ angle: 0, time: 1 }))
}

solve([
  { xstart: 2, xend: 4, height: 3 }, { xstart: 5, xend: 6, height: 4 },
], 10)
  .forEach(({ angle, time }, i) => console.log(`(${angle}, ${time})`))

