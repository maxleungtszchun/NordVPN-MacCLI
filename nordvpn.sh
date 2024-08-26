#!/usr/bin/env zsh

function print_error { printf '%b' "\e[31m${1}\e[0m\n" >&2; }
function print_green { printf '%b' "\e[32m${1}\e[0m\n" 2>&1; }
function check_command { command -v "$1" &>/dev/null; }

function public_ip { printf '%b' "$(curl -s ipinfo.io)\n" }

function get_nordvpn_server {
    local country_name="${1:-United States}"
    local server_name

    check_command curl  || { print_error 'curl not found. install it with `brew install curl`'; return 1; }
    check_command jq    || { print_error 'jq not found. install it with `brew install jq`'; return 1; }
    check_command tr    || { print_error 'tr not found'; return 1; }

    case "${country_name:l}" in
        albania)                    country_id=2 ;;
        algeria)                    country_id=3 ;;
        andorra)                    country_id=5 ;;
        argentina)                  country_id=10 ;;
        armenia)                    country_id=11 ;;
        australia)                  country_id=13 ;;
        austria)                    country_id=14 ;;
        azerbaijan)                 country_id=15 ;;
        bahamas)                    country_id=16 ;;
        bangladesh)                 country_id=18 ;;
        belgium)                    country_id=21 ;;
        belize)                     country_id=22 ;;
        bermuda)                    country_id=24 ;;
        bhutan)                     country_id=25 ;;
        bolivia)                    country_id=26 ;;
        "bosnia and herzegovina")   country_id=27 ;;
        brazil)                     country_id=30 ;;
        brunei)                     country_id=32 ;;
        bulgaria)                   country_id=33 ;;
        cambodia)                   country_id=36 ;;
        canada)                     country_id=38 ;;
        "cayman islands")           country_id=40 ;;
        chile)                      country_id=43 ;;
        colombia)                   country_id=47 ;;
        "costa rica")               country_id=52 ;;
        croatia)                    country_id=54 ;;
        cyprus)                     country_id=56 ;;
        "czech republic")           country_id=57 ;;
        denmark)                    country_id=58 ;;
        "dominican republic")       country_id=61 ;;
        ecuador)                    country_id=63 ;;
        egypt)                      country_id=64 ;;
        "el salvador")              country_id=65 ;;
        estonia)                    country_id=68 ;;
        finland)                    country_id=73 ;;
        france)                     country_id=74 ;;
        georgia)                    country_id=80 ;;
        germany)                    country_id=81 ;;
        ghana)                      country_id=82 ;;
        greece)                     country_id=84 ;;
        greenland)                  country_id=85 ;;
        guam)                       country_id=88 ;;
        guatemala)                  country_id=89 ;;
        honduras)                   country_id=96 ;;
        "hong kong")                country_id=97 ;;
        hungary)                    country_id=98 ;;
        iceland)                    country_id=99 ;;
        india)                      country_id=100 ;;
        indonesia)                  country_id=101 ;;
        ireland)                    country_id=104 ;;
        "isle of man")              country_id=243 ;;
        israel)                     country_id=105 ;;
        italy)                      country_id=106 ;;
        jamaica)                    country_id=107 ;;
        japan)                      country_id=108 ;;
        jersey)                     country_id=244 ;;
        kazakhstan)                 country_id=110 ;;
        kenya)                      country_id=111 ;;
        laos)                       country_id=118 ;;
        latvia)                     country_id=119 ;;
        lebanon)                    country_id=120 ;;
        liechtenstein)              country_id=124 ;;
        lithuania)                  country_id=125 ;;
        luxembourg)                 country_id=126 ;;
        malaysia)                   country_id=131 ;;
        malta)                      country_id=134 ;;
        mexico)                     country_id=140 ;;
        moldova)                    country_id=142 ;;
        monaco)                     country_id=143 ;;
        mongolia)                   country_id=144 ;;
        montenegro)                 country_id=146 ;;
        morocco)                    country_id=147 ;;
        myanmar)                    country_id=149 ;;
        nepal)                      country_id=152 ;;
        netherlands)                country_id=153 ;;
        "new zealand")              country_id=156 ;;
        nigeria)                    country_id=159 ;;
        "north macedonia")          country_id=128 ;;
        norway)                     country_id=163 ;;
        pakistan)                   country_id=165 ;;
        panama)                     country_id=168 ;;
        "papua new guinea")         country_id=169 ;;
        paraguay)                   country_id=170 ;;
        peru)                       country_id=171 ;;
        philippines)                country_id=172 ;;
        poland)                     country_id=174 ;;
        portugal)                   country_id=175 ;;
        "puerto rico")              country_id=176 ;;
        romania)                    country_id=179 ;;
        serbia)                     country_id=192 ;;
        singapore)                  country_id=195 ;;
        slovakia)                   country_id=196 ;;
        slovenia)                   country_id=197 ;;
        "south afric")              country_id=200 ;;
        "south korea")              country_id=114 ;;
        spain)                      country_id=202 ;;
        "sri lanka")                country_id=203 ;;
        sweden)                     country_id=208 ;;
        switzerland)                country_id=209 ;;
        thailand)                   country_id=214 ;;
        "trinidad and tobago")      country_id=218 ;;
        turkey)                     country_id=220 ;;
        ukraine)                    country_id=225 ;;
        "united arab emirates")     country_id=226 ;;
        "united kingdom")           country_id=227 ;;
        "united states")            country_id=228 ;;
        uruguay)                    country_id=230 ;;
        uzbekistan)                 country_id=231 ;;
        venezuela)                  country_id=233 ;;
        vietnam)                    country_id=234 ;;
        *)
            country_id=''
            print_error 'warning: use the server from the closest location/country'
            ;;
    esac

    server_name="$(curl -gfsSL "https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations&filters={\"country_id\":$country_id}" \
            | jq '.[0].hostname' | tr -d '"')"
    [ -z "$server_name" ] && { print_error "server name not found for $country_name"; return 1; }
    printf '%b' "${server_name}.tcp\n"
}

function connect_nordvpn {
    local cred_file_path="$1"
    local country_name="${2:-United States}"
    local server_name

    disconnect_nordvpn &>/dev/null

    check_command openvpn    || { print_error 'openvpn not found. install it with `brew install openvpn`'; return 1; }
    check_command mkdir      || { print_error 'mkdir not found'; return 1; }
    check_command unzip      || { print_error 'unzip not found. install it with `brew install unzip`'; return 1; }
    check_command rm         || { print_error 'rm not found'; return 1; }
    check_command sleep      || { print_error 'sleep not found'; return 1; }
    [ -f "$cred_file_path" ] || { print_error "cred file not found"; return 1; }

    server_name="$(get_nordvpn_server "$country_name")"

    if ! [ -d /etc/nordvpn_file ]; then
        sudo mkdir -p /etc/nordvpn_file/
        sudo curl -fsSL https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip -o /etc/nordvpn_file/ovpn.zip
        sudo unzip -qq /etc/nordvpn_file/ovpn.zip -d /etc/nordvpn_file/
        sudo rm -rf /etc/nordvpn_file/ovpn.zip /etc/nordvpn_file/ovpn_udp/
    fi

    [ -f /etc/nordvpn_file/ovpn_tcp/${server_name}.ovpn ] || { print_error "/etc/nordvpn_file/ovpn_tcp/${server_name}.ovpn not found"; return 1; }

    # https://nordvpn.com/blog/check-vpn-working/
    # https://support.nordvpn.com/hc/en-us/articles/19587726859793-What-are-the-addresses-of-my-NordVPN-DNS-servers
    sudo openvpn --config "/etc/nordvpn_file/ovpn_tcp/${server_name}.ovpn" --auth-user-pass "$cred_file_path" --daemon &>/dev/null
    [ "$?" = '0' ] \
        && { print_green "connected to $server_name" && sleep 5 && print_green "$(public_ip)"; return 0; } \
        || { print_error "cannot connect to $server_name"; return 1; }
}

function disconnect_nordvpn {
    check_command pkill || { print_error 'pkill not found. install it with `brew install proctools`'; return 1; }
    sudo pkill openvpn &>/dev/null \
        && { print_green 'nordvpn is disconnected'; return 0; } \
        || { print_error 'nordvpn is not disconnected'; return 1; }
}
