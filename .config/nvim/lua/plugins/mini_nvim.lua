vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.nvim", name = "mini" },
})

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.misc").setup_auto_root({
	"Cargo.toml",
	"go.mod",
	"build.zig",
	"module.yaml",
	"project.yaml",
	"build.gradle.kts",
	"build.gradle",
	"pom.xml",
	"flake.nix",
	".git",
	"Makefile",
})
require("mini.trailspace").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup()
require("mini.notify").setup()
require("mini.surround").setup()
require("mini.statusline").setup({ use_icons = true })

require("mini.pairs").setup({
	modes = { insert = true, command = true, terminal = false },
})

require("mini.sessions").setup()
vim.keymap.set("n", "<leader>sw", function()
	local cwd = vim.fn.getcwd()
	local last_folder = cwd:match("([^/]+)$")
	require("mini.sessions").write(last_folder)
end, { desc = "Save session" })

vim.keymap.set("n", "<leader>ss", function()
	vim.cmd("wa")
	require("mini.sessions").write()
	require("mini.sessions").select()
end, { desc = "Switch session" })

vim.keymap.set("n", "<leader>sf", function()
	local sessions = require("mini.sessions").detected
	local names = vim.tbl_keys(sessions)
	table.sort(names)
	require("fzf-lua").fzf_exec(names, {
		prompt = "Sessions> ",
		actions = {
			["default"] = function(selected)
				require("mini.sessions").read(selected[1])
			end,
		},
	})
end, { desc = "Find session" })

require("mini.visits").setup()

local PIN_LABEL = "core"

local function visits_picker(prompt, filter)
	local paths = require("mini.visits").list_paths(nil, filter and { filter = filter } or {})
	if #paths == 0 then
		vim.notify("No visited paths yet", vim.log.levels.INFO)
		return
	end
	local by_display = {}
	local display = {}
	for _, p in ipairs(paths) do
		local short = vim.fn.fnamemodify(p, ":.")
		by_display[short] = p
		table.insert(display, short)
	end
	require("fzf-lua").fzf_exec(display, {
		prompt = prompt,
		actions = {
			["default"] = function(selected)
				local target = selected and by_display[selected[1]]
				if target then
					vim.cmd.edit(vim.fn.fnameescape(target))
				end
			end,
		},
	})
end

vim.keymap.set("n", "<leader>fo", function()
	visits_picker("Recent> ")
end, { desc = "Recent files (this project)" })

vim.keymap.set("n", "<leader>fp", function()
	visits_picker("Pinned> ", PIN_LABEL)
end, { desc = "Pinned files" })

vim.keymap.set("n", "<leader>tp", function()
	local MiniVisits = require("mini.visits")
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
	if path == "" or vim.fn.filereadable(path) ~= 1 then
		vim.notify("Not a file on disk", vim.log.levels.WARN)
		return
	end
	if vim.tbl_contains(MiniVisits.list_paths(nil, { filter = PIN_LABEL }), path) then
		MiniVisits.remove_label(PIN_LABEL, path)
		vim.notify("Unpinned " .. vim.fn.fnamemodify(path, ":t"))
	else
		MiniVisits.add_label(PIN_LABEL, path)
		vim.notify("Pinned " .. vim.fn.fnamemodify(path, ":t"))
	end
end, { desc = "Pin / unpin file" })

local miniclue = require("mini.clue")
miniclue.setup({
	window = {
		config = {
			width = "auto",
			border = "double",
		},
		delay = 250,
	},
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "'" },
		{ mode = "x", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "n", keys = "s" },
		{ mode = "x", keys = "s" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		{ mode = "n", keys = "<Leader>f", desc = "+find" },
		{ mode = "n", keys = "<Leader>t", desc = "+toggle" },
		{ mode = "n", keys = "<Leader>b", desc = "+buffer" },
		{ mode = "n", keys = "<Leader>g", desc = "+git" },
		{ mode = "x", keys = "<Leader>g", desc = "+git" },
		{ mode = "n", keys = "<Leader>c", desc = "+code" },
		{ mode = "n", keys = "<Leader>o", desc = "+open" },
		{ mode = "n", keys = "<Leader>s", desc = "+session" },
		{ mode = "n", keys = "s", desc = "+surround" },
		{ mode = "x", keys = "s", desc = "+surround" },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
	},
})

local ai = require("mini.ai")
ai.setup({
	custom_textobjects = {
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
		a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
	},
})
