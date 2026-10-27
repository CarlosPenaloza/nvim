local function run(all, watch)
	local filename = vim.api.nvim_buf_get_name(0)
	local root = vim.fs.root(filename ~= "" and filename or vim.fn.getcwd(), {
		"web-test-runner.config.mjs",
		"web-test-runner.config.js",
		"package.json",
	})
	if not root then
		vim.notify("Web Test Runner: no project found", vim.log.levels.WARN)
		return
	end
	if not all and (filename == "" or vim.bo.buftype ~= "") then
		vim.notify("Web Test Runner: open a test file first", vim.log.levels.WARN)
		return
	end
	if vim.bo.modified then
		vim.notify("Web Test Runner: save changes before running tests", vim.log.levels.WARN)
		return
	end
	local directory, executable = root, nil
	while directory do
		local candidate = directory .. "/node_modules/.bin/web-test-runner"
		if vim.fn.executable(candidate) == 1 then
			executable = candidate
			break
		end
		local parent = vim.fs.dirname(directory)
		directory = parent ~= directory and parent or nil
	end
	if not executable then
		vim.notify("Web Test Runner: install @web/test-runner in this project", vim.log.levels.WARN)
		return
	end
	local command = { executable }
	if not all then
		vim.list_extend(command, { "--files", filename })
	end
	if watch then
		table.insert(command, "--watch")
	end
	vim.cmd("botright 12split")
	vim.cmd.enew()
	vim.fn.termopen(command, { cwd = root })
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("WebTest", function(args)
	run(false, args.bang)
end, { bang = true, desc = "Web Test Runner: current file (! watch)" })
vim.api.nvim_create_user_command("WebTestAll", function(args)
	run(true, args.bang)
end, { bang = true, desc = "Web Test Runner: project (! watch)" })
vim.keymap.set("n", "<leader>Tw", "<cmd>WebTest<cr>", { desc = "Test: Web Test Runner file" })
vim.keymap.set("n", "<leader>TW", "<cmd>WebTestAll<cr>", { desc = "Test: Web Test Runner project" })
