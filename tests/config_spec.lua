local root = vim.fn.getcwd()

local function load_config(path, overrides)
	local chunk = assert(loadfile(root .. "/" .. path))
	setfenv(chunk, setmetatable(overrides or {}, { __index = _G }))
	return chunk()
end

for _, path in ipairs(vim.fn.globpath(root, "**/*.lua", false, true)) do
	assert(loadfile(path))
end

local configs, enabled = {}, {}
local detected_root, deno_root = "/workspace/web", nil
local mock_vim = setmetatable({
	fs = {
		root = function(_, markers)
			if markers[1] == "deno.json" then
				return deno_root
			end
			return detected_root
		end,
	},
	lsp = {
		config = function(name, config)
			configs[name] = config
		end,
		enable = function(name)
			enabled[name] = true
		end,
	},
}, { __index = vim })
load_config("lua/config/lsp_ts.lua", { vim = mock_vim })
assert(configs.vtsls and not configs.ts_ls)
assert(enabled.vtsls and not enabled.ts_ls)
assert(configs.vtsls.root_markers and type(configs.vtsls.root_dir) == "function")
assert(configs.vtsls.workspace_required)
local resolved_root
configs.vtsls.root_dir(0, function(path)
	resolved_root = path
end)
assert(resolved_root == detected_root)
resolved_root = nil
deno_root = detected_root .. "/deno-app"
configs.vtsls.root_dir(0, function(path)
	resolved_root = path
end)
assert(resolved_root == nil)
deno_root, detected_root = nil, nil
configs.vtsls.root_dir(0, function(path)
	resolved_root = path
end)
assert(resolved_root == nil)

local mason_settings
load_config("lua/config/mason.lua", {
	require = function(name)
		return {
			setup = function(settings)
				if name == "mason-lspconfig" then
					mason_settings = settings
				end
			end,
		}
	end,
})
assert(mason_settings.automatic_enable == false)
assert(vim.tbl_contains(mason_settings.ensure_installed, "vtsls"))
assert(vim.tbl_contains(mason_settings.ensure_installed, "eslint"))
assert(not vim.tbl_contains(mason_settings.ensure_installed, "ts_ls"))

local eslint_configs = {}
local server_available, eslint_warnings = false, 0
local lsp_config = setmetatable({
	eslint = {
		root_dir = function(_, on_dir)
			on_dir("/workspace/web")
		end,
	},
}, {
	__call = function(_, name, config)
		eslint_configs[name] = config
	end,
})
local handler_configs = {}
local lsp_handlers = {
	hover = function(_, _, _, config)
		return config
	end,
	signature_help = function(_, _, _, config)
		return config
	end,
}
local eslint_vim = setmetatable({
	lsp = setmetatable({ config = lsp_config, enable = function() end, handlers = lsp_handlers }, { __index = vim.lsp }),
	fn = setmetatable({
		executable = function()
			return server_available and 1 or 0
		end,
	}, { __index = vim.fn }),
	notify_once = function()
		eslint_warnings = eslint_warnings + 1
	end,
}, { __index = vim })
load_config("lua/config/lsp.lua", { vim = eslint_vim })
handler_configs.hover = lsp_handlers["textDocument/hover"](nil, nil, nil, { max_width = 80 })
handler_configs.signature_help = lsp_handlers["textDocument/signatureHelp"](nil, nil, nil, { max_height = 12 })
assert(handler_configs.hover.border == "rounded" and handler_configs.hover.max_width == 80)
assert(handler_configs.signature_help.border == "rounded" and handler_configs.signature_help.max_height == 12)
local eslint_root
eslint_configs.eslint.root_dir(0, function(path)
	eslint_root = path
end)
assert(eslint_root == nil and eslint_warnings == 1)
server_available = true
eslint_configs.eslint.root_dir(0, function(path)
	eslint_root = path
end)
assert(eslint_root == "/workspace/web")

local plugins = load_config("lua/plugins/init.lua")
local modern_gruvbox = false
for _, plugin in ipairs(plugins) do
	assert(plugin[1] ~= "pmizio/typescript-tools.nvim")
	assert(plugin[1] ~= "morhetz/gruvbox")
	modern_gruvbox = modern_gruvbox or plugin[1] == "ellisonleao/gruvbox.nvim"
end
assert(modern_gruvbox)

local highlights = load_config("lua/config/highlights.lua")
highlights.apply()
assert(vim.api.nvim_get_hl(0, { name = "@tag.attribute.lit.event" }).link == "@function")
assert(vim.api.nvim_get_hl(0, { name = "@tag.attribute.lit.property" }).link == "@property")
assert(vim.api.nvim_get_hl(0, { name = "@tag.attribute.lit.boolean" }).link == "@boolean")
assert(vim.api.nvim_get_hl(0, { name = "DiagnosticUnderlineError", link = false }).undercurl)

local statusline_settings
load_config("lua/config/lualine.lua", {
	require = function(name)
		assert(name == "lualine")
		return {
			setup = function(settings)
				statusline_settings = settings
			end,
		}
	end,
})
assert(statusline_settings.options.theme == "auto")
vim.o.winbar = ""

local fold_settings
local fold_stub = setmetatable({
	setup = function(settings)
		fold_settings = settings
	end,
}, {
	__index = function()
		return function() end
	end,
})
load_config("lua/config/ufo.lua", {
	require = function(name)
		assert(name == "ufo")
		return fold_stub
	end,
})
local fold_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(fold_buf, 0, -1, false, { "class Component {", "  render() {}", "}" })
local web_providers = fold_settings.provider_selector(fold_buf, "javascript", "")
assert(type(web_providers[1]) == "function" and web_providers[2] == "indent")
assert(vim.deep_equal(fold_settings.provider_selector(fold_buf, "lua", ""), { "treesitter", "indent" }))
assert(fold_settings.provider_selector(fold_buf, "oil", "acwrite") == "")
vim.b[fold_buf].large_file = true
assert(fold_settings.provider_selector(fold_buf, "javascript", "") == "")
vim.b[fold_buf].large_file = false
vim.api.nvim_buf_set_lines(fold_buf, 0, -1, false, { string.rep("x", 201 * 1024) })
assert(vim.deep_equal(fold_settings.provider_selector(fold_buf, "javascript", ""), { "indent" }))
vim.api.nvim_buf_set_lines(fold_buf, 0, -1, false, { string.rep("x", 2 * 1024 * 1024) })
assert(fold_settings.provider_selector(fold_buf, "javascript", "") == "")
vim.api.nvim_buf_delete(fold_buf, { force = true })

local function truncate_fold(text, width)
	local result = ""
	for index = 0, vim.fn.strchars(text) - 1 do
		local candidate = result .. vim.fn.strcharpart(text, index, 1)
		if vim.fn.strdisplaywidth(candidate) > width then
			break
		end
		result = candidate
	end
	return result
end
for _, width in ipairs({ 0, 5, 20, 80 }) do
	local chunks = fold_settings.fold_virt_text_handler({ { "render() {", "Function" } }, 2, 26, width, truncate_fold)
	local text = table.concat(vim.tbl_map(function(chunk)
		return chunk[1]
	end, chunks))
	assert(vim.fn.strdisplaywidth(text) <= width)
	if width >= 20 then
		assert(text:find("24 lineas", 1, true))
	end
end
assert(fold_settings.preview.win_config.winblend == 0)

local narrow_chunks = fold_settings.fold_virt_text_handler({
	{ vim.fn.nr2char(0x754c):rep(30), "String" },
}, 1, 10, 16, truncate_fold)
assert(vim.fn.strdisplaywidth(table.concat(vim.tbl_map(function(chunk)
	return chunk[1]
end, narrow_chunks))) <= 16)

local detached, attached = {}, {}
local test_buf = vim.api.nvim_get_current_buf()
local previous_ufo = package.loaded["ufo"]
local fold_detached, fold_attached
package.loaded["ufo"] = {
	hasAttached = function(bufnr)
		return bufnr == test_buf
	end,
	detach = function(bufnr)
		fold_detached = bufnr
	end,
	attach = function(bufnr)
		fold_attached = bufnr
	end,
}
local search = { vim.o.hlsearch, vim.o.incsearch }
vim.wo.wrap = true
vim.bo.swapfile = false
local largefile_vim = setmetatable({
	lsp = {
		get_clients = function()
			return { {
				id = 41,
				stop = function()
					error("Shared client must not stop")
				end,
			} }
		end,
		buf_detach_client = function(bufnr, client_id)
			detached[client_id] = bufnr
		end,
		buf_attach_client = function(bufnr, client_id)
			attached[client_id] = bufnr
		end,
		get_client_by_id = function()
			return {}
		end,
	},
}, { __index = vim })
load_config("lua/config/largefile.lua", { vim = largefile_vim })
vim.cmd.LargeFileOn()
assert(vim.b.large_file and not vim.wo.wrap)
assert(detached[41] == test_buf)
assert(fold_detached == test_buf)
assert(vim.o.hlsearch == search[1] and vim.o.incsearch == search[2])
vim.cmd.LargeFileOff()
assert(not vim.b.large_file and vim.wo.wrap and not vim.bo.swapfile)
assert(attached[41] == test_buf)
assert(fold_attached == test_buf)
package.loaded["ufo"] = previous_ufo

local snippet_counts = {}
load_config("lua/config/snippets.lua", {
	require = function(name)
		assert(name == "luasnip")
		return {
			parser = {
				parse_snippet = function(context, body)
					assert(context.trig:match("^lit%-") and #body > 0)
					return { context = context, body = body }
				end,
			},
			add_snippets = function(filetype, snippets)
				snippet_counts[filetype] = (snippet_counts[filetype] or 0) + #snippets
			end,
		}
	end,
})
assert(snippet_counts.typescript == 6 and snippet_counts.javascript == 4)
load_config("lua/config/web_tests.lua")
assert(vim.fn.exists(":WebTest") == 2 and vim.fn.exists(":WebTestAll") == 2)

local terminal_runs, notifications = {}, {}
local runner_available = true
local fixture_root = "/tmp/web project"
vim.api.nvim_buf_set_name(test_buf, fixture_root .. "/test/component.test.ts")
local runner_vim = setmetatable({
	fs = setmetatable({
		root = function()
			return fixture_root
		end,
	}, { __index = vim.fs }),
	fn = setmetatable({
		executable = function()
			return runner_available and 1 or 0
		end,
		termopen = function(command, options)
			table.insert(terminal_runs, { command = command, cwd = options.cwd })
			return 1
		end,
	}, { __index = vim.fn }),
	cmd = setmetatable({
		enew = function() end,
		startinsert = function() end,
	}, { __call = function() end }),
	notify = function(message)
		table.insert(notifications, message)
	end,
}, { __index = vim })
load_config("lua/config/web_tests.lua", { vim = runner_vim })
vim.cmd("WebTest!")
assert(terminal_runs[1].cwd == fixture_root)
assert(vim.deep_equal(terminal_runs[1].command, {
	fixture_root .. "/node_modules/.bin/web-test-runner",
	"--files",
	vim.api.nvim_buf_get_name(test_buf),
	"--watch",
}))
vim.cmd.WebTestAll()
assert(#terminal_runs[2].command == 1)
runner_available = false
vim.cmd.WebTest()
assert(#terminal_runs == 2 and notifications[#notifications]:match("install"))
runner_available = true
vim.bo.modified = true
vim.cmd.WebTest()
assert(#terminal_runs == 2 and notifications[#notifications]:match("save"))
vim.bo.modified = false

local requested_modules, errors = {}, {}
local startup_vim = setmetatable({
	cmd = { colorscheme = function() end },
	schedule = function(callback)
		callback()
	end,
	notify = function(message)
		table.insert(errors, message)
	end,
}, { __index = vim })
load_config("lua/index.lua", {
	vim = startup_vim,
	require = function(name)
		requested_modules[name] = true
		if name == "config.lsp_ts" then
			error("expected startup error")
		end
		return {}
	end,
})
assert(not requested_modules["config.globals"])
assert(#errors == 1 and errors[1]:match("config.lsp_ts") and errors[1]:match("expected startup error"))

local original_code = { "const before=1;", "", "const selected={value:2};", "", "const after=3;" }
local formatted_code = { "const before = 1;", "", "const selected = { value: 2 };", "", "const after = 3;" }
local format_calls = {}
local format_module = load_config("lua/config/format.lua", {
	require = function(name)
		if name == "conform.runner" then
			return {
				format_lines_sync = function()
					return nil, formatted_code
				end,
			}
		end
		assert(name == "conform")
		return {
			list_formatters_for_buffer = function()
				return { "prettier" }
			end,
			resolve_formatters = function()
				return { { name = "prettier" } }
			end,
			format = function(options)
				table.insert(format_calls, options)
			end,
		}
	end,
})
vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, original_code)
format_module.selection(3, 3)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(test_buf, 0, -1, false), {
	original_code[1],
	"",
	formatted_code[3],
	"",
	original_code[5],
}))
vim.cmd.Format()
assert(#format_calls == 1 and format_calls[1].range == nil)

local grep_calls = {}
local search_module = load_config("lua/config/fzf.lua", {
	require = function(name)
		if name == "fzf-lua.actions" then
			return {}
		end
		assert(name == "fzf-lua")
		return setmetatable({
			setup = function() end,
			live_grep = function(options)
				table.insert(grep_calls, options)
			end,
		}, {
			__index = function()
				return function() end
			end,
		})
	end,
})
search_module.live_grep({ cwd = "/workspace/web" })
search_module.live_grep_all()
assert(grep_calls[1].cwd == "/workspace/web")
assert(grep_calls[1].exec_empty_query == false)
assert(grep_calls[1].rg_opts:find("node_modules", 1, true))
assert(not grep_calls[1].rg_opts:find("--no-ignore", 1, true))
assert(not grep_calls[1].rg_opts:find("--follow", 1, true))
assert(grep_calls[2].rg_opts:find("--no-ignore", 1, true))

if vim.env.NVIM_INTEGRATION_TESTS == "1" then
	local plugins_dir = vim.fn.stdpath("data") .. "/lazy/"
	vim.opt.runtimepath:prepend(plugins_dir .. "nvim-treesitter")
	vim.opt.runtimepath:append(root .. "/after")
	local lit_colors =
		[[const view = html`<button class="action" .value=${value} ?disabled=${busy} @click=${handler}>Save</button>`;]]
	local color_parser = vim.treesitter.get_string_parser(lit_colors, "typescript")
	color_parser:parse(true)
	local lit_captures = {}
	color_parser:for_each_tree(function(tree, language_tree)
		if language_tree:lang() == "html" then
			local query = vim.treesitter.query.get("html", "highlights")
			for capture_id, node in query:iter_captures(tree:root(), lit_colors) do
				local name = query.captures[capture_id]
				if name:find("tag.attribute.lit.", 1, true) then
					lit_captures[vim.treesitter.get_node_text(node, lit_colors)] = name
				end
			end
		end
	end)
	assert(lit_captures[".value"] == "tag.attribute.lit.property")
	assert(lit_captures["?disabled"] == "tag.attribute.lit.boolean")
	assert(lit_captures["@click"] == "tag.attribute.lit.event")
	assert(lit_captures.class == nil)
	print("Lit binding highlight captures: OK")
	for _, language in ipairs({ "javascript", "typescript", "tsx" }) do
		local source = [[this.nombrePropiedad; this.nombreMetodo(); console.log("this");]]
		local parser = vim.treesitter.get_string_parser(source, language)
		local tree = parser:parse()[1]
		local query = vim.treesitter.query.get(language, "highlights")
		local this_count = 0
		for capture_id, node in query:iter_captures(tree:root(), source) do
			if query.captures[capture_id] == "variable.builtin.this" then
				assert(node:type() == "this" and vim.treesitter.get_node_text(node, source) == "this")
				this_count = this_count + 1
			end
		end
		assert(this_count == 2, language .. ": this highlighting must target only the keyword")
	end
	print("Neutral this capture (JS/TS/TSX): OK")
	local complexity = dofile(root .. "/lua/config/complexity.lua")
	local complexity_methods = complexity.analyze(
		[[function simple(value) { return value; } function complex(a, b) { if (a && b) return a ? 1 : 0; return 2; }]],
		"typescript"
	)
	assert(#complexity_methods == 2)
	assert(complexity_methods[1].score == 1)
	assert(complexity_methods[2].score == 4)
	assert(complexity.classify(7, { limit = 10, margin = 2 }) == "good")
	assert(complexity.classify(8, { limit = 10, margin = 2 }) == "near")
	assert(complexity.classify(11, { limit = 10, margin = 2 }) == "over")
	print("Method complexity analysis and thresholds: OK")
	vim.opt.runtimepath:prepend(plugins_dir .. "gruvbox.nvim")
	vim.opt.runtimepath:prepend(plugins_dir .. "catppuccin")
	for _, plugin in ipairs(plugins) do
		if plugin[1] == "ellisonleao/gruvbox.nvim" then
			require("gruvbox").setup(plugin.opts)
		end
	end
	dofile(root .. "/lua/config/catppuccin.lua")
	for _, scheme in ipairs({ "gruvbox", "catppuccin", "gruvbox" }) do
		vim.cmd.colorscheme(scheme)
		local function foreground(name)
			return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
		end
		local event = foreground("@tag.attribute.lit.event")
		local property = foreground("@tag.attribute.lit.property")
		local boolean = foreground("@tag.attribute.lit.boolean")
		assert(event and property and boolean and event ~= property and property ~= boolean and event ~= boolean)
		assert(vim.api.nvim_get_hl(0, { name = "MethodComplexityGood" }).link == "DiagnosticOk")
		assert(vim.api.nvim_get_hl(0, { name = "MethodComplexityNear" }).link == "DiagnosticWarn")
		assert(vim.api.nvim_get_hl(0, { name = "MethodComplexityOver" }).link == "DiagnosticError")
		assert(foreground("@lsp.type.property") == property)
		assert(foreground("@lsp.type.parameter") ~= property)
		assert(foreground("@variable.builtin.this") == foreground("Normal"))
		assert(foreground("@variable.builtin.this") ~= property)
		assert(foreground("@variable.builtin.this") ~= foreground("@function.method"))
		assert(vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = "@lsp.type.string", link = false })))
		assert(vim.api.nvim_get_hl(0, { name = "DiagnosticVirtualTextError", link = false }).bg == nil)
	end
	print("Gruvbox/Catppuccin semantic and Lit colors: OK")
	for _, language in ipairs({ "javascript", "typescript", "tsx" }) do
		local source =
			[[const view = html`<p>${name}</p>`; const styles = css`p { color: ${color}; display: block; }`;]]
		local parser = vim.treesitter.get_string_parser(source, language)
		parser:parse(true)
		local found = {}
		parser:for_each_tree(function(_, tree)
			found[tree:lang()] = true
		end)
		assert(found.html and found.css, language .. ": missing Lit HTML/CSS injection")
	end
	vim.opt.runtimepath:prepend(plugins_dir .. "LuaSnip")
	dofile(root .. "/lua/config/snippets.lua")
	print("Lit injections and snippet parsing: OK")
	local snippet_context = dofile(root .. "/lua/config/snippet_context.lua")
	vim.treesitter.language.register("javascript", "javascriptreact")
	vim.treesitter.language.register("tsx", "typescriptreact")
	for _, case in ipairs({
		{ "javascript", "const view = html`<div>snippet</div>`;", "snippet", true },
		{ "typescript", "const view = html`<div>snippet</div>`;", "snippet", true },
		{ "javascript", "const view = html`<div>${expression}</div>`;", "expression", false },
		{ "typescript", "const view = html`<div>${expression}</div>`;", "expression", false },
		{ "javascript", "const value = `plain string`;", "plain", false },
		{ "typescript", "const value = css`div { color: red; }`;", "color", false },
		{ "javascriptreact", "const view = <div>snippet</div>;", "snippet", false },
		{ "typescriptreact", "const view = <div>snippet</div>;", "snippet", false },
		{ "javascript", "const outside = 1;", "outside", false },
		{ "javascript", "const view = html`<p>${html`<b>nested</b>`}</p>`;", "nested", true },
		{ "typescript", "const view = html`<input .value=${value}>`;", "value}>", false },
	}) do
		vim.bo.filetype = case[1]
		vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { case[2] })
		vim.api.nvim_win_set_cursor(0, { 1, assert(case[2]:find(case[3], 1, true)) - 1 })
		vim.treesitter.get_parser(test_buf):parse(true)
		local filetypes = snippet_context.filetypes()
		assert(vim.tbl_contains(filetypes, "html") == case[4], "Unexpected HTML snippets: " .. case[2])
		assert(vim.tbl_contains(filetypes, case[1]), "Host snippets missing")
	end
	print("Contextual HTML snippets: OK")
	vim.bo.filetype = "javascript"
	vim.api.nvim_exec_autocmds("FileType", { buffer = test_buf })
	vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "class Component {", "}" })
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	local prefix = vim.g.maplocalleader or "\\"
	local property_mapping = vim.fn.maparg(prefix .. "lp", "n", false, true)
	assert(type(property_mapping.callback) == "function")
	property_mapping.callback()
	assert(table.concat(vim.api.nvim_buf_get_lines(test_buf, 0, -1, false), "\n"):find("@attr value", 1, true))
	require("luasnip").unlink_current()
	vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, { "class Component {", "}" })
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	local method_mapping = vim.fn.maparg(prefix .. "lm", "n", false, true)
	method_mapping.callback()
	assert(table.concat(vim.api.nvim_buf_get_lines(test_buf, 0, -1, false), "\n"):find("@param {string}", 1, true))
	require("luasnip").unlink_current()
	print("Documented Lit shortcut expansion: OK")
	vim.opt.runtimepath:prepend(plugins_dir .. "conform.nvim")
	vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
	dofile(root .. "/lua/config/conform.lua")
	vim.bo.filetype = "javascript"
	local real_format = dofile(root .. "/lua/config/format.lua")
	local contiguous = { "const before=1;", "const selected={value:2};", "const after=3;" }
	vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, contiguous)
	real_format.selection(2, 2)
	local actual = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
	assert(actual[1] == contiguous[1] and actual[3] == contiguous[3], "Unselected code changed")
	assert(actual[2] ~= contiguous[2] and actual[2]:find("value: 2", 1, true), "Selection was not formatted")
	vim.cmd.Format()
	actual = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
	assert(actual[1] ~= contiguous[1] and actual[3] ~= contiguous[3], "Full formatting did not cover the file")
	print("Prettier selection and full-file formatting: OK")
	vim.opt.runtimepath:prepend(plugins_dir .. "nvim-ufo")
	vim.opt.runtimepath:prepend(plugins_dir .. "promise-async")
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	local lit_fold_buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(lit_fold_buf)
	vim.api.nvim_buf_set_lines(lit_fold_buf, 0, -1, false, {
		"/**",
		" * Lit component.",
		" */",
		"export class Component extends LitElement {",
		"  static styles = css`",
		"    :host {",
		"      display: block;",
		"    }",
		"  `;",
		"  render() {",
		"    return html`",
		"      <section>",
		"        <span>${this.label}</span>",
		"      </section>",
		"    `;",
		"  }",
		"}",
	})
	vim.bo.filetype = "typescript"
	dofile(root .. "/lua/config/ufo.lua")
	local real_ufo = require("ufo")
	real_ufo.attach(lit_fold_buf)
	local provider = require("ufo.config").provider_selector(lit_fold_buf, "typescript", "")[1]
	local ranges = provider(lit_fold_buf)
	assert(type(ranges) == "table" and #ranges > 0, "No Lit folding ranges")
	local class_fold, method_fold, doc_fold, html_fold, css_fold = false, false, false, false, false
	local html_template_fold, css_template_fold = false, false
	for _, range in ipairs(ranges) do
		class_fold = class_fold or (range.startLine == 3 and range.endLine == 16)
		method_fold = method_fold or (range.startLine == 9 and range.endLine == 15)
		doc_fold = doc_fold or (range.startLine == 0 and range.endLine == 2)
		html_fold = html_fold or (range.kind == "element" and range.startLine == 11 and range.endLine == 13)
		css_fold = css_fold or (range.kind == "rule_set" and range.startLine == 5 and range.endLine == 7)
		html_template_fold = html_template_fold or (range.startLine == 10 and range.endLine == 14)
		css_template_fold = css_template_fold or (range.startLine == 4 and range.endLine == 8)
	end
	assert(
		class_fold and method_fold and doc_fold and html_fold and css_fold and html_template_fold and css_template_fold,
		vim.inspect(ranges)
	)
	vim.wo.foldenable = true
	real_ufo.applyFolds(lit_fold_buf, ranges)
	real_ufo.closeAllFolds()
	assert(vim.fn.foldclosed(4) == 4, "Class fold did not close")
	real_ufo.openAllFolds()
	assert(vim.fn.foldclosed(4) == -1, "Class fold did not open")
	vim.api.nvim_win_set_cursor(0, { 11, 0 })
	vim.cmd("normal! zc")
	assert(vim.fn.foldclosed(11) == 11 and vim.fn.foldclosedend(11) == 15, "HTML template did not close")
	real_ufo.openAllFolds()
	vim.api.nvim_win_set_cursor(0, { 12, 0 })
	vim.cmd("normal! zc")
	assert(vim.fn.foldclosed(12) == 12 and vim.fn.foldclosedend(12) == 14, "Inner HTML element did not close")
	real_ufo.openAllFolds()
	vim.cmd.LargeFileOn()
	assert(not real_ufo.hasAttached(lit_fold_buf) and not vim.wo.foldenable)
	vim.cmd.LargeFileOff()
	assert(real_ufo.hasAttached(lit_fold_buf))
	print("UFO Lit ranges and large-file lifecycle: OK")
	for _, filetype in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
		local cold_buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_set_current_buf(cold_buf)
		vim.api.nvim_buf_set_lines(cold_buf, 0, -1, false, {
			"const view = html`",
			"  <section>",
			"    content",
			"  </section>",
			"`;",
		})
		vim.bo.filetype = filetype
		real_ufo.attach(cold_buf)
		local cold_provider = require("ufo.config").provider_selector(cold_buf, filetype, "")[1]
		local function has_element(start_line, end_line)
			for _, range in ipairs(cold_provider(cold_buf)) do
				if range.kind == "element" and range.startLine == start_line and range.endLine == end_line then
					return true
				end
			end
			return false
		end
		assert(has_element(1, 3), filetype .. ": HTML fold missing on cold open")
		vim.api.nvim_buf_set_lines(cold_buf, 2, 3, false, { "    <div>", "      content", "    </div>" })
		assert(has_element(2, 4), filetype .. ": HTML fold missing after edit")
		vim.api.nvim_buf_delete(cold_buf, { force = true })
	end
	vim.api.nvim_set_current_buf(lit_fold_buf)
	print("Lit cold-open and incremental folds (JS/TS/JSX/TSX): OK")
	local started = vim.uv.hrtime()
	for _ = 1, 1000 do
		fold_settings.fold_virt_text_handler({ { "render() {", "Function" } }, 1, 50, 80, truncate_fold)
	end
	print(("Fold summary: 1000 renders in %.2f ms"):format((vim.uv.hrtime() - started) / 1e6))
end

print("Configuration checks: OK")
