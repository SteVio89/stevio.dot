return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup({
				ensure_installed = {
					"gdtoolkit",
				},
			})
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
				"ols",
				"qmlls",
				"clangd",
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
			vim.lsp.config("gopls", {})
			vim.lsp.config("bashls", {})
			vim.lsp.config("zls", {})
			vim.lsp.config("ols", {})
			vim.lsp.config("qmlls", {})
			vim.lsp.config("gdscript", {})
			vim.lsp.config("clangd", {})

			vim.lsp.enable("lua_ls")
			vim.lsp.enable("gopls")
			vim.lsp.enable("bashls")
			vim.lsp.enable("zls")
			vim.lsp.enable("ols")
			vim.lsp.enable("qmlls")
			vim.lsp.enable("gdscript")
			vim.lsp.enable("clangd")

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
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{
		"MysticalDevil/inlay-hints.nvim",
		event = "LspAttach",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("inlay-hints").setup()
			vim.g.rustaceanvim = {
				server = {
					settings = {
						["rust-analyzer"] = {
							inlayHints = {
								bindingModeHints = {
									enable = false,
								},
								chainingHints = {
									enable = true,
								},
								closingBraceHints = {
									enable = true,
									minLines = 25,
								},
								closureReturnTypeHints = {
									enable = "never",
								},
								lifetimeElisionHints = {
									enable = "never",
									useParameterNames = false,
								},
								maxLength = 25,
								parameterHints = {
									enable = true,
								},
								reborrowHints = {
									enable = "never",
								},
								renderColons = true,
								typeHints = {
									enable = true,
									hideClosureInitialization = false,
									hideNamedConstructor = false,
								},
							},
						},
					},
				},
			}
		end,
	},
	{
		"S1M0N38/love2d.nvim",
		event = "VeryLazy",
		version = "2.*",
		opts = {},
		keys = {
			{ "<leader>vv", "<cmd>LoveRun<cr>", desc = "Run LÖVE" },
			{ "<leader>vs", "<cmd>LoveStop<cr>", desc = "Stop LÖVE" },
		},
	},
}
