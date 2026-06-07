/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*
 * function            description                     argument (example)
 *
 * battery_perc        battery percentage              battery name (BAT0)
 * cpu_perc            cpu usage in percent            NULL
 * datetime            date and time                   format string (%F %T)
 * disk_perc           disk usage in percent           mountpoint path (/)
 * ram_perc            memory usage in percent         NULL
 * run_command         custom shell command            command (echo foo)
 * wifi_essid          WiFi ESSID                      interface name (wlan0)
 */

/* ---------- CUSTOM COMMANDS ---------- */

static const char current_song[] =
    "get-currently-playing-song-from-mpd | cut -c1-40";

static const char cpu_padded[] =
    "printf '%02d' $(grep 'cpu ' /proc/stat | "
    "awk '{u=$2+$4;s=$2+$4+$5} "
    "NR==1{u1=u;s1=s; system(\"sleep 0.1\")} "
    "NR==2{printf ((u-u1)*100/(s-s1))+0}')";

static const char ram_padded[] =
    "free | awk '/Mem:/ {printf \"%02d\", ($3/$2) * 100}'";

static const char disk_padded[] =
    "df / | awk 'NR==2 {gsub(/%/, \"\", $5); printf \"%02d\", $5}'";

static const char volume_padded[] =
    "wpctl get-volume @DEFAULT_AUDIO_SINK@ | "
    "awk '{ "
    "if ($3 == \"[MUTED]\") print \"Off\"; "
    "else printf \"%02d\", $2 * 100 "
    "}'";

static const char network_status[] =
    "wifi_iface='wlp1s0'; "
    "eth_iface='eno1'; "

    "if [ \"$(cat /sys/class/net/$wifi_iface/operstate 2>/dev/null)\" = \"up\" ]; then "
        "ssid=$(iw dev $wifi_iface link | awk -F': ' '/SSID/ {print $2}'); "
        "signal=$(awk '/wlp1s0/ {print int($3 * 100 / 70)}' /proc/net/wireless); "
        "printf '  %s %02d%%' \"$ssid\" \"$signal\"; "
        "exit; "
    "fi; "

    "if [ \"$(cat /sys/class/net/$eth_iface/operstate 2>/dev/null)\" = \"up\" ]; then "
        "printf '󰈀 ethernet'; "
        "exit; "
    "fi; "

    "printf '󰖪 offline'";

/* ---------- STATUS BAR ---------- */

static const struct arg args[] = {
    /* function      format                  argument */

    { run_command,   "%s ",                 current_song },

    { run_command,   "󰋊  %s%% ",            disk_padded },

    { run_command,   "│   %s%% ",            cpu_padded },

    { run_command,   "│   %s%% ",            ram_padded },

    { run_command,   "│ 󰕾  %s%% ",            volume_padded },

    { run_command,   "│ %s ",                 network_status },

    { datetime,      "│   %s ",               "%a %d.%m.%Y │   %H:%M" },
};
