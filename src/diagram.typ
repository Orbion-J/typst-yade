#import "imports.typ": fletcher
#import "node.typ": make_nodes
#import "edge.typ": make_edges

#let base_scale = 7 // à vue de nez

#let make_diagram(diagram, scale: 1, debug: false) = {
  let json_diagram = if type(diagram) == dictionary {
    diagram
  } else if type(diagram) == content and diagram.func() == raw {
    json(bytes(diagram.text))
  } else {
    panic("Unsupported diagram description")
  }
  let graph = json_diagram.graph
  let tab = graph.tabs.at(graph.activeTabId)
  let nodes = tab.nodes
  let edges = tab.edges
  let size = 1 / base_scale * if scale == none { 1 } else { 1 / scale * tab.sizeGrid }
  let preamble = graph.latexPreamble

  fletcher.diagram(
    debug: if debug { 3 } else { false },
    ..make_nodes(
      nodes,
      size,
      preamble,
    ),
    ..make_edges(
      edges,
      size,
      preamble,
    ),
  )
}

#let diagram = make_diagram

#let yade(body, size: auto, scale: 1, debug: false) = {
  // let text_size = state("text_size", 1em)
  // context {
  //   text_size.update(1em.to-absolute())
  // }
  show raw.where(lang: "yade"): it => {
    let size = if size == auto {
      1.25em
    } else {
      size
    }
    set text(size) // to compensate the fact that text size in raw is by defaut 0.8em => no very robust, better solution above? (breaks preview)
    make_diagram(it, scale: scale, debug: debug)
  }
  body
}
