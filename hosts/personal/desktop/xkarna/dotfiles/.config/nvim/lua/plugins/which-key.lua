return {
  "folke/which-key.nvim",
  opts = {
    preset = "classic",
  },
  keys = {
    -- files
    { "<leader>ff", "<cmd>Yazi<cr>", desc = "find file" },
    { "<leader>fs", "<cmd>w<cr>", desc = "save file" },

    -- yank file path
    { "<leader>fy", "<cmd>let @+ = expand('%:p')<cr>", desc = "yank file path" },

    -- buffer
    {
      "<leader>bk",
      function()
        Snacks.bufdelete()
      end,
      desc = "kill buffer",
    },

    -- tabs
    { "<leader><tab>h", "<cmd>tabprevious<cr>", desc = "previous tab" },
    { "<leader><tab>l", "<cmd>tabnext<cr>", desc = "next tab" },

    -- terminal
    {
      "<leader>ot",
      function()
        Snacks.terminal(nil, { cwd = LazyVim.root() })
      end,
      desc = "toggle terminal",
    },
    -- neotree
    {
      "<leader>op",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "neotree",
    },

    -- misc
    { "<leader>hhr", "<cmd>Lazy reload<cr>", desc = "refresh config" },
  },
}
