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


#let args_from_style(json_style, size) = {
  // Default args
  let args = (
    bend: 0deg,
    extrude: (0,),
    label-angle: 0deg,
    label-side: left,
    marks: (none, none, (inherit:"head")),
    shift: (0, 0),
    stroke: auto,
    decorations: none,
    dash: none,
  )

  // Reading style
  for item in json_style {
    let s = item.split(" ")

    // alignment -> side
    if s.at(0) == "alignment" {
      assert_parameters(s, 1, "alignment")

      let alignment = s.at(1)
      let value = if alignment == "right" {
        right
      } else if alignment == "left" {
        left
      } else if alignment == "over" {
        return center
      } else {
        panic_parameters(alignment, "alignement")
      }
      args.label-side = value

      // head -> marks
    } else if s.at(0) == "head" {
      assert_parameters(s, 1, "head")

      let head = s.at(1)
      let value = if head == "none" {
        none
      } else if head == "twoheads" {
        (inherit:">>")
      } else {
        panic_parameters(head, "head")
      }
      args.marks.at(2) += value

      // bend -> bend
    } else if s.at(0) == "bend" {
      assert_parameters(s, 1, "bend")

      let bend = float(s.at(1))
      let value = calc.atan(-bend)
      args.bend = value

      // kind -> extrude, stroke
    } else if s.at(0) == "kind" {
      assert_parameters(s, 1, "kind")

      let kind = s.at(1)
      if kind == "double" {
        args.extrude = (-1.5, 1.5)
      } else if kind == "none" {
        args.stroke = none
      } else {
        panic_parameters(kind, "kind")
      }

      // shiftSource -> shift
    } else if s.at(0) == "shiftSource" {
      assert_parameters(s, 1, "shiftSource")

      let shiftSource = float(s.at(1))
      let value = shiftSource / size * 2
      args.shift[0] = value

      // shiftTarget -> shift
    } else if s.at(0) == "shiftTarget" {
      assert_parameters(s, 1, "shiftTarget")

      let shiftTarget = float(s.at(1))
      let value = shiftTarget / size * 2
      args.shift[1] = value

      // adjunction -> stroke, label-angle
    } else if s.at(0) == "adjunction" {
      assert_parameters(s, 0, "adjunction")

      args.stroke = none
      args.label-angle = right

      // color -> stroke
    } else if s.at(0) == "color" {
      assert_parameters(s, 1, "color")

      args.stroke = resolve-color(s.at(1))

      // position -> ignore
    } else if s.at(0) == "position" {
      assert_parameters(s, 1, "position")

      // wavy -> decorations
    } else if s.at(0) == "wavy" {
      assert_parameters(s, 0, "wavy")
      args.decorations = "wave"

      // dashed -> dash
    } else if s.at(0) == "dashed" {
      assert_parameters(s, 0, "dashed")
      args.dash = "dashed"

      // tail -> marks
    } else if s.at(0) == "tail" {
      assert_parameters(s, 1, "tail")

      let tail = s.at(1)
      let value = if tail == "mapsto" {
        "bar"
      } else if tail == "hook" {
        "hook"
      } else if tail == "hookalt" {
        "hook'"
      } else {
        panic_parameters(tail, "tail")
      }
      args.marks.at(0) += (inherit:value)

      // marker -> marks
    } else if s.at(0) == "marker" {
      assert_parameters(s, 1, "marker")

      let marker = s.at(1)
      args.marks.at(1) = if marker == "\\bullet" {
        (inherit:"circle")
      } else if marker == "\\circ" {
        (inherit: "circle", fill: none)
      } else if marker == "|" {
        (inherit:"|")
      } else {
        (draw: it => { cetz.draw.content((0, 0), scale(70%, mitex.mi(raw(marker)))) })
      }

      // headColor -> marks
    } else if s.at(0) == "headColor" {
      assert_parameters(s, 1, "headColor")

      args.marks.at(2) += (stroke:resolve-color(s.at(1)))

      // tailColor -> marks
    } else if s.at(0) == "tailColor" {
      assert_parameters(s, 1, "tailColor")

      args.marks.at(0) += (stroke:resolve-color(s.at(1)))

      // pullshout -> ?
    } else if s.at(0) == "pullshout" {
      assert_parameters(s, 2, "pullshout")
      args.marks.at(2) = none
      // UNSUPPORTED

      // Unknown style
    } else {
      panic("Error: Unrecognized style '" + s.at(0) + "'.")
    }
  }

  return args
}


// /// Draw edge

#let make_edge(json_edge, size, preamble) = {
  fletcher.edge(
    vertices: (id_to_label(json_edge.from), id_to_label(json_edge.to)),
    label: make_label(json_edge.label.label, preamble),
    label-size: 0.7em,
    name: id_to_label(json_edge.id),
    ..args_from_style(json_edge.label.style, size),
  )
}


#let make_edges(json_edges, size, preamble) = {
  json_edges.map(e => make_edge(e, size, preamble))
}
