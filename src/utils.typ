#import "imports.typ": mitex

#let id_to_label(id) = label(str(id))

#let make_label(json_label, preamble, is_text_node: false, default: none, size: 1em) = {
  let content = if is_text_node {
    mitex.mitext(raw(preamble + json_label))
  } else {
    if json_label == "" {
      default
    } else {
      mitex.mi(raw(preamble + json_label))
    }
  }
  set text(size: size)
  content
}
