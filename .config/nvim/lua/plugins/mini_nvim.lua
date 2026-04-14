vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.nvim", name = "mini" },
})

require("mini.icons").setup()
require("mini.misc").setup_auto_root()
require("mini.trailspace").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup()
require("mini.notify").setup()
require("mini.surround").setup()

require("mini.files").setup({
	windows = { preview = true },
	options = { use_as_default_explorer = true },
})

vim.keymap.set("n", "<leader>fe", function()
	local buffer_name = vim.api.nvim_buf_get_name(0)
	if buffer_name == "" or vim.fn.filereadable(buffer_name) == 0 then
		require("mini.files").open(vim.uv.cwd())
	else
		require("mini.files").open(buffer_name)
	end
end, { desc = "Open file explorer" })

require("mini.pairs").setup({
	modes = { insert = true, command = true, terminal = false },
})

require("mini.sessions").setup()
vim.keymap.set("n", "<leader>sS", function()
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
		-- Built-in completions
		{ mode = "i", keys = "<C-x>" },
		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "x", keys = "'" },
		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		-- Window commands
		{ mode = "n", keys = "<C-w>" },
		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
		-- Brackets
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		-- Your leader groups
		{ mode = "n", keys = "<Leader>a", desc = "+AI" },
		{ mode = "n", keys = "<Leader>f", desc = "+file" },
		{ mode = "n", keys = "<Leader>b", desc = "+buffer" },
		{ mode = "n", keys = "<Leader>g", desc = "+git" },
		{ mode = "n", keys = "<Leader>c", desc = "+code" },
		{ mode = "n", keys = "<Leader>o", desc = "+other" },
		{ mode = "n", keys = "<Leader>s", desc = "+sessions" },
		-- Built-in clue enhancers
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
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

-- local ai = require("mini.ai")
-- ai.setup({
--   custom_textobjects = {
--     f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
--     c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
--     a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
--   },
-- })
