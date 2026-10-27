; extends

(comment) @fold

(call_expression
	function: (identifier) @_lit_tag
	(#any-of? @_lit_tag "html" "css")
	arguments: (template_string) @fold)