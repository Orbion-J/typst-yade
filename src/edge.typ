#import "utils.typ": *
#import "imports.typ": cetz, fletcher, mitex


// /// Style analysis

#let assert_parameters(s, expected_nb_param, name) = {
  let len = s.len()
  assert(
    len == expected_nb_param + 1,
    message: "Error: style '"
      + str(name)
      + "' expects "
      + str(expected_nb_param)
      + "parameters and "
      + str(len - 1)
      + "were given.",
  )
}

#let panic_parameters(value, name) = {
  panic("Error: unknown value '" + str(value) + "' for style '" + str(name) + "'.")
}

#let resolve-color(color) = {
  if color == "red" {
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

#let args_from_style(json_style, size, start, end, json_edges) = {
  // Default args
  let args = (
    vertices: (start, end),
    // bend: 0deg,
    extrude: (0,),
    label-angle: 0deg,
    label-side: true,
    label-pos: 50%,
    marks: (none, none, (inherit: "head")),
    // shift: (0, 0),
    stroke: auto,
    // decorations: none,
    dash: none,
    // corner: none,
    corner-radius: none,
    // outset: auto,
  )

  // Reading style
  for (key, val) in json_style {
      let s = (key, val)

    // alignment -> side
    if key == "alignment" {
      assert_parameters(s, 1, "alignment")

      let alignment = val
      args.label-side = if alignment == "right" {
        false
      } else if alignment == "left" {
        true
      } else if alignment == "over" {
        center
      } else {
        panic_parameters(alignment, "alignment")
      }

      // head -> marks
    } else if key == "head" {
      assert_parameters(s, 1, "head")

      let head = val
      let value = if head == "none" {
        none
      } else if head == "twoheads" {
        (inherit: ">>")
      } else {
        panic_parameters(head, "head")
      }
      args.marks.at(2) = value

      // bend -> bezier
    } else if key == "bend" {
      assert_parameters(s, 1, "bend")

      let bend = -float(s.at(1))
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
      // args.bezier = (bezier_point,)

      // kind -> extrude, stroke
    } else if key == "kind" {
      assert_parameters(s, 1, "kind")

      let kind = val
      if kind == "double" {
        args.extrude = (-1.5, 1.5)
        // args.outset = (0.3em, 0.3em)
      } else if kind == "none" {
        args.stroke = none
      } else {
        panic_parameters(kind, "kind")
      }

      // shiftSource -> shift
    } else if key == "shiftSource" {
      assert_parameters(s, 1, "shiftSource")

      let shiftSource = float(s.at(1))
      let value = (shiftSource / 10 + 0.5) * 100%
      // let value = shiftSource / size
      // args.shift.at(0) = value
      args.vertices.at(0) += (anchor: value)

      // shiftTarget -> shift
    } else if key == "shiftTarget" {
      assert_parameters(s, 1, "shiftTarget")

      let shiftTarget = float(s.at(1))
      let value = (shiftTarget / 10 + 0.5) * 100%
      // let value = shiftTarget / size * 2
      // args.shift.at(1) = value
      args.vertices.at(1) += (anchor: value)

      // adjunction -> stroke, label-angle
    } else if key == "adjunction" {
      assert_parameters(s, 0, "adjunction")

      args.stroke = none
      args.label-angle = right

      // color -> stroke
    } else if key == "color " {
      assert_parameters(s, 1, "color")

      args.stroke = resolve-color(s.at(1))

      // position -> label-pos
    } else if key == "position" {
      assert_parameters(s, 1, "position")

      args.label-pos = float(s.at(1))

      // wavy -> decorations
    } else if key == "wavy" {
      assert_parameters(s, 0, "wavy")
      // flags.push(wave)
      // TODO ??

      // dashed -> dash
    } else if key == "dashed" {
      if val == true {
        args.dash = "dashed"
      }
      // tail -> marks
    } else if key == "tail" {
      assert_parameters(s, 1, "tail")

      let tail = val
      let value = if tail == "mapsto" {
        "bar"
      } else if tail == "hook" {
        "hook"
      } else if tail == "hookalt" {
        "hook'"
      } else {
        panic_parameters(tail, "tail")
      }
      args.marks.at(0) += (inherit: value)

      // marker -> marks
    } else if key == "marker" {
      assert_parameters(s, 1, "marker")

      let marker = val
      args.marks.at(1) = if marker == "\\bullet" {
        (inherit: "circle")
      } else if marker == "\\circ" {
        (inherit: "circle", fill: none)
      } else if marker == "|" {
        (inherit: "|")
      } else {
        (draw: it => { cetz.draw.content((0, 0), scale(70%, mitex.mi(raw(marker)))) })
      }

      // headColor -> marks
    } else if key == "headColor" {
      assert_parameters(s, 1, "headColor")

      args.marks.at(2) += (stroke: resolve-color(val))

      // tailColor -> marks
    } else if key == "tailColor" {
      assert_parameters(s, 1, "tailColor")

      args.marks.at(0) += (stroke: resolve-color(val))

      // pullshout -> corner (pas ouf)
    } else if key == "pullshout" {
      assert_parameters(s, 2, "pullshout")
      args.marks.at(2) = none
      // let shift_s = (int(s.at(1)) - 50) / 100
      // let shift_t = (int(s.at(2)) - 50) / 100
      // args.shift = (shift_s, shift_t)
      // let shift_s = float(s.at(1)) * 1%
      // let shift_t = float(s.at(2)) * 1%
      // args.vertices.at(0) += (anchor: shift_s)
      // args.vertices.at(1) += (anchor: shift_t)
      // args.corner = left

      let root = make_start(find_edge(start, json_edge))

      // Unknown style
    } else {
      panic("Error: Unrecognized style '" + key + "'.")
    }
  }


  return args
}


// /// Draw edge
#let make_start(json_edge) = (name: str(json_edge.from))
#let make_end(json_edge) = (name: str(json_edge.to))

#let make_edge(json_edge, size, preamble, dictionnary, json_edges) = {
  let start = make_start(json_edge) 
  let end = make_end(json_edge) 
  let args = args_from_style(json_edge.label.options, size, start, end, json_edges)
  fletcher.edge(
    label: make_label(json_edge.label.label, preamble, dictionnary, size: 0.7em),
    name: id_to_label(json_edge.id),
    ..args,
  )
}


#let make_edges(json_edges, size, preamble, dictionnary) = {
  json_edges.map(e => make_edge(e, size, preamble, dictionnary, json_edges))
}
