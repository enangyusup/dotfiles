return {
  {
    "ibhagwan/fzf-lua",
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- invoke native setup
      require("fzf-lua").setup({
        -- Choose a default layout profile if desired (e.g., 'default', 'tmux', 'fzf-native', 'ivy')
        winopts = {
          height     = 0.85,
          width      = 0.80,
          row        = 0.35,
          col        = 0.50,
          preview = {
            layout   = "vertical", -- horizontal|vertical|flex
          },
        },
      })
    end,
    keys = {
      -- Set up your favorite keymaps
      { "<leader>t", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume Last Search" },
    },
  }
}
