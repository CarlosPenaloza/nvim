-- lua/plugins/ui-productivity.lua
return {
	-- 1) which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { spelling = { enabled = false } },
			win = { border = "rounded" },
			show_help = true,
			show_keys = true,
		},
		config = function(_, opts)
			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.setup(opts)
				wk.add({
					{ "<leader>x", group = "Trouble / Diagnósticos" },
					{ "<leader>t", group = "TODOs" },
				})
			end
		end,
	},

	-- 2) trouble (solo declaración, config en config/diagnostics.lua)
	{
		"folke/trouble.nvim",
		branch = "main",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
	},

	-- 3) todo-comments
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			keywords = {
				TODO = { icon = "", color = "info" },
				FIX = { icon = "", color = "error", alt = { "FIXME", "BUG" } },
				HACK = { icon = "", color = "warning" },
				NOTE = { icon = "", color = "hint", alt = { "INFO" } },
			},
			highlight = { multiline = false },
			search = {
				command = "rg",
				args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
			},
		},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Siguiente TODO",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Anterior TODO",
			},
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Trouble: TODOs" },
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Telescope: TODOs" },
		},
	},
}
