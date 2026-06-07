-- ~/.config/nvim/lua/plugins/fzf-override.lua
return {
  "ibhagwan/fzf-lua",
  keys = {
    -- search in buffer
    { "<leader>ss", "<cmd>FzfLua grep_curbuf<cr>", desc = "search in file" },
    -- search all commands
    { "<leader>:", "<cmd>FzfLua commands<cr>", desc = "list all commands" },
  },
}
