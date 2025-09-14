-- mini.hipatterns — colores en código (HEX + rgb(a) + hsl(a))
local ok, hipatterns = pcall(require, "mini.hipatterns")
if not ok then return end

-- Helpers
local function clamp(x, lo, hi)
  x = tonumber(x) or 0
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

-- hsl -> rgb (0–360, 0–100%, 0–100%)
local function hsl_to_rgb(h, s, l)
  h = ((tonumber(h) or 0) % 360) / 360
  s = clamp(tonumber(s) or 0, 0, 100) / 100
  l = clamp(tonumber(l) or 0, 0, 100) / 100
  if s == 0 then
    local v = math.floor(l * 255 + 0.5)
    return v, v, v
  end
  local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end
  local q = l < 0.5 and (l * (1 + s)) or (l + s - l * s)
  local p = 2 * l - q
  local r = hue2rgb(p, q, h + 1 / 3)
  local g = hue2rgb(p, q, h)
  local b = hue2rgb(p, q, h - 1 / 3)
  return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

hipatterns.setup({
  highlighters = {
    -- 1) HEX (#rgb/#rrggbb/#rrggbbaa) — generador oficial
    hex_color = hipatterns.gen_highlighter.hex_color(),

    -- 2) rgb()/rgba() — usa los 3 primeros números
    rgb_color = {
      pattern = "rgba?%(%s*%d+%s*,%s*%d+%s*,%s*%d+[^)]*%)",
      group = function(_, match)
        local nums = {}
        for n in match:gmatch("%d+") do
          nums[#nums + 1] = tonumber(n)
          if #nums == 3 then break end
        end
        local r, g, b = nums[1], nums[2], nums[3]
        if not (r and g and b) then return end
        r, g, b = clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255)
        local hex = string.format("#%02x%02x%02x", r, g, b)
        return hipatterns.compute_hex_color_group(hex, "bg")
      end,
    },

    -- 3) hsl()/hsla() — convierte a RGB (alpha ignorado para highlight)
    hsl_color = {
      pattern = "hsla?%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%[^)]*%)",
      group = function(_, match)
        local h, s, l = match:match("hsla?%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%")
        if not h then return end
        local r, g, b = hsl_to_rgb(h, s, l)
        local hex = string.format("#%02x%02x%02x", r, g, b)
        return hipatterns.compute_hex_color_group(hex, "bg")
      end,
    },
  },
})
