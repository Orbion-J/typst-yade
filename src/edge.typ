#import "utils.typ": *
#import "imports.typ": fletcher


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


#let args_from_style(json_style, size) = {
  // Default args
  let args = (
    bend: 0deg,
    extrude: (0,),
    label-angle: 0deg,
    label-side: left,
    marks: (none, "head"),
    shift: (0, 0),
    stroke: auto,
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
      } else {
        panic_parameters(head, "head")
      }
      args.marks.at(1) = value

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

      // Unknown style
    } else {
      panic("Error: Unrecognized style '" + s + "'.")
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
