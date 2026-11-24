#import "imports.typ": fletcher
#import "node.typ": make_nodes
#import "edge.typ": make_edges

// #let base_scale = 1.5 // à vue de nez
// #let base_scale = .05 // à vue de nez
#let supported_yade_version = 20


// A dictionary (nodes: array, edges: array)
// where nodes (resp. edges) is a list of arguments objects, one for each fletcher node (resp. edge) object in the final diagram
#let _nodes_and_edges_args(..diag_args) = {
  let diagram = diag_args.diagram
  let json_diagram = if type(diagram) == dictionary {
    diagram
  } else if type(diagram) == content and diagram.func() == raw {
    json(bytes(diagram.text))
  } else if type(diagram) == path {
    json(diagram)
  } else {
    panic(
      "Unsupported diagram description. Input should be of type dict, content/raw or path but is of type "
        + str(type(diagram)),
    )
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
    if diag_args.scale == none { 20 } else { 2 / 3 * 1 / diag_args.scale * tab.sizeGrid }
    // 1 / base_scale * if scale == none { 1 } else { 1 / scale * tab.sizeGrid }
  )
  let preamble = graph.latexPreamble

  (
    nodes: make_nodes(
      nodes,
      size,
      preamble,
      diag_args.dictionary,
      diag_args.text-font,
    ),
    edges: make_edges(
      edges,
      size,
      preamble,
      diag_args.dictionary,
      diag_args.crossing-fill,
      diag_args.edge-fill,
    ),
  )
}

#let add_extra_args(args, extra_args) = {
  let id = str(args.name)
  arguments(
    ..(args.pos()),
    ..(args.named() + extra_args.at(id, default: none)),
  )
}

#let _nodes_and_edges(..diag_args) = {
  let ne_args = _nodes_and_edges_args(..diag_args)
  (
    ..ne_args.nodes.map(n => {
      let n = add_extra_args(n, diag_args.extra)
      fletcher.node(..n)
    }),
    ..ne_args.edges.map(e => {
      let e = add_extra_args(e, diag_args.extra)
      fletcher.edge(..e)
    }),
  )
}

#let _diagram(..diag_args) = {
  fletcher.diagram(
    debug: diag_args.debug,
    _nodes_and_edges(..diag_args),
  )
}

#let diagram(
  diagram,
  dictionary: (:),
  extra: (:),
  text-font: "New Computer Modern",
  crossing-fill: auto,
  edge-fill: auto,
  scale: 1,
  debug: false,
  size: auto,
) = {
  let size = if size == auto {
    1em
  } else if type(size) == length {
    size
  } else {
    size * 1em
  }
  set text(size)
  _diagram(
    diagram: diagram,
    dictionary: dictionary,
    extra: extra,
    text-font: text-font,
    crossing-fill: crossing-fill,
    edge-fill: edge-fill,
    scale: scale,
    debug: debug,
  )
}

#let nodes_and_edges(
  diagram,
  dictionary: (:),
  extra: (:),
  text-font: "New Computer Modern",
  crossing-fill: auto,
  edge-fill: auto,
  scale: 1,
) = _nodes_and_edges(
  diagram: diagram,
  dictionary: dictionary,
  extra: extra,
  text-font: text-font,
  crossing-fill: crossing-fill,
  edge-fill: edge-fill,
  scale: scale,
)

// #let nodes_and_edges_args(
//   diagram,
//   dictionary: (:),
//   text_font: "New Computer Modern",
//   scale: 1,
// ) = _nodes_and_edges_args(diagram, dictionary, text_font, scale: scale)

#let yade(
  body,
  dictionary: (:),
  text-font: "New Computer Modern",
  crossing-fill: auto,
  edge-fill: auto,
  scale: 1,
  debug: false,
  size: auto,
) = {
  // let text_size = state("text_size", 1em)
  // context {
  //   text_size.update(1em.to-absolute())
  // }
  // to compensate the fact that text size in raw is by defaut 0.8em => no very robust, better solution above? (breaks preview)
  let size = if size == auto {
    1.25em
  } else if type(size) == length {
    size
  } else {
    size * 1.25em
  }
  show raw.where(lang: "yade"): it => {
    set text(size)
    set align(center)
    _diagram(
      diagram: it,
      dictionary: dictionary,
      extra: (:),
      text-font: text-font,
      crossing-fill: crossing-fill,
      edge-fill: edge-fill,
      scale: scale,
      debug: debug,
    )
  }
  body
}
