cite about-alias
about-alias 'stuff con-f-use uses every blue moon'

alias conservessh="ssh -o 'UserKnownHostsFile=~/.ssh/known_hosts.initramfs' -i '/home/confus/.ssh/id_rsa.conserve.dropbear' root@192.168.0.11"

# Create a data URL from a file
function dataurl() {
    local mimeType=$(file -b --mime-type "$1");
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8";
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

alias limitcpuscal='for i in {0..3}; do echo 2100000 | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq; echo conservative | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done'

alias gitpublishprojpage="git subtree push origin gh-pages --prefix "
alias submitpotruns='for i in {0..102}; do i=$(printf "%03i" $i); qsub s$i.start; done'
alias writepotruns='for i in {1..102}; do i=$(printf "%03i\n" $i); ./newrun.sh s000 s$i; done'
alias clusterdot="
    scp .bashcustom ~/.bash_logout ~/.gnuplot ~/.inputrc ~/.vimrc ~/sync/config/pycustom leo3e:;
    scp ~/.bashcustom ~/.bash_logout ~/.gnuplot ~/.inputrc ~/.vimrc ~/sync/config/pycustom leo3:;
    scp ~/sync/config/ssh_config leo3e:.ssh/config;
    scp ~/sync/config/ssh_config leo3e:.ssh/config
"

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}";
    sleep 1 && open "http://localhost:${port}/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
    local port="${1:-4000}";
    local ip=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}');
    sleep 1 && open "http://${ip}:${port}/" &
    php -S "${ip}:${port}";
}

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i eth0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
# scan your local network with nmap
#
# usage:
#  snet <nmap-args>
# example: (scan for every HP printer in the network)
#  snet -p jetdirect --open
#
# - get all non-linklocal IP addrs from ip
# - pipe the IPs through ipcalc to get the network ID
#   - this is neccessary to prevent scanning the same network twice
#   - likely to experience if connected via wifi and ethernet
# - xargs it to nmap at the end
alias snet="ip addr | \\grep -v "inet6" | \\grep inet | cut -d \" \" -f 6 | \\grep -v '127\\.0\\.[0-1]\\.[0-1]' | xargs -n 1 ipcalc | awk '/Network:/{print \$2}' | sort -u | xargs nmap"

# Get a character’s Unicode code point
function codepoint() {
    perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))";
    # print a newline unless we’re piping the output to another program
    if [ -t 1 ]; then
        echo ""; # newline
    fi;
}
