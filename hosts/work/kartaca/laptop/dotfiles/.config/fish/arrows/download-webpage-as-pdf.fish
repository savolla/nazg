#!/usr/bin/env fish
function __dlpdf -d "download webpage as pdf #misc :dlpdf"
    read -l -P "url: " url < /dev/tty
    test -z "$url" && return 1
    set download_path $HOME/resource/notes/org/roam/biblio/webpages
    set page_title (curl -s $url | grep -oP '(?<=<title>).*?(?=</title>)')
    set safe_title (echo $page_title | tr -cd '[:alnum:] ._-' | sed 's/  */ /g')
    echo "wkhtmltopdf $url \"$download_path/$safe_title.pdf\" && notify-send 'pdf downloader' '$safe_title is downloaded as pdf under $download_path'"
end
abbr -a dlpdf --function __dlpdf
