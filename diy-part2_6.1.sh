# 文件名: diy-part2.sh
# 描述: OpenWrt DIY script part 2 (放在安装feeds之后)
#!/bin/bash

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
    	echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}

# Modify default IP
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# Modify default hostname
sed -i 's/OpenWrt/ImmortalWrt/g' package/base-files/files/bin/config_generate

# Modify default timezone
sed -i 's/UTC/Asia\/Shanghai/g' package/base-files/files/bin/config_generate

# Modify default banner
echo "-----------------------------------------------------" >> package/base-files/files/etc/banner
echo " ImmortalWrt ${Version} by immortalwrt" >> package/base-files/files/etc/banner
echo "-----------------------------------------------------" >> package/base-files/files/etc/banner

# Modify default system release
sed -i "s/DISTRIB_ID='*.*'/DISTRIB_ID='ImmortalWrt'/g" package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ImmortalWrt'/g" package/base-files/files/etc/openwrt_release

# Modify default opkg source
sed -i 's/option check_signature/# option check_signature/g' package/system/opkg/files/opkg.conf
echo "src/gz immortalwrt https://op.supes.top/packages/x86_64" >> package/system/opkg/files/customfeeds.conf

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify default services
sed -i '/exit 0/i\# Start MosDNS' package/base-files/files/etc/rc.local
sed -i '/exit 0/i\mosdns start' package/base-files/files/etc/rc.local
sed -i '/exit 0/i\# Start SmartDNS' package/base-files/files/etc/rc.local
sed -i '/exit 0/i\smartdns start' package/base-files/files/etc/rc.local

# Modify default firewall
sed -i 's/option drop_invalid/option drop_invalid 1/g' package/network/config/firewall/files/firewall.config

# Modify default wireless
sed -i 's/option disabled 1/option disabled 0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Modify default packages
sed -i 's/CONFIG_PACKAGE_luci-app-adbyby-plus=y/CONFIG_PACKAGE_luci-app-adblock=y/g' .config
sed -i 's/CONFIG_PACKAGE_luci-theme-argon-mod=y/CONFIG_PACKAGE_luci-theme-argon=y/g' .config
sed -i 's/CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y/CONFIG_PACKAGE_dnsmasq-full=y/g' .config
sed -i 's/# CONFIG_PACKAGE_odhcpd-ipv6only is not set/CONFIG_PACKAGE_odhcpd-ipv6only=y/g' .config

# Modify default kernel
sed -i 's/CONFIG_KERNEL_BUILD_USER="*.*"/CONFIG_KERNEL_BUILD_USER="immortalwrt"/g' .config
sed -i 's/CONFIG_KERNEL_BUILD_DOMAIN="*.*"/CONFIG_KERNEL_BUILD_DOMAIN="immortalwrt"/g' .config

# Modify default grub
sed -i 's/CONFIG_GRUB_TITLE="*.*"/CONFIG_GRUB_TITLE="ImmortalWrt by immortalwrt"/g' .config

# Modify default rootfs size
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=*.*$/CONFIG_TARGET_ROOTFS_PARTSIZE=600/g' .config

# Modify default feeds
sed -i 's/openwrt\/packages/immortalwrt\/packages/g' feeds.conf.default
sed -i 's/openwrt\/luci/immortalwrt\/luci/g' feeds.conf.default
sed -i 's/openwrt\/routing/immortalwrt\/routing/g' feeds.conf.default
sed -i 's/openwrt\/telephony/immortalwrt\/telephony/g' feeds.conf.default

# Modify default banner file
curl -fsSL https://raw.githubusercontent.com/immortalwrt/diy/master/banner_IMMORTALWRT > package/base-files/files/etc/banner

# Modify default luci-app-zerotier
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-zerotier/root/etc/config/zerotier

# Modify default luci-app-upnp
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-upnp/root/etc/config/upnpd

# Modify default luci-app-wol
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-wol/root/etc/config/wol

# Modify default luci-app-ddns
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-ddns/root/etc/config/ddns

# Modify default luci-app-samba4
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-samba4/root/etc/config/samba4

# Modify default luci-app-turboacc
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc

# Modify default luci-app-mosdns
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-mosdns/root/etc/config/mosdns

# Modify default luci-app-smartdns
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-smartdns/root/etc/config/smartdns

# Modify default luci-app-adblock
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-adblock/root/etc/config/adblock

# Modify default luci-app-firewall
sed -i 's/option enabled 0/option enabled 1/g' package/network/config/firewall/files/firewall.config

# Modify default luci-app-accesscontrol
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-accesscontrol/root/etc/config/accesscontrol

# Modify default luci-app-autotimeset
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-autotimeset/root/etc/config/autotimeset

# Modify default luci-app-chatgpt-web
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-chatgpt-web/root/etc/config/chatgpt-web

# Modify default luci-app-ddnsto
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-ddnsto/root/etc/config/ddnsto

# Modify default luci-app-diskman
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-diskman/root/etc/config/diskman

# Modify default luci-app-dockerman
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-dockerman/root/etc/config/dockerman

# Modify default luci-app-homebox
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-homebox/root/etc/config/homebox

# Modify default luci-app-msd_lite
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-msd_lite/root/etc/config/msd_lite

# Modify default luci-app-multiaccountdial
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-multiaccountdial/root/etc/config/multiaccountdial

# Modify default luci-app-mwan3
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-mwan3/root/etc/config/mwan3

# Modify default luci-app-netdata
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-netdata/root/etc/config/netdata

# Modify default luci-app-nlbwmon
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-nlbwmon/root/etc/config/nlbwmon

# Modify default luci-app-ramfree
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-ramfree/root/etc/config/ramfree

# Modify default luci-app-socat
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-socat/root/etc/config/socat

# Modify default luci-app-ttyd
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-ttyd/root/etc/config/ttyd

# Modify default luci-app-udpxy
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-udpxy/root/etc/config/udpxy

# Modify default luci-app-unblockmusic
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-unblockmusic/root/etc/config/unblockmusic

# Modify default luci-app-unishare
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-unishare/root/etc/config/unishare

# Modify default luci-app-vlmcsd
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-vlmcsd/root/etc/config/vlmcsd

# Modify default luci-app-wireguard
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-wireguard/root/etc/config/wireguard

# Modify default luci-app-zerotier
sed -i 's/option enabled 0/option enabled 1/g' feeds/luci/applications/luci-app-zerotier/root/etc/config/zerotier
