return {
  -- Base16 colorscheme for matugen-generated colors
  {
    "RRethy/base16-nvim",
    name = "base16-colorscheme",
    priority = 1000,
    config = function()
      -- Load the matugen-generated colors
      dofile(vim.fn.expand("~/.config/matugen/output/neovim-colors.lua"))
    end,
  },

  -- Disable plugins we're not using
  { "folke/tokyonight.nvim", enabled = false },
  { "RedsXDD/neopywal.nvim", enabled = false },

  -- Set base16 as default (the generated.lua applies it automatically)
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        -- Colors are already applied by generated.lua, just return nil
        -- to prevent LazyVim from trying to load a colorscheme by name
      end,
    },
  },
}
