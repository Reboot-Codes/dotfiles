vim.opt.expandtab = True
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.number = True
vim.opt.clipboard = "unnamed"

require("catppuccin").setup({
  flavour = "mocha",

  color_overrides = {
    mocha = {
      base = "#000000",
      -- mantle = "#000000",
      -- crust = "#000000"
    }
	}
})

vim.cmd.colorscheme "catppuccin"
