#import "imports.typ": fletcher
#import "node.typ": make_nodes
#import "edge.typ": make_edges

#let base_scale = 1.5 // à vue de nez

#let src_diagram(diagram, dictionary, text_font, scale: 1) = {
  let json_diagram = if type(diagram) == dictionary {
    diagram
  } else if type(diagram) == content and diagram.func() == raw {
    json(bytes(diagram.text))
  } else {
    panic("Unsupported diagram description")
  }
  let version = json_diagram.version
  if version < 20 {
    panic("Diagram version (" + str(version) + ") outdated")
  }
  let graph = json_diagram.graph
  let tab = graph.tabs.at(graph.activeTabId)
  let nodes = tab.nodes
  let edges = tab.edges
  let size = (
    1 / base_scale * if scale == none { 1 } else { 1 / scale * tab.sizeGrid }
  )
  let preamble = graph.latexPreamble

  (
    ..make_nodes(
      nodes,
      size,
      preamble,
      dictionary,
      text_font,
    ),
    ..make_edges(
      edges,
      size,
      preamble,
      dictionary,
    ),
  )
}

#let make_diagram(diagram, dictionary, text_font, scale: 1, debug: false) = {
  fletcher.diagram(
    debug: debug,
    // debug: if debug { 3 } else { false },
    ..src_diagram(diagram, dictionary, text_font, scale: scale),
  )
}

#let diagram = make_diagram

#let yade(body, dictionary: (:), size: auto, scale: 1, text_font: "New Computer Modern", debug: false) = {
  // let text_size = state("text_size", 1em)
  // context {
  //   text_size.update(1em.to-absolute())
  // }
  // to compensate the fact that text size in raw is by defaut 0.8em => no very robust, better solution above? (breaks preview)
  let size = if size == auto {
    1.25em
  } else {
    size
  }
  show raw.where(lang: "yade"): it => {
    set text(size)
    make_diagram(it, dictionary, text_font, scale: scale, debug: debug)
  }
  // show raw.where(lang: "yade-src"): it => {
  //   set text(size)
  //   src_diagram(it, dictionary, scale: scale)
  // }
  body
}
