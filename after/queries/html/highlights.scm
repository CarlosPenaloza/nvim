; extends

((attribute_name) @tag.attribute.lit.event
  (#lua-match? @tag.attribute.lit.event "^@")
  (#set! priority 110))

((attribute_name) @tag.attribute.lit.property
  (#lua-match? @tag.attribute.lit.property "^%.")
  (#set! priority 110))

((attribute_name) @tag.attribute.lit.boolean
  (#lua-match? @tag.attribute.lit.boolean "^%?")
  (#set! priority 110))