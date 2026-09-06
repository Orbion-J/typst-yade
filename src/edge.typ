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


#let find_edge(id, json_edges) = {
  for edge in json_edges {
    if edge.id == id {
      return edge
    }
  }
  panic("Edge not found")
}

#let make_anchor(is_edge, shift) = {
  if is_edge and shift != auto {
    let shift = float(shift)
    let value = (shift / 10 + 0.5) * 100%
    (anchor: value)
  } else {
    none
  }
}

#let make_args(
  start,
  start_is_edge,
  end,
  end_is_edge,
  name,
  label,
  json_options,
  zindex,
  size,
) = {
  let find(opt, default: auto) = json_options.at(opt, default: default)

  let args = (
    // Base
    vertices: (
      start + make_anchor(start_is_edge, find("shiftSource")),
      end + make_anchor(end_is_edge, find("shiftTarget")),
    ),
    name: name,
    label: label,
    corner-radius: none,
    layer: zindex,
    crossing: true, // not supported by fletcher yet it seems

    // Shorten if a 2-cell
    shorten: (
      if start_is_edge { .5em } else { 0 },
      if end_is_edge { .5em } else { 0 },
    ),

    // Label
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

    // Marks: tail, marker, head
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

    // Stroke: no stroke or color
    stroke: {
      let kind = find("kind")
      if kind == "none" {
        none
      } else {
        resolve_color(find("color "))
      }
    },

    // Extrude
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

    // Dash
    dash: {
      let dashed = find("dashed")
      if dashed == true {
        "dashed"
      } else {
        none
      }
    },

    // Waves
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
    let bend = -float(bend)
    let bezier_point_func = (s, e) => {
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

    args += (
      draw: ((a, b)) => cetz.draw.bezier(a, b, bezier_point_func(a, b)),
    )
  }

  // Loop
  let loopRadius = find("loopRadius")
  if loopRadius != auto {
    let loopAngle = find("loopAngle", default: 0)
    args += (loop: loopRadius / size / 2, loop-angle: -loopAngle * 1rad)
  }

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
    "loopAngle",
    "loopRadius",
  )
  for (key, value) in json_options {
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


#let make_start_end(json_edge, size, json_edges, id_edges, pullshout_info) = {
  if pullshout_info == none {
    // Not a pullshout edge

    let start = (name: str(json_edge.from))
    let end = (name: str(json_edge.to))
    let start_is_edge = json_edge.from in id_edges
    let end_is_edge = json_edge.to in id_edges
    (start, start_is_edge, end, end_is_edge)
  } else {
    // A pullshout edge

    let start_pullshout = (
      name: str(json_edge.from),
      anchor: pullshout_info.s * 1 / size * 1em,
    )
    let end_pullshout = (
      name: str(json_edge.to),
      anchor: pullshout_info.t * 1 / size * 1em,
    )

    // find the root (common point)
    let root = {
      let start_edge = find_edge(json_edge.from, json_edges)
      let end_edge = find_edge(json_edge.to, json_edges)
      let root_id = if start_edge.to in (end_edge.to, end_edge.from) {
        start_edge.to
      } else if start_edge.from in (end_edge.to, end_edge.from) {
        start_edge.from
      } else { panic("Error: pullshout ill-formed") }
      (name: str(root_id))
    }

    // compute the middle point of the pullshout angle (using cetz resolved coordinates)
    let middle = (
      (s, e, r) => {
        let r_to_s = cetz.vector.sub(s, r)
        let r_to_e = cetz.vector.sub(e, r)
        let r_to_m = cetz.vector.add(r_to_s, r_to_e)
        let m = cetz.vector.add(r, r_to_m)
        m
      },
      start_pullshout,
      end_pullshout,
      root,
    )

    if pullshout_info.kind == "start" {
      let start = start_pullshout
      let end = middle
      let start_is_edge = true
      let end_is_edge = false
      (start, start_is_edge, end, end_is_edge)
    } else {
      let start = middle
      let end = end_pullshout
      let start_is_edge = false
      let end_is_edge = true
      (start, start_is_edge, end, end_is_edge)
    }
  }
}

// /// Draw edge
#let make_edge(
  json_edge,
  size,
  preamble,
  dictionnary,
  json_edges,
  id_edges,
  pullshout_info,
) = {
  let (start, start_is_edge, end, end_is_edge) = make_start_end(
    json_edge,
    size,
    json_edges,
    id_edges,
    pullshout_info,
  )

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
    json_edge.label.zindex,
    size,
  )

  args
}


#let make_edges(json_edges, size, preamble, dictionnary) = {
  let id_edges = json_edges.map(e => e.id)

  // For each edge, if its a pullshout, insert two edges
  let edges_with_pullshout = ()
  for e in json_edges {
    let pullshout_option = e.label.options.at("pullshout", default: none)
    if pullshout_option != none {
      let (s, t) = pullshout_option.split(" ")
      edges_with_pullshout.push((
        edge: e,
        pullshout: (kind: "start", s: float(s), t: float(t)),
      ))
      edges_with_pullshout.push((
        edge: e,
        pullshout: (kind: "end", s: float(s), t: float(t)),
      ))
    } else {
      edges_with_pullshout.push((edge: e, pullshout: none))
    }
  }

  edges_with_pullshout.map(ewp => {
    make_edge(
      ewp.edge,
      size,
      preamble,
      dictionnary,
      json_edges,
      id_edges,
      ewp.pullshout,
    )
  })
}
