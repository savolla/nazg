#!/usr/bin/env bash
set -euo pipefail
export BROWSER="librewolf"

WEB_BROWSER="$(whereis "$BROWSER" | cut -d ' ' -f 2)"
SITES="wnextcloud\nnextcloud\nbrain\nwbrain\ndashboard\nrss\ngoogle\nyoutube\nportainer\nirc\ntodo\nnavidrome\nwdashboard\nwrss\nwgoogle\nwyoutube\nwportainer\nwirc\nwtodo\nwnavidrome\ngithub\narchwiki\ntranslate\nprotonmail\ndiscord\ngitsearch\ngitprofile\nblog\nwikipedia\nhackernews\nlibgen\nzlib\nstarpage\npiratebay\nuzem\nnews\n"
CHOICE=$(echo -e $SITES | rofi -dmenu -p "goto")

case $CHOICE in
    # portainer apps (HOME)
    # nextcloud)
    #     $WEB_BROWSER "http://192.168.1.194:10091" ;; # nextcloud
    dashboard)
        $WEB_BROWSER "http://192.168.1.194" ;; # heimdall
    rss)
        $WEB_BROWSER "http://192.168.1.194:10001/i/" ;; # freshrss
    google)
        $WEB_BROWSER "http://192.168.1.194:10000/" ;; # whoogle-search
    youtube)
        $WEB_BROWSER "http://192.168.1.194:3009/" ;; # invidious
    portainer)
        $WEB_BROWSER "https://192.168.1.194:9443/#!/home" ;; # portainer
    irc)
        $WEB_BROWSER "http://192.168.1.194:64080" ;; # quassel-web
    todo)
        $WEB_BROWSER "http://192.168.1.194:10100" ;; # kanboard
    spotify)
        $WEB_BROWSER "http://192.168.1.194:4533" ;; # navidrome
    notes)
        $WEB_BROWSER "http://192.168.1.194:10078" ;; # tiddlywiki

    # portainer apps (WORK)
    # wnextcloud)
    #     $WEB_BROWSER "http://192.168.68.194:10091" ;; # nextcloud
    wdashboard)
        $WEB_BROWSER "http://192.168.68.194" ;; # heimdall
    wrss)
        $WEB_BROWSER "http://192.168.68.194:10001/i/" ;; # freshrss
    wgoogle)
        $WEB_BROWSER "http://192.168.68.194:10000/" ;; # whoogle-search
    wyoutube)
        $WEB_BROWSER "http://192.168.68.194:3000/" ;; # invidious
    wportainer)
        $WEB_BROWSER "https://192.168.68.194:9443/#!/home" ;; # portainer
    wirc)
        $WEB_BROWSER "http://192.168.68.194:64080/" ;; # quassel-web
    wtodo)
        $WEB_BROWSER "http://192.168.68.194:10100" ;; # kanboard
    wspotify)
        $WEB_BROWSER "http://192.168.68.194:4533" ;; # navidrome
    wnotes)
        $WEB_BROWSER "http://192.168.68.194:10078" ;; # tiddlywiki

    # general web bookmarks
    piratebay)
        $WEB_BROWSER "https://thepiratebay.org/index.html" ;;
    discord)
        $WEB_BROWSER "https://discord.com/login" ;;
    uzem)
        $WEB_BROWSER "https://uzemders.duzce.edu.tr/" ;;
    translate)
        $WEB_BROWSER "https://lingva.ml/" ;;
    protonmail)
        $WEB_BROWSER "https://mail.protonmail.com/login" ;;
    startpage)
        $WEB_BROWSER "https://startpage.com/" ;;
    gitprofile)
        $WEB_BROWSER "https://github.com/savolla" ;;
    gitsearch)
        $WEB_BROWSER "https://github.com/search" ;;
    blog)
        $WEB_BROWSER "https://savolla.github.io/" ;;
    wikipedia)
        $WEB_BROWSER "https://www.wikipedia.org/" ;;
    archwiki)
        $WEB_BROWSER "https://wiki.archlinux.org/" ;;
    hackernews)
        $WEB_BROWSER "https://news.ycombinator.com/" ;;
    libgen)
        $WEB_BROWSER "http://libgen.rs/" ;;
    zlib)
        $WEB_BROWSER "https://1lib.net/" ;;
    news)
        $WEB_BROWSER "https://newslookup.com/results?ovs=&dp=&mt=-1&mtx=0&tp=&s=&groupby=no&cat=-1&fmt=&ut=&mkt=0&mktx=0&q=turkey&m=" ;;
    *)
        $WEB_BROWSER https://html.duckduckgo.com/html/?q="$CHOICE"&t=h_&ia=web
        # $WEB_BROWSER https://duckduckgo.com/?q="$CHOICE"&t=h_&ia=web
        # $WEB_BROWSER https://swisscows.com/web?query="$CHOICE"&region=tr-TR
        ;;
esac
