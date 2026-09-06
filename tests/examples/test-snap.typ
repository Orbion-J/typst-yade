#import "@local/fletcher:0.6.0": *

// #set page(width: auto, height: auto, margin: 10%)


#let bend = -.5
#let bezier_point_func = (s, e) => {
  let (xs, ys, zs) = s
  let (xe, ye, ze) = e
  assert(zs == 0 and ze == 0, message: "Error: non-zero z coordinate")
  let dx = xe - xs
  let dy = ye - ys
  let d = calc.sqrt(dx * dx + dy * dy)
  let xcenter = xs + dx / 2
  let ycenter = ys + dy / 2
  let angle = if dx != 0 { calc.atan(dy / dx) } else { 90deg }
  let dxtop_sign = if dy > 0 { -1 } else { 1 }
  let dytop_sign = if dx > 0 { 1 } else { -1 }
  let dxtop = dxtop_sign * calc.abs(calc.sin(angle)) * bend * d
  let dytop = dytop_sign * calc.abs(calc.cos(angle)) * bend * d
  (xcenter + dxtop, ycenter + dytop, 0)
}
#let x = (0em, 0em)
#let y = (0em, -4em)
#diagram(
  node(x, $X'$, <x>),
  node(y, $Y'$, <y>),
  edge(stroke: green, snap-to: auto, <x>, <y>),
  debug: "edge.snap.from",
)
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  edge(<x>, <y>),
  debug: "edge.snap.from",
)
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  edge(<x>, <y>, stroke: green, snap-to: auto, draw: ((a, b)) => cetz.draw.line(
    a,
    b,
  )),
  debug: "edge.snap.from",
)
#diagram(
  node(x, $X'$, <x>),
  node(y, $Y'$, <y>),
  edge(<x>, <y>, stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
    a,
    b,
    bezier_point_func(a, b),
  )),
  debug: "edge.snap.from",
)
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  edge(<x>, <y>, stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
    a,
    b,
    bezier_point_func(a, b),
  )),
  edge(<x>, <y>, stroke: red, draw: ((a, b)) => cetz.draw.bezier-through(
    a,
    (-2em, -2em),
    b,
  )),
  debug: "edge.snap.from",
)
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  // edge(stroke: green, snap-to: auto, cetz.draw.line(x, y)),
  // edge(<x>, <y>, bend: 30deg, stroke: red),
  edge(<x>, <y>, through: (-.5em, -2em), stroke: red),
  // edge(<x>, <y>, ctrl-pts: ((-2em, -2em),), stroke: purple),
  // edge(<x>, <y>, stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
  edge(vertices: (x, y), stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
    a,
    b,
    bezier_point_func(a, b),
  )),
  // edge(stroke: red, snap-to: auto, draw: ((a, b)) => cetz.draw.line(
  //   a,
  //   b,
  // )),
  // debug: true,
  debug: "edge.snap.from",
)
/*
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  // edge(stroke: green, snap-to: auto, cetz.draw.line(x, y)),
  // edge(<x>, <y>, bend: 30deg, stroke: red),
  // edge(<x>, <y>, through: (uv: (.5, .5)), stroke: green),
  // edge(<x>, <y>, stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
  edge(vertices: (x, y), stroke: blue, draw: ((a, b)) => cetz.draw.bezier(
    a,
    b,
    bezier_point_func(a, b),
  )),
  // edge(stroke: red, snap-to: auto, draw: ((a, b)) => cetz.draw.line(
  //   a,
  //   b,
  // )),
  // debug: true,
  debug: "edge.snap.from",
)
*/

#let x = (0em, 0em)
#let y = (0em, -4em)
#diagram(
  node(x, $X''$, <x>),
  node(y, $Y''$, <y>),
  edge(<x>, <y>, through: (-.5em, -2em), stroke: red),
  debug: "edge.snap.from",
)
/*
