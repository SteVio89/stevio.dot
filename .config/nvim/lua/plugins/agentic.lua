return {
	"carlos-algms/agentic.nvim",
	dependencies = {
		{ "hakonharnes/img-clip.nvim", opts = {} },
	},
	opts = {
		provider = "claude-agent-acp",
		diff_preview = "split",
	},

	keys = {
		{
			"<leader>ao",
			function()
				require("agentic").open({ auto_add_to_context = false })
			end,
			mode = { "n" },
			desc = "Open Agentic chat",
		},
		{
			"<leader>aO",
			function()
				require("agentic").open()
			end,
			mode = { "n" },
			desc = "Open Agentic chat with context",
		},
		{
			"<leader>an",
			function()
				require("agentic").new_session_with_provider({ auto_add_to_context = false })
			end,
			mode = { "n" },
			desc = "New Agentic session",
		},
		{
			"<leader>aN",
			function()
				require("agentic").new_session_with_provider()
			end,
			mode = { "n" },
			desc = "New Agentic session with context",
		},
	},
}
