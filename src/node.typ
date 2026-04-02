#import "utils.typ": *
#import "imports.typ": fletcher

#let make_node(json_node, size_grid, preamble) = {
  let x = json_node.label.pos.at(0) / size_grid * 1em
  let y = -json_node.label.pos.at(1) / size_grid * 1em
  fletcher.node(
    (x, y),
    // pos: (x, y),
    body: make_label(
      json_node.label.label,
      preamble,
      is_text_node: "text" in json_node.label.flags,
      default: $bullet$,
    ),
    name: id_to_label(json_node.id),
    weight: 0,
  )
}

#let make_nodes(json_nodes, size_grid, preamble) = {
  json_nodes.map(n => make_node(n, size_grid, preamble))
}
