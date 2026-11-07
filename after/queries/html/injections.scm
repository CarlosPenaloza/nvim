; extends

((script_element
  (start_tag
    (tag_name) @_tag)
  (raw_text) @injection.content)
 (#eq? @_tag "script")
 (#set! injection.language "javascript"))