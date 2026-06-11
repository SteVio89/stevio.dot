vim.lsp.config("scls", {
	cmd = { "simple-completion-language-server" },
	filetypes = {
		"lua", "go", "sh", "bash", "zsh", "zig", "c", "cpp", "nix",
		"markdown", "text", "gitcommit", "json", "yaml", "toml",
		"typescript", "javascript", "java", "rust", "kotlin",
	},
	settings = {
		feature_words = true,
		feature_paths = true,
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
vim.lsp.enable("copilot")
vim.lsp.enable("scls")
vim.lsp.inlay_hint.enable()
vim.lsp.inline_completion.enable()

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
