local function set_inline_completion_hl()
	vim.api.nvim_set_hl(0, "ComplHint", { fg = "#585b70", italic = true })
	vim.api.nvim_set_hl(0, "ComplHintMore", { fg = "#585b70", italic = true })
end

set_inline_completion_hl()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_inline_completion_hl,
})

vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or not client:supports_method("textDocument/completion") then
			return
		end

		vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
	end,
})

-- Buffer-local: a global 'autocomplete' would double up with vim.lsp.completion elsewhere.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown", "text", "zsh" },
	callback = function(ev)
		vim.bo[ev.buf].complete = ".,w,b,u,kspell"
		vim.bo[ev.buf].autocomplete = true
	end,
})

vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	elseif vim.snippet.active({ direction = 1 }) then
		return "<cmd>lua vim.snippet.jump(1)<cr>"
	else
		return "<Tab>"
	end
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	elseif vim.snippet.active({ direction = -1 }) then
		return "<cmd>lua vim.snippet.jump(-1)<cr>"
	else
		return "<S-Tab>"
	end
end, { expr = true })

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return vim.keycode("<C-y>")
	else
		return require("mini.pairs").cr()
	end
end, { expr = true, replace_keycodes = false })

vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end)
