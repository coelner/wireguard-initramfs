#!/usr/bin/env bash
#
# Migrate 2023-10-21 installs to current format.

if [ "$(id -u)" -ne 0 ]
  then echo "Please run as root"
  exit
fi

target_dir=${DESTDIR}/etc/wireguard-initramfs
docs_dir=${DESTDIR}/usr/local/share/docs/wireguard-initramfs

config_dir="../configs"

mkdir -p "${config_dir}"
source "${target_dir}/config"

tmp_INTERFACE_ADDR_IPV4=$(echo "${INTERFACE_ADDR}" | cut -d/ -f 1)
tmp_INTERFACE_ADDR_IPV4_SUFFIX=$(echo "${INTERFACE_ADDR}" | cut -d/ -f 2)
tmo_PEER_URL=$(echo "${PEER_ENDPOINT}" | cut -d: -f 1)

cat >"${config_dir}/initramfs" <<EOL
# Wireguard initramfs configuration.
#
# NOTE: As most systems do not encrypt /boot, private key material is exposed
#       and compromised/untrusted. Boot wireguard network should be
#       **different** & untrusted; versus the network used after booting.
#       Always restrict ports and access on the wireguard server.
#
# Be sure to test wireguard config with a running system before setting
# options.
#
# Restricting dropbear connections to **only** wireguard:
# * Confirm wireguard/dropbear work without restriction first.
# * Set dropbear listen address to only wireguard interface (INTERFACE_ADDR_*)
#   address:
#
#   /etc/dropbear-initramfs/config
#     DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
#
# Reference:
# * https://manpages.debian.org/unstable/wireguard-tools/wg-quick.8.en.html

###############################################################################
# InitRAMFS Configuration
###############################################################################

# Absolute path to wireguard adapter config for initramfs. This is copied to
# initramfs and loaded after the hardware device is initialized.
ADAPTER=/etc/wireguard/initramfs.conf

# URL to send a web request to set the local datetime.
#
# Raspberry Pi's should enable this feature for wireguard-initramfs to work.
#
# Skipped if blank.
DATETIME_URL=google.com

# Persist wireguard interface after initramfs exits? Any value enables.
PERSISTENT=

###############################################################################
# Adapter Configuration
###############################################################################
# During init the wireguard adapter must be initialized manually. Set values
# from ADAPTER here; extracting the minimum information needed to stand-up the
# adapter and load the rest of the wireguard configuration. These values must
# match the values found in ADAPTER.
#
# Highly recommended to set PersistentKeepalives in ADAPTER to ensure
# connections for non-exposed ports.

# Wireguard interface name. Required.
INTERFACE=${INTERFACE}

# CIDR wireguard IPv4 interface address. Required IPv4, IPv6, or both.
INTERFACE_ADDR_IPV4=${INTERFACE_ADDR}

# CIDR wireguard IPv6 interface address. Required IPv4, IPv6, or both.
INTERFACE_ADDR_IPV6=

# Custom wireguard interface MTU. Default: empty (wireguard default). Optional.
INTERFACE_MTU=

# Allowed IPs from peers.
#
# A comma-separated list of IP addresses with CIDR masks from which incoming
# traffic for this peer is allowed and to which outgoing traffic for this peer
# is directed. All traffic is blocked by default.
#
# * '0.0.0.0/0' match all IPv4 addresses.
# * '::/0' match all IPv6 addresses.
#
# Required.
PEER_ALLOWED_IPS_IPV4=172.31.255.254/32
PEER_ALLOWED_IPS_IPV6=
EOL

rm "${docs_dir}/examples/config"
rm "${target_dir}/private_key"
rm "${target_dir}/pre_shared_key"
rm "${target_dir}/config"
