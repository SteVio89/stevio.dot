vim.pack.add({
	{ src = "https://github.com/milanglacier/minuet-ai.nvim", name = "minuet" },
})

local code_ft = {
	"lua",
	"go",
	"rust",
	"c",
	"cpp",
	"zig",
	"python",
	"bash",
	"sh",
	"typescript",
	"javascript",
	"java",
	"kotlin",
	"nix",
	"sql",
	"yaml",
}

require("minuet").setup({
	provider = "openai_fim_compatible",
	n_completions = 1,
	context_window = 2048,
	provider_options = {
		openai_fim_compatible = {
			name = "oMLX",
			end_point = "http://localhost:8000/v1/completions",
			model = "Mellum-4b-base-8bit",
			api_key = "TERM",
			stream = true,
			template = {
				prompt = function(before, after, _)
					return "<fim_suffix>" .. after .. "<fim_prefix>" .. before .. "<fim_middle>"
				end,
				suffix = false,
			},
			optional = {
				max_tokens = 64,
				temperature = 0,
				stop = { "\n", "<fim_suffix>", "<fim_prefix>", "<fim_middle>", "<|endoftext|>" },
			},
		},
	},
	lsp = {
		enabled_ft = code_ft,
		completion = { enable = false },
		inline_completion = { enable = true, enabled_auto_trigger_ft = code_ft },
	},
})
