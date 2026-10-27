local luasnip = require("luasnip")
local parse = luasnip.parser.parse_snippet
local documented = {
	typescript = {
		property = [=[
/**
 * ${1:Property description.}
 * @type {${2:string}}
 * @default ${3:''}
 * @attr ${4:value}
 */
@property({ type: ${5:String} }) accessor $4: $2 = $3;
$0
]=],
		method = [=[
/**
 * ${1:Method description.}
 * @param ${2:value} - ${3:Parameter description.}
 * @returns ${4:Return description.}
 */
${5:methodName}($2: ${6:string}): ${7:void} {
  $0
}
]=],
	},
	javascript = {
		property = [=[
/**
 * ${1:Property description.}
 * @type {${2:string}}
 * @attr ${3:value}
 */
$3: { type: ${4:String} },
$0
]=],
		method = [=[
/**
 * ${1:Method description.}
 * @param {${2:string}} ${3:value} - ${4:Parameter description.}
 * @returns {${5:void}} ${6:Return description.}
 */
${7:methodName}($3) {
  $0
}
]=],
	},
}

for filetype, templates in pairs(documented) do
	luasnip.add_snippets(filetype, {
		parse({ trig = "lit-property-doc", name = "Lit documented property" }, templates.property),
		parse({ trig = "lit-method-doc", name = "Lit documented method" }, templates.method),
	}, { key = "web-lit-documented-" .. filetype })
end

local group = vim.api.nvim_create_augroup("config-lit-snippets", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "javascript", "typescript" },
	callback = function(args)
		for keys, kind in pairs({ ["<localleader>lp"] = "property", ["<localleader>lm"] = "method" }) do
			vim.keymap.set({ "n", "i" }, keys, function()
				local template = documented[vim.bo[args.buf].filetype][kind]
				local function expand()
					luasnip.snip_expand(parse({ trig = "", name = "Lit documented " .. kind }, template))
				end
				if vim.fn.mode() == "n" then
					vim.api.nvim_put({ "" }, "l", true, true)
				end
				expand()
			end, { buffer = args.buf, desc = "Lit: documented " .. kind })
		end
	end,
})

luasnip.add_snippets("typescript", {
	parse(
		{ trig = "lit-element", name = "Lit element (TypeScript decorators)" },
		[=[
import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('${1:my-element}')
export class ${2:MyElement} extends LitElement {
  @property({ type: String }) accessor ${3:label} = '${4:Hello}';

  static styles = css`
    :host {
      display: block;
    }
  `;

  render() {
    return html`<slot>\${this.$3}</slot>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    '$1': $2;
  }
}
$0
]=]
	),
	parse(
		{ trig = "lit-property", name = "Lit reactive property" },
		"@property({ type: ${1:String} }) accessor ${2:value} = ${3:''};$0"
	),
	parse(
		{ trig = "lit-state", name = "Lit internal state" },
		"@state() private accessor ${1:loading} = ${2:false};$0"
	),
	parse(
		{ trig = "lit-event", name = "Typed composed custom event" },
		[=[
this.dispatchEvent(new CustomEvent<${1:string}>('${2:value-changed}', {
  detail: ${3:this.value},
  bubbles: true,
  composed: true,
}));$0
]=]
	),
}, { key = "web-lit-typescript" })

luasnip.add_snippets("javascript", {
	parse(
		{ trig = "lit-element", name = "Lit element (JavaScript)" },
		[=[
import { LitElement, html, css } from 'lit';

export class ${1:MyElement} extends LitElement {
  static properties = { ${2:label}: { type: String } };

  constructor() {
    super();
    this.$2 = '${3:Hello}';
  }

  static styles = css`
    :host {
      display: block;
    }
  `;

  render() {
    return html`<slot>\${this.$2}</slot>`;
  }
}

customElements.define('${4:my-element}', $1);
$0
]=]
	),
	parse(
		{ trig = "lit-event", name = "Composed custom event" },
		[=[
this.dispatchEvent(new CustomEvent('${1:value-changed}', {
  detail: ${2:this.value},
  bubbles: true,
  composed: true,
}));$0
]=]
	),
}, { key = "web-lit-javascript" })
