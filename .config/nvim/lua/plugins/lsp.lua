vim.pack.add({
	{ src = "https://github.com/artemave/workspace-diagnostics.nvim", name = "workspace-diagnostics" },
})

require("workspace-diagnostics").setup()

vim.lsp.config("postgres_lsp", {
	-- lspconfig defaults to `postgres-language-server`; the installed binary is `postgrestools`
	cmd = { "postgrestools", "lsp-proxy" },
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

vim.lsp.config("kotlin_lsp", {
	cmd = { "kotlin-lsp", "--stdio" },
	single_file_support = false,
	filetypes = { "kotlin" },
	root_markers = { "build.gradle", "build.gradle.kts", "pom.xml", "module.yaml", "project.yaml" },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("zls")
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("kotlin_lsp")
vim.lsp.enable("nixd")
vim.lsp.enable("vtsls")
vim.lsp.enable("postgres_lsp")
vim.lsp.enable("golangci_lint_ls")
vim.lsp.enable("yamlls")
vim.lsp.inlay_hint.enable()

-- TODO: drop once Neovim ships neovim/neovim#40569 (inlay hints moved onto the capability
-- framework). Until then, hints computed against a buffer that has since been edited past
-- place extmarks at stale columns and crash the decoration provider with "Invalid 'col'".
local inlay_hint_group = vim.api.nvim_create_augroup("InlayHintInsertGuard", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
	group = inlay_hint_group,
	callback = function(ev)
		vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	group = inlay_hint_group,
	callback = function(ev)
		vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
	end,
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true })
end, { desc = "Code format" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
		local fzf = require("fzf-lua")
		local function map(lhs, method, fn, desc)
			if client:supports_method(method) then
				vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
			end
		end
		map("gra", "textDocument/codeAction", function()
			require("tiny-code-action").code_action()
		end, "Code action")
		map("grr", "textDocument/references", fzf.lsp_references, "References")
		map("gO", "textDocument/documentSymbol", fzf.lsp_document_symbols, "Document symbols")
	end,
})

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
