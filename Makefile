#
# Copyright (C) 2026 shb110119
#
# This is free software, licensed under the MIT License.
#
# 说明：本包是纯 LuCI 资源包（JS + rpcd ucode + 配置），不含任何需要编译的
# C 代码，因此这里刻意不使用 feeds/luci/luci.mk —— 那会引入 luci-base 的
# host 构建（lemon/lua），在 GCC 14+ 的新发行版上容易编译失败，对纯资源包
# 完全是多余开销。改用 rules.mk + package.mk，只做文件安装，产物仍是
# Architecture: all，任何 CPU 都能装。
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-traffic
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=shb110119

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-traffic
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Traffic statistics with live chart and vnStat history
  DEPENDS:=+luci-base +vnstat2
  PKGARCH:=all
  URL:=https://github.com/shb110119/luci-app-traffic
endef

define Package/luci-app-traffic/description
 LuCI 流量统计页：实时速率折线图（悬停读数、动态纵轴）+ vnStat 历史
（24小时/日/月），接口列表跟随 vnStat 勾选自动同步。默认展示 pon0 等
PON 接口，适合光猫/OpenWrt 一体机。界面风格仿老毛子（Padavan）流量统计。
endef

# 纯资源包，无可编译内容
define Build/Compile
endef

define Package/luci-app-traffic/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/traffic
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/traffic/overview.js \
		$(1)/www/luci-static/resources/view/traffic/overview.js

	$(INSTALL_DIR) $(1)/usr/share/rpcd/ucode
	$(INSTALL_BIN) ./root/usr/share/rpcd/ucode/luci.traffic \
		$(1)/usr/share/rpcd/ucode/luci.traffic

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-traffic.json \
		$(1)/usr/share/rpcd/acl.d/luci-app-traffic.json

	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./root/usr/share/luci/menu.d/luci-app-traffic.json \
		$(1)/usr/share/luci/menu.d/luci-app-traffic.json

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/98-vnstat-persist \
		$(1)/etc/uci-defaults/98-vnstat-persist
endef

$(eval $(call BuildPackage,luci-app-traffic))
