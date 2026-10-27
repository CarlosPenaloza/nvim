; extends

(call_expression
  function: (identifier) @_lit_css
  (#eq? @_lit_css "css")
  arguments: (template_string
    (string_fragment) @injection.content)
  (#set! injection.language "css")
  (#set! injection.combined))