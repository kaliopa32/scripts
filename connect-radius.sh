#!/bin/bash

# === Early Requirements ===
if ! command -v nmcli &> /dev/null; then
    echo "❌ Error: 'nmcli' is required but not installed."
    exit 1
fi

RG_CMD="grep"
if command -v rg &> /dev/null; then
    RG_CMD="rg"
fi

trap "echo -e '\nAborted.'; exit 130" INT
echo -e "\n\e[1m[ Kali's WPA2-Enterprise Wi-Fi Tool ]\e[0m"

# === Scan SSIDs ===
SSID_LIST=($(nmcli --terse --fields SSID dev wifi | sort -u | $RG_CMD -v '^$'))
if [ ${#SSID_LIST[@]} -eq 0 ]; then
    echo "No Wi-Fi networks found."
    exit 1
fi

for i in "${!SSID_LIST[@]}"; do
    printf "%2d: %s\n" "$((i+1))" "${SSID_LIST[i]}"
done

# === Prompt for SSID ===
echo -e "\nEnter SSID name or select by number with ! +/or modifier * to save credentials, @ to load credential(e.g. 2! 2!* 2!@):"
read -rp "SSID: " SSID_INPUT

SAVE_CREDS=0
AUTOLOAD_CREDS=0

# === Parse SSID selection + flags ===
if [[ "$SSID_INPUT" =~ ^([0-9]+)!(\*|@)?$ ]]; then
    INDEX="${BASH_REMATCH[1]}"
    case "${BASH_REMATCH[2]}" in
        "*") SAVE_CREDS=1 ;;
        "@") AUTOLOAD_CREDS=1 ;;
    esac
    INDEX=$((INDEX - 1))
    if [ "$INDEX" -ge 0 ] && [ "$INDEX" -lt "${#SSID_LIST[@]}" ]; then
        SSID="${SSID_LIST[$INDEX]}"
        echo "Selected SSID: $SSID"
    else
        echo "Invalid index."
        exit 1
    fi
elif [[ "$SSID_INPUT" =~ ^(.+?)(\*|@)?$ ]]; then
    SSID="${BASH_REMATCH[1]}"
    case "${BASH_REMATCH[2]}" in
        "*") SAVE_CREDS=1 ;;
        "@") AUTOLOAD_CREDS=1 ;;
    esac
else
    echo "Invalid SSID input."
    exit 1
fi

# === Credential Storage ===
CRED_FILE="$HOME/.config/wifi-creds/$SSID"
mkdir -p "$(dirname "$CRED_FILE")"

# === Load Credentials If File Exists ===
if [ -f "$CRED_FILE" ]; then
    if [ "$AUTOLOAD_CREDS" -eq 1 ]; then
        echo "🔐 Autoloading saved credentials for $SSID."
        source "$CRED_FILE"
    else
        echo -ne "\n🔐 Found saved credentials for \"$SSID\". Load them? [y/N]: "
        read -r USE_STORED
        if [[ "$USE_STORED" =~ ^[Yy]$ ]]; then
            source "$CRED_FILE"
            echo "✅ Loaded stored credentials."
        fi
    fi
fi

# === Prompt if not already loaded ===
if [[ -z "$IDENTITY" || -z "$PASSWORD" ]]; then
    read -rp "Login identity (e.g., user@school.edu): " IDENTITY
    read -rsp "Password: " PASSWORD
    echo
fi

# === Save Credentials ===
if [ "$SAVE_CREDS" -eq 1 ]; then
    echo "💾 Saving credentials to $CRED_FILE"
    {
        echo "IDENTITY=\"$IDENTITY\""
        echo "PASSWORD=\"$PASSWORD\""
    } > "$CRED_FILE"
    chmod 600 "$CRED_FILE"
fi

# === Disable all user input ===
exec </dev/null

# === Clean and Connect ===
CA_CERT="/etc/ssl/certs/ca-certificates.crt"

if nmcli -t -f NAME connection show | grep -Fxq "$SSID"; then
    echo -e "\n🧹 Removing existing connection for $SSID..."
    nmcli connection delete "$SSID" &>/dev/null
fi

echo -e "\n🔌 Connecting to \e[1m$SSID\e[0m as \e[1m$IDENTITY\e[0m..."
nmcli connection add type wifi con-name "$SSID" ifname "*" ssid "$SSID" \
    wifi-sec.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.phase2-auth mschapv2 \
    802-1x.identity "$IDENTITY" \
    802-1x.password "$PASSWORD" \
    802-1x.ca-cert "$CA_CERT" &>/dev/null

nmcli connection up "$SSID" < /dev/null &>/dev/null

if nmcli -t -f NAME connection show --active | grep -Fxq "$SSID"; then
    echo -e "\n✅ \e[1mConnected to $SSID.\e[0m"
    exit 0
else
    echo -e "\n❌ \e[1mFailed to connect to $SSID.\e[0m"
    exit 2
fi

















































































































































































