#import "utils.typ": *
#import "imports.typ": cetz, fletcher, mitex

#let panic_parameters(value, name) = {
  panic(
    "Error: unknown value '" + str(value) + "' for style '" + str(name) + "'.",
  )
}

#let resolve_color(color) = {
  if color == auto {
    auto
  } else if color == "red" {
    red
  } else if color == "blue" {
    blue
  } else if color == "purple" {
    purple
  } else if color == "green" {
    green
  } else if color == "orange" {
    orange
  } else if color == "yellow" {
    yellow
  } else if color == "gray" {
    gray
  } else if color == "black" {
    black
  } else {
    panic("Error: unrecognized color '" + color + "'.")
  }
}


#let find_edge(x, json_edges) = {
  for edge in json_edges {
    if edge.id == x.name {
      return edge
    }
  }
  panic("Edge not found")
}

#let make_anchor(is_edge, pullshout, shift, start_or_end) = {
  if not is_edge {
    none
  } else if pullshout != auto {
    // let shift = pullshout.split(" ").at(start_or_end)
    // let value = int(shift) - 50 / 100
    // if start_or_end == 0 { (anchor: 10%) } else { none }
    none // TODO
  } else if shift != auto {
    let shift = float(shift)
    let value = (shift / 10 + 0.5) * 100%
    (anchor: value)
  } else {
    none
  }
}
// + (
//   anchor: {
//     let pullshout = find("pullshout")
//     if pullshout != auto {
//       let (s, t) = pullshout.split(" ")
//       float(s) * 1%
//     } else {
//       let shift = find("shiftSource")
//       if shift == auto { none } else {
//         let shift = float(shift)
//         let value = (shift / 10 + 0.5) * 100%
//         value
//       }
//     }
//   },
// args.marks.at(2) = none
//   // let shift_s = (int(s.at(1)) - 50) / 100
//   // let shift_t = (int(s.at(2)) - 50) / 100
//   // args.shift = (shift_s, shift_t)
//   // let shift_s = float(s.at(1)) * 1%
//   // let shift_t = float(s.at(2)) * 1%
//   // args.vertices.at(0) += (anchor: shift_s)
//   // args.vertices.at(1) += (anchor: shift_t)
//   // args.corner = left


#let make_args(
  start,
  start_is_edge,
  end,
  end_is_edge,
  name,
  label,
  json_options,
  size,
) = {
  let find(opt) = json_options.at(opt, default: auto)
  // let refind(opt1, opt2) = {
  //   let try = find(opt1)
  //   if try != auto { try } else { find(opt2) }
  // }

  let args = (
    //
    // Base
    //
    vertices: (
      start
        + make_anchor(start_is_edge, find("pullshout"), find("shiftSource"), 0),
      end + make_anchor(end_is_edge, find("pullshout"), find("shiftTarget"), 1),
    ),
    name: name,
    label: label,
    corner-radius: none,
    // corner: none,
    // outset: auto,
    //
    // Shorten if a 2-cell
    //
    shorten: (
      if start_is_edge { .5em } else { 0 },
      if end_is_edge { .5em } else { 0 },
    ),
    //
    // Label
    //
    label-side: {
      let alignment = find("alignment")
      if alignment == auto or alignment == "left" {
        true
      } else if alignment == "right" {
        false
      } else if alignment == "over" {
        center
      } else {
        panic_parameters(alignment, "alignment")
      }
    },
    label-pos: {
      let pos = find("position")
      if pos == auto { 50% } else { float(pos) }
    },
    label-angle: 0deg,
    //
    // Marks: tail, marker, head
    //
    marks: (
      {
        let tail = find("tail")
        if tail == auto { none } else {
          let tailColor = find("tailColor")
          let stroke = resolve_color(tailColor)
          let tail_class = if tail == "mapsto" {
            "bar"
          } else if tail == "hook" {
            "hook"
          } else if tail == "hookalt" {
            "hook'"
          } else if tail == "arrowtail" {
            ">"
          } else {
            panic_parameters(tail, "tail")
          }
          (inherit: tail_class, stroke: stroke)
        }
      },
      {
        let marker = find("marker")
        if marker == auto {
          none
        } else if marker == "\\bullet" {
          (inherit: "circle")
        } else if marker == "\\circ" {
          (inherit: "circle", fill: none)
        } else if marker == "|" {
          (inherit: "|")
        } else {
          (
            draw: it => {
              cetz.draw.content((0, 0), scale(70%, mitex.mi(raw(marker))))
            },
          )
        }
      },
      {
        let head = find("head")
        let headColor = find("headColor")
        let stroke = resolve_color(headColor)
        let pullshout = find("pullshout")
        if head == "none" or pullshout != auto {
          none
        } else if head == auto {
          (inherit: "head", stroke: stroke)
        } else if head == "twoheads" {
          (inherit: ">>", stroke: stroke)
        } else {
          panic_parameters(head, "head")
        }
      },
    ),
    //
    // Stroke
    //
    stroke: {
      let kind = find("kind")
      if kind == "none" {
        none
      } else {
        resolve_color(find("color "))
      }
    },
    //
    // Extrude
    //
    extrude: {
      let kind = find("kind")
      if kind == auto or kind == "none" {
        (0,)
      } else if kind == "double" {
        (-1.5, 1.5)
      } else {
        panic_parameters(kind, "kind")
      }
    },
    //
    // Dash
    //
    dash: {
      let dashed = find("dashed")
      if dashed == true {
        "dashed"
      } else {
        none
      }
    },
    //
    // shift: (0, 0),
    decorate: {
      let wavy = find("wavy")
      if wavy == true {
        (kind: "zigzag", shorten: 1)
      } else {
        auto
      }
    },
  )


  // OPTIONAL ADDITIONAL ARGUMENTS

  // Bend (Bezier curve)
  let bend = find("bend")
  if bend != auto {
    args += (
      bezier: {
        let bend = -float(bend)
        let bezier_point = (
          (s, e) => {
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
          },
          start,
          end,
        )
        (bezier_point,)
      },
    )
  }

  // Corner for pullshout
  let pullshout = find("pullshout")
  if pullshout != auto {
    args += (corner: "-|")
  }
  // } else if key == "shiftSource" {
  //     //assert_parameters(s, 1, "shiftSource")
  //
  //     let shiftSource = float(s.at(1))
  //     let value = (shiftSource / 10 + 0.5) * 100%
  //     // let value = shiftSource / size
  //     // args.shift.at(0) = value
  //     args.vertices.at(0) += (anchor: value)
  //
  //     // shiftTarget -> shift
  //   } else if key == "shiftTarget" {
  //     //assert_parameters(s, 1, "shiftTarget")
  //
  //     let shiftTarget = float(s.at(1))
  //     let value = (shiftTarget / 10 + 0.5) * 100%
  //     // let value = shiftTarget / size * 2
  //     // args.shift.at(1) = value
  //     args.vertices.at(1) += (anchor: value)
  //
  // } else if key == "pullshout" {
  //   //assert_parameters(s, 2, "pullshout")
  //   // args.marks.at(2) = none
  //   // let shift_s = (int(s.at(1)) - 50) / 100
  //   // let shift_t = (int(s.at(2)) - 50) / 100
  //   // args.shift = (shift_s, shift_t)
  //   // let shift_s = float(s.at(1)) * 1%
  //   // let shift_t = float(s.at(2)) * 1%
  //   // args.vertices.at(0) += (anchor: shift_s)
  //   // args.vertices.at(1) += (anchor: shift_t)
  //   // args.corner = left
  //
  //   let root = make_start(find_edge(start, json_edge))


  // Checking for unknown option
  let known_options = (
    "alignment",
    "head",
    "bend",
    "kind",
    "shiftSource",
    "shiftTarget",
    "adjunction",
    "color ",
    "position",
    "wavy",
    "dashed",
    "tail",
    "marker",
    "headColor",
    "tailColor",
    "pullshout",
    "labelColor",
  )
  for (key, _) in json_options {
    if key not in known_options {
      panic(
        "Error: Unrecognized option '"
          + key
          + "' with value '"
          + str(value)
          + "'.",
      )
    }
  }

  return args
}


// /// Draw edge
#let make_start(json_edge) = (name: str(json_edge.from))
#let make_end(json_edge) = (name: str(json_edge.to))

#let make_edge(json_edge, size, preamble, dictionnary, json_edges, id_edges) = {
  let start = make_start(json_edge)
  let start_is_edge = json_edge.from in id_edges

  let end = make_end(json_edge)
  let end_is_edge = json_edge.to in id_edges

  let name = id_to_label(json_edge.id)

  let label = make_label(
    json_edge.label.label,
    preamble,
    dictionnary,
    size: 0.7em,
    fill: resolve_color(json_edge.label.options.at(
      "labelColor",
      default: auto,
    )),
  )

  let args = make_args(
    start,
    start_is_edge,
    end,
    end_is_edge,
    name,
    label,
    json_edge.label.options,
    size,
  )
  fletcher.edge(..args)
  // json_edges,
  //   label: make_label(
  //     json_edge.label.label,
  //     preamble,
  //     dictionnary,
  //     size: 0.7em,
  //     // fill: resolve_color(json_edge.label.options.at("color ", default: auto)),
  //   ),
  //   name: id_to_label(json_edge.id),
  //   ..args,
  // )
}


#let make_edges(json_edges, size, preamble, dictionnary) = {
  let id_edges = json_edges.map(e => e.id)
  json_edges.map(e => make_edge(
    e,
    size,
    preamble,
    dictionnary,
    json_edges,
    id_edges,
  ))
}
