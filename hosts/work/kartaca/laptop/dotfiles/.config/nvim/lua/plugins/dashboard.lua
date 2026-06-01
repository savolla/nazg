return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
                        ██  ██        
                        ██  ██        
  ████████████  ██████████  ██  ██████
  ██  ██▄▄████  ████  ████  ██  ██▄▄██
████  ██  ██  ██  ████████████████  ██
      
       we're just living to die       
]],
        keys = {},
      },
    },
  },
}
