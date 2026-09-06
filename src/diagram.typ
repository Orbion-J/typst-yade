#import "imports.typ": fletcher
#import "node.typ": make_nodes
#import "edge.typ": make_edges

// #let base_scale = 1.5 // à vue de nez
// #let base_scale = .05 // à vue de nez
#let supported_yade_version = 20

#let _nodes_and_edges_args(diagram, dictionary, text_font, scale: 1) = {
  let json_diagram = if type(diagram) == dictionary {
    diagram
  } else if type(diagram) == content and diagram.func() == raw {
    json(bytes(diagram.text))
  } else if type(diagram) == path {
    json(diagram)
  } else {
    panic("Unsupported diagram description. Input should be of type dict, content/raw or path but is of type " + str(type(diagram)))
  }
  let version = json_diagram.version
  if version < supported_yade_version {
    panic(
      "Diagram version ("
        + str(version)
        + ") outdated. To update your diagram, copy paste it in an updated instance of yade and export it again.",
    )
  }
  let graph = json_diagram.graph
  let tab = graph.tabs.at(graph.activeTabId)
  let nodes = tab.nodes
  let edges = tab.edges
  let size = (
    if scale == none { 20 } else { 2 / 3 * 1 / scale * tab.sizeGrid }
    // 1 / base_scale * if scale == none { 1 } else { 1 / scale * tab.sizeGrid }
  )
  let preamble = graph.latexPreamble

  (
    nodes: make_nodes(
      nodes,
      size,
      preamble,
      dictionary,
      text_font,
    ),
    edges: make_edges(
      edges,
      size,
      preamble,
      dictionary,
    ),
  )
}

#let _nodes_and_edges(diagram, dictionary, text_font, scale: 1) = {
  let args = _nodes_and_edges_args(diagram, dictionary, text_font, scale: scale)
  (
    ..args.nodes.map(n => fletcher.node(..n)),
    ..args.edges.map(e => fletcher.edge(..e)),
  )
}

#let _diagram(diagram, dictionary, text_font, scale: 1, debug: false) = {
  fletcher.diagram(
    debug: debug,
    _nodes_and_edges(diagram, dictionary, text_font, scale: scale)
  )
}

#let diagram(
  diagram,
  dictionary: (:),
  text_font: "New Computer Modern",
  scale: 1,
  debug: false,
) = _diagram(diagram, dictionary, text_font, scale: scale, debug: debug)

#let nodes_and_edges(
  diagram,
  dictionary: (:),
  text_font: "New Computer Modern",
  scale: 1,
) = _nodes_and_edges(diagram, dictionary, text_font, scale: scale)

#let nodes_and_edges_args(
  diagram,
  dictionary: (:),
  text_font: "New Computer Modern",
  scale: 1,
) = _nodes_and_edges_args(diagram, dictionary, text_font, scale: scale)

#let nodes_and_edges_metadata(
  diagram,
  dictionary: (:),
  text_font: "New Computer Modern",
  scale: 1,
) = {
  let args = nodes_and_edges_args(
    diagram,
    dictionary: dictionary,
    text_font: text_font,
    scale: scale,
  )
  let output = ""
  for n in args.nodes {
    let x = str(repr(n))
    x = x.replace("\n", "").replace("  ", " ").replace("( ", "(")
    x = x.replace("arguments", "node")
    x = x
      .replace("body: styled(child: equation(block: false, ", "")
      .replace("]), ..)", "]")
    output += x + ", "
  }
  for e in args.edges {
    let x = str(repr(e))
    x = x.replace("\n", "").replace("  ", " ").replace("( ", "(")
    x = x
      .replace(
        "label: styled(child: equation( block: false,  body: equation(block: false, body:",
        "label: ",
      )
      .replace("]), ), ..)", "]")
    x = x.replace("label: styled(child: [], ..), ", "")
    output += "edge" + x + ", "
  }
  // pretty: false,
  // ),
  metadata(output)
}

#let yade(
  body,
  dictionary: (:),
  size: auto,
  scale: 1,
  text_font: "New Computer Modern",
  debug: false,
) = {
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
    _diagram(it, dictionary, text_font, scale: scale, debug: debug)
  }
  body
}
