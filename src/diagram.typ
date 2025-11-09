#import "imports.typ" : fletcher
#import "node.typ" : make_nodes
#import "edge.typ" : make_edges


#let make_diagram(json_diagram, scale: 1) = {
  // let json_diagram = json(diagram_path)
  let graph = json_diagram.graph
  let tab = graph.tabs.at(graph.activeTabId)
  let nodes = tab.nodes
  let edges = tab.edges
  let size = if scale == none { 1 } else { 1 / scale * tab.sizeGrid }
  let preamble = graph.latexPreamble

  fletcher.diagram(
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
