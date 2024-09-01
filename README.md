# Command Line Interface for NordVPN on MacOS

NordVPN does not officially provide a CLI on MacOS. Thus, I wrote this script.

It requires the installation of `jq` and `openvpn`. You can install them by `brew install jq` and `brew install openvpn`.

## Getting Started
```shell
# replace `your-username` and `your-password` from https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/
cat > "$HOME/.nordvpn_cred" <<'EOF'
your-username
your-password
EOF

git clone --depth 1 https://github.com/maxleungtszchun/NordVPN-MacCLI.git
# you must use zsh (the default shell on MacOS) for sourcing this script
source ./NordVPN-MacCLI/nordvpn.sh

# the script automatically selects the best server of the country specified
# openvpn needs sudo
connect_nordvpn "$HOME/.nordvpn_cred" 'United States'

# disconnect nordvpn
# pkill needs sudo
disconnect_nordvpn
```