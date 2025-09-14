-- lua/config/globals.lua

local function ensure_file(path, content)
	local f = io.open(path, "r")
	if f ~= nil then
		f:close()
		return -- ya existe
	end

	-- crear archivo con contenido base
	f = io.open(path, "w")
	if f ~= nil then
		f:write(content)
		f:close()
		vim.notify("Se creó " .. path .. " con configuración base.", vim.log.levels.INFO)
	else
		vim.notify("No se pudo crear " .. path, vim.log.levels.ERROR)
	end
end

local home = vim.fn.expand("~")

-- ===== Prettier =====
local prettier_file = home .. "/.prettierrc.json"
local prettier_content = [[
{
  "singleQuote": true,
  "trailingComma": "all"
}
]]
ensure_file(prettier_file, prettier_content)

-- ===== ESLint =====
local eslint_file = home .. "/.eslintrc.json"
local eslint_content = [[
{
  "rules": {
    "quotes": ["error", "single", { "avoidEscape": true }],
    "comma-dangle": ["error", "always-multiline"],
    "semi": ["error", "always"]
  }
}
]]
ensure_file(eslint_file, eslint_content)
