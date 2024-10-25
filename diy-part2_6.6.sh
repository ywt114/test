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

# 修改管理地址
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 交换LAN/WAN口
sed -i 's/"eth1 eth2" "eth0"/"eth1 eth2" "eth0"/g' target/linux/x86/base-files/etc/board.d/02_network
sed -i "s/'eth1 eth2' 'eth0'/'eth1 eth2' 'eth0'/g" target/linux/x86/base-files/etc/board.d/02_network
sed -i "s/lan 'eth0'/lan 'eth0'/g" package/base-files/files/etc/board.d/99-default_network
sed -i "s/wan 'eth1'/wan 'eth1'/g" package/base-files/files/etc/board.d/99-default_network
sed -i "s/net\/eth1/net\/eth1/g" package/base-files/files/etc/board.d/99-default_network

# 修改默认皮肤
sed -i 's/luci-theme-bootstrap/luci-theme-argon-mod/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon-mod/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon-mod/g' feeds/luci/collections/luci-ssl-nginx/Makefile

# 修改主机名以及一些显示信息
sed -i "s/hostname='*.*'/hostname='test'/" package/base-files/files/bin/config_generate
sed -i "s/DISTRIB_ID='*.*'/DISTRIB_ID='OpenWrt'/g" package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='OpenWrt'/g"  package/base-files/files/etc/openwrt_release
sed -i '/(<%=pcdata(ver.luciversion)%>)/a\      built by test' package/lean/autocore/files/x86/index.htm
echo -n "$(date +'%Y%m%d')" > package/base-files/files/etc/openwrt_version
curl -fsSL https://raw.githubusercontent.com/ywt114/diy/main/banner_test > package/base-files/files/etc/banner

# 修改部分默认设置
sed -i "/exit 0/i sed -i '\/oui\/d' \/etc\/opkg\/distfeeds.conf" package/lean/default-settings/files/zzz-default-settings
sed -i "s/option check_signature/# option check_signature/g" package/system/opkg/Makefile
# echo "src/gz openwrt_kiddin9 https://op.supes.top/packages/x86_64" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_kenzok8 https://op.dllkids.xyz/packages/x86_64" >> package/system/opkg/files/customfeeds.conf
sed -i "s/mirrors.cloud.tencent.com\/lede/mirrors.cloud.tencent.com\/openwrt/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/sed -i 's\/root::0:0:99999:7:::/# sed -i 's\/root::0:0:99999:7:::/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/sed -i 's\/root:::0:99999:7:::/# sed -i 's\/root:::0:99999:7:::/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/sed -i '\/REDIRECT --to-ports/# sed -i '\/REDIRECT --to-ports/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/echo 'iptables -t/echo '# iptables -t/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/echo '\[ -n/echo '# \[ -n/g" package/lean/default-settings/files/zzz-default-settings

# 开启wifi选项
sed -i 's/disabled=*.*/disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/ssid=*.*/ssid=test/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 添加关机按钮到系统选项
curl -fsSL https://raw.githubusercontent.com/ywt114/diy/main/poweroff.htm > feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm
curl -fsSL https://raw.githubusercontent.com/ywt114/diy/main/system.lua > feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

# 删除替换默认源插件和添加插件
# find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
# find ./ | grep Makefile | grep pdnsd-alt | xargs rm -f
# \rm -rf feeds/packages/net/v2ray-geodata feeds/packages/net/pdnsd-alt
\rm -rf feeds/packages/net/{v2ray-geodata,pdnsd-alt}
\rm -rf feeds/packages/lang/golang
git clone -b 23.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
# rm -rf feeds/packages/net/curl
# git clone -b main https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl
git clone -b lua https://github.com/sbwml/luci-app-alist package/lean/alist
\rm -rf feeds/packages/net/mosdns feeds/luci/applications/luci-app-mosdns feeds/packages/utils/v2dat
git clone -b v5-lua https://github.com/sbwml/luci-app-mosdns package/lean/mosdns
\rm -rf feeds/luci/applications/luci-app-adbyby-plus
git clone -b main https://github.com/ywt114/luci-app-adbyby-plus-lite package/lean/luci-app-adbyby-plus-lite
\rm -rf feeds/packages/net/msd_lite
git clone -b main https://github.com/ywt114/luci-app-msd_lite package/lean/msd_lite
git clone -b master https://github.com/ywt114/luci-app-gpsysupgrade package/lean/luci-app-gpsysupgrade
\rm -rf feeds/packages/net/smartdns feeds/luci/applications/luci-app-smartdns
git clone -b master https://github.com/pymumu/openwrt-smartdns package/lean/smartdns
git clone -b lede https://github.com/pymumu/luci-app-smartdns package/lean/luci-app-smartdns
git clone -b master https://github.com/kenzok8/small package/lean/small
# \rm -rf package/lean/small/luci-app-bypass package/lean/small/luci-app-homeproxy package/lean/small/luci-app-mihomo package/lean/small/luci-app-mosdns package/lean/small/luci-app-passwall2
\rm -rf package/lean/small/{*bypass*,*homeproxy*,*mihomo*,*mosdns*,*passwall2*}
git clone -b main https://github.com/sirpdboy/luci-app-chatgpt-web package/lean/luci-app-chatgpt-web
git clone -b master https://github.com/sirpdboy/luci-app-advanced package/lean/luci-app-advanced
git clone -b master https://github.com/sirpdboy/luci-app-autotimeset package/lean/luci-app-autotimeset
sed -i 's/control"/system"/g' package/lean/luci-app-autotimeset/luasrc/controller/autotimeset.lua
sed -i 's/control]/system]/g' package/lean/luci-app-autotimeset/luasrc/view/autotimeset/log.htm
# merge_package master https://github.com/kenzok8/openwrt-packages package/lean/small luci-app-openclash
\rm -rf feeds/packages/net/socat feeds/luci/applications/luci-app-socat
merge_package master https://github.com/xiangfeidexiaohuo/extra-ipk package/lean/socat op-socat
merge_package master https://github.com/xiangfeidexiaohuo/extra-ipk package/lean/homebox op-homebox
\rm -rf feeds/packages/net/adguardhome feeds/luci/applications/luci-app-adguardhome
merge_package main https://github.com/sirpdboy/sirpdboy-package package/lean adguardhome luci-app-adguardhome
merge_package main https://github.com/linkease/openwrt-app-actions package/lean applications/luci-app-multiaccountdial
merge_package main https://github.com/linkease/istore package/lean translations luci/luci-app-store luci/luci-lib-taskd luci/luci-lib-xterm luci/taskd
# sed -i 's/+luci-lib-ipkg/+luci-base/g' package/lean/luci-app-store/Makefile
merge_package main https://github.com/linkease/nas-packages-luci package/lean luci/luci-app-ddnsto luci/luci-app-istorex luci/luci-app-linkease luci/luci-app-quickstart luci/luci-app-unishare luci/luci-lib-iform luci/luci-nginxer
sed -i 's/istorex_template")).leaf/istorex_template"), _("iStoreX"), 3).leaf/g' package/lean/luci-app-istorex/luasrc/controller/istorex.lua
merge_package master https://github.com/linkease/nas-packages package multimedia
merge_package master https://github.com/linkease/nas-packages package/network/services network/services/ddnsto network/services/linkease network/services/linkmount network/services/quickstart network/services/unishare network/services/webdav2
merge_package main https://github.com/Carseason/openwrt-packages package/lean luci/luci-app-istorego luci/luci-app-routerdog
merge_package main https://github.com/Carseason/openwrt-packages package/network/services network/services/routergo

# 创建automake-1.15软连接
# sudo -E ln -sf /usr/bin/automake /usr/bin/automake-1.15

# 取消部分config配置
sed -i 's/iperf3-ssl[[:space:]]*//g' target/linux/x86/Makefile
# sed -i '/CONFIG_PACKAGE_kmod-usb-audio/d' ./.config
# echo "# CONFIG_PACKAGE_kmod-usb-audio is not set" >> ./.config
# echo "# CONFIG_PACKAGE_kmod-media-core is not set" >> ./.config

# 修改vermagic版本号
# curl -fsSL https://raw.githubusercontent.com/ywt114/diy/main/vermagic-6.6 > vermagic
# sed -i 's/grep '\''=\[ym\]'\'' $(LINUX_DIR)\/.config.set | LC_ALL=C sort | $(MKHASH) md5 >/cp $(TOPDIR)\/vermagic/g' include/kernel-defaults.mk
# sed -i 's/$(SCRIPT_DIR)\/kconfig.pl $(LINUX_DIR)\/.config | $(MKHASH) md5/cat $(LINUX_DIR)\/.vermagic/g' package/kernel/linux/Makefile

sed -i 's/Variable1 = "*.*"/Variable1 = "ywt114"/g' package/lean/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable2 = "*.*"/Variable2 = "test"/g' package/lean/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable3 = "*.*"/Variable3 = "x86_64"/g' package/lean/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable4 = "*.*"/Variable4 = "6.6"/g' package/lean/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable1 = "*.*"/Variable1 = "ywt114"/g' package/lean/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable2 = "*.*"/Variable2 = "test"/g' package/lean/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable3 = "*.*"/Variable3 = "x86_64"/g' package/lean/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable4 = "*.*"/Variable4 = "6.6"/g' package/lean/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua

# 回退passwall到2024年1月9日旧版本
cd package/lean/small/luci-app-passwall
git reset --hard ecd92aa64174f5e7a200678b4122891764a6b245
cd ../../../..
\cp -rf package/lean/mosdns/v2dat package/lean/small
sed -i 's/CGO_ENABLED=0/CGO_ENABLED=1/g' package/lean/small/sing-box/Makefile
