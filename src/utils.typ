#import "imports.typ" : mitex

#let id_to_label(id) = label(str(id))

#let make_label(json_label, preamble, is_text_node: false, default: none) = {
  if is_text_node {
    return mitex.mitext(raw(preamble + json_label))
  } else {
    if json_label == "" {
      return default
    }
    return mitex.mi(raw(preamble + json_label))
  }
}
