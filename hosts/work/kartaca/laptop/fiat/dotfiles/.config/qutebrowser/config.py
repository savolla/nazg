c = c
config = config
config.load_autoconfig(False)  # was True — dangerous, fixed
c.auto_save.session = True
c.content.autoplay = True # fix calendar/gmail/google chat notification sounds are muted
config.set("content.cookies.accept", "all") # auto accept cookies
config.set("content.cookies.store", True) # store cookies

config.set("content.headers.accept_language", "", "https://matchmaker.krunker.io/*")

config.set("content.pdfjs", True)

config.set("content.images", True, "chrome-devtools://*")
config.set("content.images", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome-devtools://*")
config.set("content.javascript.enabled", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome://*/*")
config.set("content.javascript.enabled", True, "qute://*/*")
config.set("content.javascript.enabled", True, "https://chatgpt.com/")
config.set("content.javascript.enabled", True, "*://*.chatgpt.com/*")

config.set(
    "content.local_content_can_access_remote_urls",
    True,
    "file:///home/kkoc/.local/share/qutebrowser/userscripts/*",
)

config.set(
    "content.local_content_can_access_file_urls",
    False,
    "file:///home/kkoc/.local/share/qutebrowser/userscripts/*",
)

c.content.notifications.enabled = True
c.content.notifications.presenter = "libnotify"  # explicit, reliable
# c.content.notifications.presenter = "auto"  # testing (remove if no notifications shown)
c.content.persistent_storage = True

#####################################################################
# Notification permissions
config.set("content.notifications.enabled", True, "https://app.slack.com")
config.set("content.notifications.enabled", True, "https://calendar.google.com")

# gmail/chat etc.
config.set("content.notifications.enabled", True, "https://mail.google.com:433")
config.set("content.notifications.enabled", True, "https://chat.google.com:433")

# Protocol handler permissions
config.set("content.register_protocol_handler", True, "https://calendar.google.com?cid=%25s")
config.set("content.register_protocol_handler", True, "https://mail.google.com?extsrc=mailto&url=%25s")
#####################################################################

# # slack settings
# config.set("content.notifications.enabled", True, "https://app.slack.com/*")
# config.set("content.media.audio_capture", True, "https://app.slack.com/*")
# config.set("content.register_protocol_handler", True, "https://app.slack.com/*")


# # website settings — fixed patterns with /*
# config.set("content.notifications.enabled", True, "https://chat.google.com")
# config.set("content.notifications.enabled", True, "https://calendar.google.com/*")
# config.set("content.notifications.enabled", True, "https://mail.google.com/*")
# config.set("content.notifications.enabled", True, "https://web.whatsapp.com/*")

# config.set("content.media.audio_capture", True, "https://chat.google.com")
# config.set("content.media.audio_capture", True, "https://calendar.google.com/*")
# config.set("content.media.audio_capture", True, "https://mail.google.com/*")
# config.set("content.media.audio_capture", True, "https://web.whatsapp.com/*")


# config.set("content.register_protocol_handler", True, "https://calendar.google.com?cid=%25s")
# config.set("content.register_protocol_handler", True, "https://mail.google.com?extsrc=mailto&url=%25s")
# config.set("content.register_protocol_handler", True, "https://chat.google.com?extsrc=mailto&url=%25s")

# config.set("content.media.audio_capture", True, "https://calendar.google.com?cid=%25s")
# config.set("content.media.audio_capture", True, "https://mail.google.com?extsrc=mailto&url=%25s")
# config.set("content.media.audio_capture", True, "https://chat.google.com?extsrc=mailto&url=%25s")

c.content.media.audio_video_capture = True
c.content.media.audio_capture = True

c.completion.use_best_match = True
c.tabs.position = "right"
c.tabs.width = "20%"
c.tabs.pinned.shrink = False
c.tabs.title.format_pinned = "{audio}{index} {current_title}"
c.tabs.show = "always"
c.tabs.show_switching_delay = 2500
c.window.transparent = True
c.zoom.default = "120%"

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "never"

c.fonts.default_size = "13pt"
c.fonts.default_family = ["IosevkaTerm Nerd Font Mono"]

c.tabs.select_on_remove = "next"
c.tabs.title.format = "{audio}{index} {current_title}"
c.tabs.undo_stack_size = 50

c.session.default_name = "main"

# adblockers
c.content.blocking.adblock.lists = [
    # ── Core (keep what you have) ──────────────────────────────────────────
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist.to/easylist/fanboy-social.txt",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://easylist-downloads.adblockplus.org/easylistdutch.txt",
    "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
    "https://www.i-dont-care-about-cookies.eu/abp/",

    # ── AdGuard (great complement to EasyList, different rule sources) ─────
    "https://filters.adtidy.org/extension/ublock/filters/2.txt",   # AdGuard Base
    "https://filters.adtidy.org/extension/ublock/filters/3.txt",   # AdGuard Tracking Protection
    "https://filters.adtidy.org/extension/ublock/filters/14.txt",  # AdGuard Annoyances
    "https://filters.adtidy.org/extension/ublock/filters/17.txt",  # AdGuard Social Media

    # ── Privacy / tracking ────────────────────────────────────────────────
    # AdGuard's URL tracking parameter stripping (utm_*, fbclid, etc.)
    "https://filters.adtidy.org/extension/ublock/filters/17.txt",
    # Peter Lowe's ad and tracking server list (long-standing, well maintained)
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext",

    # ── Malware / phishing ────────────────────────────────────────────────
    # URLhaus - malware URLs from Abuse.ch, updated twice daily
    "https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-online.txt",
    # Phishing Army extended blocklist
    "https://phishing.army/download/phishing_army_blocklist_extended.txt",

    # ── Misc annoyances ───────────────────────────────────────────────────
    # uBlock Origin's own unbreak list (prevents over-blocking)
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
    # uBlock Origin's own annoyances
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
    # uBlock Origin's privacy filters
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
]

c.url.default_page = "https://savolla.github.io"
c.url.start_pages = ["https://savolla.github.io"]

# THEME
# base16-qutebrowser (https://github.com/theova/base16-qutebrowser)
# Scheme name: Gruvbox Material Dark, Hard
# Scheme author: Mayush Kumar (https://github.com/MayushKumar), sainnhe (https://github.com/sainnhe/gruvbox-material-vscode)
# Template author: theova
# Commentary: Tinted Theming: (https://github.com/tinted-theming)

base00 = "#202020"
base01 = "#2a2827"
base02 = "#504945"
base03 = "#5a524c"
base04 = "#bdae93"
base05 = "#ddc7a1"
base06 = "#ebdbb2"
base07 = "#fbf1c7"
base08 = "#ea6962"
base09 = "#e78a4e"
base0A = "#d8a657"
base0B = "#a9b665"
base0C = "#89b482"
base0D = "#7daea3"
base0E = "#d3869b"
base0F = "#bd6f3e"

# set qutebrowser colors

# Text color of the completion widget. May be a single color to use for
# all columns or a list of three colors, one for each column.
c.colors.completion.fg = base05

# Background color of the completion widget for odd rows.
c.colors.completion.odd.bg = base01

# Background color of the completion widget for even rows.
c.colors.completion.even.bg = base00

# Foreground color of completion widget category headers.
c.colors.completion.category.fg = base0A

# Background color of the completion widget category headers.
c.colors.completion.category.bg = base00

# Top border color of the completion widget category headers.
c.colors.completion.category.border.top = base00

# Bottom border color of the completion widget category headers.
c.colors.completion.category.border.bottom = base00

# Foreground color of the selected completion item.
c.colors.completion.item.selected.fg = base05

# Background color of the selected completion item.
c.colors.completion.item.selected.bg = base02

# Top border color of the selected completion item.
c.colors.completion.item.selected.border.top = base02

# Bottom border color of the selected completion item.
c.colors.completion.item.selected.border.bottom = base02

# Foreground color of the matched text in the selected completion item.
c.colors.completion.item.selected.match.fg = base0B

# Foreground color of the matched text in the completion.
c.colors.completion.match.fg = base0B

# Color of the scrollbar handle in the completion view.
c.colors.completion.scrollbar.fg = base05

# Color of the scrollbar in the completion view.
c.colors.completion.scrollbar.bg = base00

# Background color of disabled items in the context menu.
c.colors.contextmenu.disabled.bg = base01

# Foreground color of disabled items in the context menu.
c.colors.contextmenu.disabled.fg = base04

# Background color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.bg = base00

# Foreground color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.fg =  base05

# Background color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.bg = base02

#Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.fg = base05

# Background color for the download bar.
c.colors.downloads.bar.bg = base00

# Color gradient start for download text.
c.colors.downloads.start.fg = base00

# Color gradient start for download backgrounds.
c.colors.downloads.start.bg = base0D

# Color gradient end for download text.
c.colors.downloads.stop.fg = base00

# Color gradient stop for download backgrounds.
c.colors.downloads.stop.bg = base0C

# Foreground color for downloads with errors.
c.colors.downloads.error.fg = base08

# my custom hints
c.colors.keyhint.bg        = "#32302f"
c.colors.keyhint.fg        = "#ebdbb2"
c.colors.keyhint.suffix.fg = "#fe8019"
c.colors.hints.bg       = "#3c3836"
c.colors.hints.fg       = "#ebdbb2"
c.colors.hints.match.fg = "#fe8019"
c.hints.border          = "0px solid #b8bb26"

# Foreground color of an error message.
c.colors.messages.error.fg = base00

# Background color of an error message.
c.colors.messages.error.bg = base08

# Border color of an error message.
c.colors.messages.error.border = base08

# Foreground color of a warning message.
c.colors.messages.warning.fg = base00

# Background color of a warning message.
c.colors.messages.warning.bg = base0E

# Border color of a warning message.
c.colors.messages.warning.border = base0E

# Foreground color of an info message.
c.colors.messages.info.fg = base05

# Background color of an info message.
c.colors.messages.info.bg = base00

# Border color of an info message.
c.colors.messages.info.border = base00

# Foreground color for prompts.
c.colors.prompts.fg = base05

# Border used around UI elements in prompts.
c.colors.prompts.border = base00

# Background color for prompts.
c.colors.prompts.bg = base00

# Background color for the selected item in filename prompts.
c.colors.prompts.selected.bg = base02

# Foreground color for the selected item in filename prompts.
c.colors.prompts.selected.fg = base05

# Foreground color of the statusbar.
c.colors.statusbar.normal.fg = base0B

# Background color of the statusbar.
c.colors.statusbar.normal.bg = base00

# Foreground color of the statusbar in insert mode.
c.colors.statusbar.insert.fg = base00

# Background color of the statusbar in insert mode.
c.colors.statusbar.insert.bg = base0D

# Foreground color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.fg = base00

# Background color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.bg = base0C

# Foreground color of the statusbar in private browsing mode.
c.colors.statusbar.private.fg = base00

# Background color of the statusbar in private browsing mode.
c.colors.statusbar.private.bg = base01

# Foreground color of the statusbar in command mode.
c.colors.statusbar.command.fg = base05

# Background color of the statusbar in command mode.
c.colors.statusbar.command.bg = base00

# Foreground color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.fg = base05

# Background color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.bg = base00

# Foreground color of the statusbar in caret mode.
c.colors.statusbar.caret.fg = base00

# Background color of the statusbar in caret mode.
c.colors.statusbar.caret.bg = base0E

# Foreground color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.fg = base00

# Background color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.bg = base0D

# Background color of the progress bar.
c.colors.statusbar.progress.bg = base0D

# Default foreground color of the URL in the statusbar.
c.colors.statusbar.url.fg = base05

# Foreground color of the URL in the statusbar on error.
c.colors.statusbar.url.error.fg = base08

# Foreground color of the URL in the statusbar for hovered links.
c.colors.statusbar.url.hover.fg = base05

# Foreground color of the URL in the statusbar on successful load
# (http).
c.colors.statusbar.url.success.http.fg = base0C

# Foreground color of the URL in the statusbar on successful load
# (https).
c.colors.statusbar.url.success.https.fg = base0B

# Foreground color of the URL in the statusbar when there's a warning.
c.colors.statusbar.url.warn.fg = base0E

# Background color of the tab bar.
c.colors.tabs.bar.bg = base00

# Color gradient start for the tab indicator.
c.colors.tabs.indicator.start = base0D

# Color gradient end for the tab indicator.
c.colors.tabs.indicator.stop = base0C

# Color for the tab indicator on errors.
c.colors.tabs.indicator.error = base08

# Foreground color of unselected odd tabs.
c.colors.tabs.odd.fg = base05

# Background color of unselected odd tabs.
c.colors.tabs.odd.bg = base01

# Foreground color of unselected even tabs.
c.colors.tabs.even.fg = base05

# Background color of unselected even tabs.
c.colors.tabs.even.bg = base00

# Background color of pinned unselected even tabs.
c.colors.tabs.pinned.even.bg = base00

# Foreground color of pinned unselected even tabs.
c.colors.tabs.pinned.even.fg = "#fe8019"

# Background color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.bg = base01

# Foreground color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.fg = "#fe8019"

# Background color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.bg = base02

# Foreground color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.fg = base05

# Background color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.bg = base02

# Foreground color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.fg = base05

# Foreground color of selected odd tabs.
c.colors.tabs.selected.odd.fg = base05

# Background color of selected odd tabs.
c.colors.tabs.selected.odd.bg = base02

# Foreground color of selected even tabs.
c.colors.tabs.selected.even.fg = base05

# Background color of selected even tabs.
c.colors.tabs.selected.even.bg = base02

# Background color for webpages if unset (or empty to use the theme's
# color).
# c.colors.webpage.bg = base00


# # ---------------------------------------------------------------------------
# # Gruvbox Hard Dark color scheme
# # bg0_hard  #1d2021  ← new base (was #282828)
# # bg0       #282828  ← used sparingly for slight contrast
# # bg1       #32302f  ← alternating rows (was #3c3836)
# # bg2       #3c3836  ← selected/hover backgrounds
# # bg3       #504945  ← private/muted
# # fg        #ebdbb2
# # yellow    #b8bb26
# # orange    #fe8019
# # red       #fb4934
# # blue      #83a598
# # purple    #d3869b
# # ---------------------------------------------------------------------------

# # pinned tabs
# c.colors.tabs.pinned.selected.even.bg = '#282828'
# c.colors.tabs.pinned.selected.odd.bg = '#ebdbb2'

# # Backgrounds
# c.colors.webpage.bg            = "#1d2021"
# c.colors.statusbar.normal.bg   = "#1d2021"
# c.colors.statusbar.insert.bg   = "#32302f"
# c.colors.statusbar.passthrough.bg = "#32302f"
# c.colors.statusbar.caret.bg    = "#d3869b"
# c.colors.statusbar.command.bg  = "#1d2021"
# c.colors.statusbar.private.bg  = "#504945"

# # Foregrounds
# c.colors.statusbar.normal.fg      = "#ebdbb2"
# c.colors.statusbar.insert.fg      = "#ebdbb2"
# c.colors.statusbar.caret.fg       = "#1d2021"
# c.colors.statusbar.command.fg     = "#ebdbb2"
# c.colors.statusbar.private.fg     = "#ebdbb2"

# # URL colors
# c.colors.statusbar.url.fg              = "#ebdbb2"
# c.colors.statusbar.url.hover.fg        = "#83a598"
# c.colors.statusbar.url.success.http.fg = "#ebdbb2"
# c.colors.statusbar.url.success.https.fg= "#b8bb26"
# c.colors.statusbar.url.error.fg        = "#fb4934"
# c.colors.statusbar.url.warn.fg         = "#fe8019"

# # Completion widget
# c.colors.completion.fg                    = ["#ebdbb2", "#ebdbb2", "#ebdbb2"]
# c.colors.completion.odd.bg                = "#1d2021"
# c.colors.completion.even.bg               = "#32302f"
# c.colors.completion.item.selected.bg      = "#3c3836"
# c.colors.completion.item.selected.fg      = "#ebdbb2"
# c.colors.completion.match.fg              = "#fe8019"
# c.colors.completion.item.selected.match.fg= "#fe8019"
# c.colors.completion.scrollbar.fg          = "#b8bb26"
# c.colors.completion.scrollbar.bg          = "#32302f"

# # Prompts
# c.colors.prompts.bg          = "#32302f"
# c.colors.prompts.fg          = "#ebdbb2"
# c.colors.prompts.selected.bg = "#3c3836"
# c.colors.prompts.selected.fg = "#b8bb26"

# # Keyhints
# c.colors.keyhint.bg        = "#32302f"
# c.colors.keyhint.fg        = "#ebdbb2"
# c.colors.keyhint.suffix.fg = "#fe8019"

# # Hints
# c.colors.hints.bg       = "#3c3836"
# c.colors.hints.fg       = "#ebdbb2"
# c.colors.hints.match.fg = "#fe8019"
# c.hints.border          = "0px solid #b8bb26"

# # Tabs
# c.colors.tabs.bar.bg             = "#1d2021"
# c.colors.tabs.odd.bg             = "#1d2021"
# c.colors.tabs.even.bg            = "#32302f"
# c.colors.tabs.odd.fg             = "#a89984"  # dimmed fg for inactive tabs
# c.colors.tabs.even.fg            = "#a89984"
# c.colors.tabs.selected.even.bg   = "#a89984"
# c.colors.tabs.selected.even.fg   = "#282828"
# c.colors.tabs.selected.odd.bg    = "#a89984"
# c.colors.tabs.selected.odd.fg    = "#282828"

# # Downloads
# c.colors.downloads.bar.bg   = "#1d2021"
# c.colors.downloads.error.bg = "#fb4934"
# c.colors.downloads.error.fg = "#1d2021"
# c.colors.downloads.start.bg = "#83a598"
# c.colors.downloads.start.fg = "#1d2021"
# c.colors.downloads.stop.bg  = "#b8bb26"
# c.colors.downloads.stop.fg  = "#1d2021"

# # Messages
# c.colors.messages.error.bg   = "#fb4934"
# c.colors.messages.error.fg   = "#1d2021"
# c.colors.messages.warning.bg = "#fe8019"
# c.colors.messages.warning.fg = "#1d2021"
# c.colors.messages.info.bg    = "#1d2021"
# c.colors.messages.info.fg    = "#ebdbb2"

# Unbinds
# config.unbind("r") # refresh with r

# doom emacs keys
config.bind("<Space>:", "cmd-set-text : ;; message-info 'M-x'")
config.bind("<Space>hrr", ":config-source ;; message-info 'config reloaded'")

## tabs
config.bind("<Space>bb", "tab-focus last ;; message-info 'switched to last tab'")
config.bind("<Space>bn", ":open -t ;; message-info 'created new tab'")
config.bind("<Space>br", "cmd-set-text -s :tab-rename")  # fixed: use built-in tab-rename
config.bind("<Space>bR", ":reload")
config.bind("<Space>bk", ":tab-close ;; message-info 'closed tab'")
config.bind("<Space>bm", "tab-mute")
config.bind("<Space>bp", "tab-pin")
config.bind("<Space>bc", "tab-clone")
config.bind("<Ctrl-k>", "tab-move -")
config.bind("<Ctrl-j>", "tab-move +")
config.bind("<Space><Space>", "cmd-set-text -s :tab-select")

config.bind("<Space>g", "tab-focus 1")
config.bind("<Space>1", "tab-select 1")
config.bind("<Space>2", "tab-select 2")
config.bind("<Space>3", "tab-select 3")
config.bind("<Space>4", "tab-select 4")
config.bind("<Space>5", "tab-select 5")
config.bind("<Space>6", "tab-select 6")
config.bind("<Space>7", "tab-select 7")
config.bind("<Space>8", "tab-select 8")
config.bind("<Space>9", "tab-select 9")
config.bind("<Space>G", "tab-focus -1")

# config.bind('n',  'open -t about:blank') # open a blank

# password manager
config.bind(
    '<Space><l>',
    'spawn --userscript qute-pass '
    '--username-target secret '
    '--username-pattern "username: (.+)" '
    '--mode gopass '
    '--unfiltered '
    '--always-show-selection '
    '--dmenu-invocation \'dmenu -i -fn "IosevkaTerm NF:size=12:style=Regular" -nb "#282828" -nf "#a89984" -sb "#a89984" -sf "#282828"\''
)

# kartaca spesific keychords
## jenkins
config.bind('<Space>okjhA',  'open https://uretimbandi.kartaca.com/view/Bird/job/bird-usy/')
### preprod
config.bind('<Space>okjhpb', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/pretest-be-deploy/')
config.bind('<Space>okjhpf', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/pretest-fe-deploy/')

### test
config.bind('<Space>okjhtb', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/test-be-deploy/')
config.bind('<Space>okjhtf', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/test-fe-deploy/')

### staging
config.bind('<Space>okjhsb', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/staging-be-deploy/')
config.bind('<Space>okjhsf', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/staging-fe-deploy/')

### prod
config.bind('<Space>okjhPb', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/prod-be-deploy/')
config.bind('<Space>okjhPf', 'open https://uretimbandi.kartaca.com/job/bird-usy/job/prod-fe-deploy/')

## vault
config.bind('<Space>okv', 'open https://parola.kartaca.com/ui/vault/secrets')

## b2b
### dashboards
config.bind('<Space>okhp2d', 'open https://bird-pretest.test.kartaca.com/user/login?destination=admin/dashboard')
config.bind('<Space>okht2d', 'open https://bird.test.kartaca.com/user/login?destination=admin/dashboard')
config.bind('<Space>okhs2d', 'open https://bird.staging.kartaca.com/user/login?destination=admin/dashboard')
config.bind('<Space>okhP2d', 'open https://b2b.hopi.com.tr/user/login?destination=admin/dashboard')

### updates
config.bind('<Space>okhp2u', 'open https://bird-pretest.test.kartaca.com/update.php')
config.bind('<Space>okht2u', 'open https://bird.test.kartaca.com/update.php')
config.bind('<Space>okhs2u', 'open https://bird.staging.kartaca.com/update.php')
config.bind('<Space>okhP2u', 'open https://b2b.hopi.com.tr/update.php')

## rabbitmq
## cassandra reaper
## karbus
config.bind('<Space>okK', 'open https://karbus.kartaca.com/')
config.bind('<Space>okkrwr', 'open https://karbus.kartaca.com/remote-work-request')
config.bind('<Space>okkrwl', 'open https://karbus.kartaca.com/remote-works')

## atlassian
### timetracker
config.bind('<Space>okaT', 'open https://kartaca.atlassian.net/jira/apps/d95630c7-9fd4-495d-8988-b55637f4f8e9/1e298677-4dfa-4966-9486-544a5b279ca7')

### confluence
config.bind('<Space>okaj', 'open https://kartaca.atlassian.net/wiki/home')

# Files
config.bind("<Space>fh", "history --tab")
config.bind("<Space>fbb", "bookmark-list --tab")
config.bind("<Space>fba", "bookmark-add")
config.bind("<Space>fbd", "bookmark-del")
config.bind("<Space>fp", "config-edit")
config.bind("<Space>feU", "adblock-update")
config.bind("<Space>fqa", "quickmark-save")
config.bind("<Space>fqd", "cmd-set-text -s :quickmark-del")

# Frame
config.bind("<Space>Fb", "cmd-set-text --space :tab-take")
config.bind("<Space>FB", "tab-give")
config.bind("<Space>FD", "window-only")
config.bind("<Space>Fn", "tab-clone --window")

# session
config.bind("<Space>qq", "quit --save")
config.bind("<Space>qr", "restart")
config.bind("<Space>ff", "cmd-set-text --space :session-load --clear")
config.bind("<Space>fs", "cmd-set-text --space :session-save")

c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
}

# hints
c.hints.chars = "asdfjkl"

# search
config.bind("<Space>ss", "cmd-set-text /")
config.bind("<Space>sog", "cmd-set-text :open -t https://www.google.com/search?q=")
config.bind("<Space>soj", "cmd-set-text :open -t https://kartaca.atlassian.net/browse/")
config.bind("<Space>soy", "cmd-set-text :open -t https://www.youtube.com/results?search_query=")
config.bind("<Space>sod", "cmd-set-text :open -t https://duckduckgo.com/?q=")
config.bind("<Space>soR", "cmd-set-text :open -t https://rutracker.org/forum/tracker.php?nm=")
config.bind("<Space>sow", "cmd-set-text :open -t https://en.wikipedia.org/wiki/Special:Search/")
config.bind("<Space>soG", "cmd-set-text :open -t https://github.com/search?q=")
config.bind("<Space>sos", "cmd-set-text :open -t https://stackoverflow.com/search?q=")
config.bind("<Space>sor", "cmd-set-text :open -t https://www.reddit.com/search/?q=")
config.bind("<Space>soc", "cmd-set-text :open -t https://chat.openai.com/?q=")
config.bind("<Space>son", "cmd-set-text :open -t https://search.nixos.org/packages?channel=unstable&query=")


## toggles
config.bind("<Space>tt", "config-cycle tabs.show always never")
config.bind("<Space>ts", "config-cycle statusbar.show always never")
config.bind("<Space>td", "config-cycle colors.webpage.darkmode.enabled true false")

## help
config.bind("<Space>?", "bind")

## quickmark
config.bind("<Space><Return>", "cmd-set-text -s :quickmark-load -t")

## yank
config.bind("<Space>yy", "yank")
config.bind("<Space>yt", "yank title")
config.bind("<Space>yd", "yank domain")
config.bind("<Space>yo", "yank inline [[{url:yank}][{title}]]")
config.bind("<Space>yu", "hint links yank")

## misc
config.bind("<Space>eu", "cmd-set-text -s :open {url}")
config.bind("<Space>ov", "hint links spawn --detach mpv --ytdl-format=best {hint-url}")
config.bind(
    "<Space>dp",
    "spawn --detach wkhtmltopdf {url} /home/kkoc/resource/notes/org/roam/biblio/webpages/{title}.pdf"  # fixed username
)
config.bind("a", "mode-enter insert", mode="normal")


# THESE ADDED BY CLAUDE FOR QUTEBROWSER OPTIMIZATIONS. (consider removing if these don't work)
# ── Performance & Memory ──────────────────────────────────────────

# Don't restore all tabs at once on startup — load them on demand
config.set('session.lazy_restore', True)

# Cap the HTTP disk cache (default is uncapped and grows forever)
# 52428800 = 50MB
config.set('content.cache.size', 52428800)

# Cap in-memory page cache — how many pages to keep rendered in RAM
# Default is determined by Qt; 2 is safe for your 11GB system
# config.set('content.cache.maximum_pages', 2)

# Disable DNS prefetching — saves background CPU on many-tab setups
config.set('content.dns_prefetch', False)

# ── Tab behaviour ─────────────────────────────────────────────────

# Mute all tabs by default — prevents background video/audio draining CPU
# config.set('content.mute', True, '*') # do we really need this?
c.content.mute = False;

# Disable autoplay — biggest single source of background CPU usage
# config.set('content.autoplay', False)

# ── Rendering ─────────────────────────────────────────────────────

# Disable smooth scrolling — saves GPU compositing work on Vega 8
config.set('scrolling.smooth', False)

# Request reduced motion from websites (respects prefers-reduced-motion)
# Stops animation-heavy sites from thrashing your iGPU
config.set('content.prefers_reduced_motion', False) # websites will think you're a bot if you set it to True

# Disable canvas fingerprinting reads — also slightly reduces GPU work
config.set('content.canvas_reading', True) # cloudflare's and other captchas must use this for I'm not robot. keep it True

# ── Ad & tracker blocking ─────────────────────────────────────────

config.set('content.blocking.enabled', True)

# adblock method uses the Brave/uBO filter engine — much faster than hosts
config.set('content.blocking.method', 'adblock')

config.set('content.blocking.adblock.lists', [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt',
])

# ── JavaScript ────────────────────────────────────────────────────

# Suppress JS console noise from being processed by qutebrowser's Python layer
config.set('content.javascript.log_message.levels', {
    'qutebrowser': ['error'],
    'js-error': ['error'],
    'js-warning': [],
    'js-info': [],
    'js-debug': [],
})

# Clipboard access: 'ask' prompts on Qt 6.8+, behaves like 'none' on older Qt
config.set('content.javascript.clipboard', 'access')

# ── Completion / UI ───────────────────────────────────────────────

# Limit history shown in completion to reduce SQLite query size
config.set('completion.web_history.max_items', 1000)

# Delay before completion updates — reduces CPU on fast typing
config.set('completion.delay', 10)

config.set('qt.workarounds.disable_accelerated_2d_canvas', 'never') # for capthas and stability
