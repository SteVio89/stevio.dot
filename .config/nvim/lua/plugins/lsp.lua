vim.pack.add({
	{ src = "https://github.com/artemave/workspace-diagnostics.nvim", name = "workspace-diagnostics" },
})

require("workspace-diagnostics").setup()

vim.lsp.config("scls", {
	cmd = { "simple-completion-language-server" },
	filetypes = {
		"lua",
		"go",
		"sh",
		"bash",
		"zsh",
		"zig",
		"c",
		"cpp",
		"nix",
		"markdown",
		"text",
		"gitcommit",
		"json",
		"yaml",
		"toml",
		"typescript",
		"javascript",
		"java",
		"rust",
		"kotlin",
		"sql",
	},
	settings = {
		feature_words = true,
		feature_paths = true,
	},
})

vim.lsp.config("postgres_lsp", {
	root_markers = { "postgres-language-server.jsonc", "postgrestools.jsonc", ".git" },
	workspace_required = true,
})

vim.lsp.config("zls", {
	settings = {
		zls = {
			enable_build_on_save = true,
		},
	},
})

vim.lsp.config("golangci_lint_ls", {
	init_options = {
		command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false", "--issues-exit-code=1" },
	},
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("zls")
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("kotlin_lsp")
vim.lsp.enable("nixd")
vim.lsp.enable("nil_ls")
vim.lsp.enable("vtsls")
vim.lsp.enable("postgres_lsp")
vim.lsp.enable("golangci_lint_ls")
vim.lsp.enable("copilot")
vim.lsp.enable("scls")
vim.lsp.enable("yamlls")
vim.lsp.inlay_hint.enable()

vim.keymap.set("n", "<leader>fT", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients == 0 then
		vim.notify("No LSP client attached — nothing to populate", vim.log.levels.WARN)
		return
	end
	for _, client in ipairs(clients) do
		require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
	end
	vim.notify("Populating workspace diagnostics for all project files…", vim.log.levels.INFO)
end, { desc = "Find trouble (workspace-wide diagnostics)" })

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show lsp hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "<leader>ca", function()
	require("tiny-code-action").code_action()
end, { desc = "Code action" })
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true })
end, { desc = "Code format" })
vim.keymap.set("n", "<leader>cr", function()
	vim.lsp.buf.rename()
end, { desc = "Rename" })

local doc_hl = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight") then
			return
		end

		vim.api.nvim_clear_autocmds({ group = doc_hl, buffer = ev.buf })
		vim.b[ev.buf].minicursorword_disable = true

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = doc_hl,
			buffer = ev.buf,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = doc_hl,
			buffer = ev.buf,
			callback = vim.lsp.buf.clear_references,
		})
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(ev)
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
			if c.id ~= ev.data.client_id and c:supports_method("textDocument/documentHighlight") then
				return
			end
		end
		vim.lsp.buf.clear_references()
		vim.api.nvim_clear_autocmds({ group = doc_hl, buffer = ev.buf })
		vim.b[ev.buf].minicursorword_disable = false
	end,
})
