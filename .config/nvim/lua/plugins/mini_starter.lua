return {
  "echasnovski/mini.starter",
  version = false,
  config = function()
    require("mini.starter").setup({
      autoopen = true,
      items = {
        require("mini.starter").sections.builtin_actions(),
        require("mini.starter").sections.sessions(10, true),
      },
      header = [[
  _____ _    __      ___       _       _   _        __      ___
 / ____| |   \ \    / (_)     ( )     | \ | |       \ \    / (_)
| (___ | |_ __\ \  / / _  ___ |/ ___  |  \| | ___  __\ \  / / _ _ __ ___
 \___ \| __/ _ \ \/ / | |/ _ \  / __| | . ` |/ _ \/ _ \ \/ / | | '_ ` _ \
 ____) | ||  __/\  /  | | (_) | \__ \ | |\  |  __/ (_) \  /  | | | | | | |
|_____/ \__\___| \/   |_|\___/  |___/ |_| \_|\___|\___/ \/   |_|_| |_| |_|]],
    })
  end
}
