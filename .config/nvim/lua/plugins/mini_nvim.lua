return {
	{
		"echasnovski/mini.icons",
		version = false,
	},
	{
		"echasnovski/mini.files",
		version = false,
		opts = {
			windows = {
				preview = true,
			},
			options = {
				use_as_default_explorer = true,
			},
		},
		keys = {
			{
				"<leader>fe",
				function()
					local buffer_name = vim.api.nvim_buf_get_name(0)
					if buffer_name == "" or string.match(buffer_name, "Starter") then
						require("mini.files").open(vim.loop.cwd())
					else
						require("mini.files").open(vim.api.nvim_buf_get_name(0))
					end
				end,
				desc = "Open file explorer",
				mode = "n",
			},
		},
		config = function(_, opts)
			require("mini.files").setup(opts)
		end,
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},
	{
		"echasnovski/mini.sessions",
		version = false,
		lazy = false,
		priority = 1000,
		keys = {
			{
				"<leader>sw",
				function()
					local cwd = vim.fn.getcwd()
					local last_folder = cwd:match("([^/]+)$")
					require("mini.sessions").write(last_folder)
				end,
				desc = "Save",
				mode = "n",
			},
			{
				"<leader>ss",
				function()
					vim.cmd("wa")
					require("mini.sessions").write()
					require("mini.sessions").select()
				end,
				desc = "Switch",
				mode = "n",
			},
			{
				"<leader>sf",
				function()
					vim.cmd("wa")
					require("mini.sessions").select()
				end,
				desc = "Find",
				mode = "n",
			},
		},
		opts = {},
		config = function(_, opts)
			require("mini.sessions").setup()
		end,
	},
	{
		"echasnovski/mini.starter",
		version = false,
		priority = 900,
		config = function()
			require("mini.starter").setup({
				items = {
					require("mini.starter").sections.sessions(5, true),
				},
				header = [[
 _____  _          _   _  _         _
/  ___|| |        | | | |(_)       ( )
\ `--. | |_   ___ | | | | _   ___  |/  ___
 `--. \| __| / _ \| | | || | / _ \    / __|
/\__/ /| |_ |  __/\ \_/ /| || (_) |   \__ \
\____/  \__| \___| \___/ |_| \___/    |___/
 _   _               _   _  _
| \ | |             | | | |(_)
|  \| |  ___   ___  | | | | _  _ __ ___
| . ` | / _ \ / _ \ | | | || || '_ ` _ \
| |\  ||  __/| (_) |\ \_/ /| || | | | | |
\_| \_/ \___| \___/  \___/ |_||_| |_| |_|
]],
			})
		end,
	},
	{
		"echasnovski/mini.pairs",
		version = false,
		opts = {
			modes = { insert = true, command = true, terminal = false },
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			skip_ts = { "string" },
			skip_unbalanced = true,
			markdown = true,
		},
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},
	{
		"echasnovski/mini.statusline",
		version = false,
		config = function()
			require("mini.statusline").setup()
		end,
	},
	{
		"echasnovski/mini.misc",
		version = false,
		config = function()
			require("mini.misc").setup_auto_root()
		end,
	},
	{
		"echasnovski/mini.trailspace",
		version = false,
		config = function()
			require("mini.trailspace").setup()
		end,
	},
	{
		"echasnovski/mini.cursorword",
		version = false,
		config = function()
			require("mini.cursorword").setup()
		end,
	},
	{
		"echasnovski/mini.indentscope",
		version = false,
		config = function()
			require("mini.indentscope").setup()
		end,
	},
	{
		"echasnovski/mini.jump",
		version = false,
		config = function()
			require("mini.jump").setup()
		end,
	},
	{
		"echasnovski/mini.jump2d",
		version = false,
		config = function()
			require("mini.jump2d").setup()
		end,
	},
	{
		"echasnovski/mini.notify",
		version = false,
		config = function()
			require("mini.notify").setup()
		end,
	},
}
