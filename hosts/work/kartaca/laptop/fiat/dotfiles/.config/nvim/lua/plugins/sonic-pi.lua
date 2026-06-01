return {
  "magicmonty/sonicpi.nvim",
  config = function()
    require("sonicpi").setup({
      server_dir = "/opt/sonic-pi/app/server",
      lsp_diagnostics = true,
      mappings = {
        { "n", "<leader>d", ":SonicPiStartDaemon<CR>", { desc = "Sonic Pi: start daemon" } },
        { "n", "<leader>s", require("sonicpi.remote").stop, { desc = "Sonic Pi: stop" } },
        { "i", "<M-s>", require("sonicpi.remote").stop, { desc = "Sonic Pi: stop" } },
        { "n", "<leader>r", require("sonicpi.remote").run_current_buffer, { desc = "Sonic Pi: run" } },
        { "i", "<M-r>", require("sonicpi.remote").run_current_buffer, { desc = "Sonic Pi: run" } },
        { "n", "<leader>R", ":SonicPiSendBuffer<CR>", { desc = "Sonic Pi: send buffer" } },
        { "i", "<M-R>", ":SonicPiSendBuffer<CR>", { desc = "Sonic Pi: send buffer" } },
      },
      single_file = true,
    })
  end,
  dependencies = {
    "hrsh7th/nvim-cmp",
    "kyazdani42/nvim-web-devicons",
  },
}
