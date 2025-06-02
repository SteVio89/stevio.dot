return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
			ensure_installed = {
				"gopls",
				"lua_ls",
				"rust_analyzer",
				"bashls",
				"zls",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		priority = 900,
		event = "BufReadPre",
		config = function()
			-- configure lsp server here
			vim.lsp.config("lua_ls", {})
			vim.lsp.config("rust_analzer", {})
			vim.lsp.config("gopls", {})
			vim.lsp.config("bashls", {})
			vim.lsp.config("zls", {})

			vim.lsp.enable("lua_ls")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("gopls")
			vim.lsp.enable("bashls")
			vim.lsp.enable("zls")
			--TODO: init missing lsp
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show lsp hover" })
			vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Goto definition" })
			vim.keymap.set("n", "<leader>cR", vim.lsp.buf.references, { desc = "Goto reference" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
			vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Code format" })
			vim.keymap.set("n", "<leader>cr", function()
				vim.lsp.buf.rename()
			end, { desc = "Rename" })
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		version = false,
		lazy = false,
		dependencies = {
			{
				"jay-babu/mason-null-ls.nvim",
				opts = {
					ensure_installed = { "stylua" },
				},
				config = function(_, opts)
					require("mason-null-ls").setup(opts)
				end,
			},
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
				},
			})
		end,
	},
}
