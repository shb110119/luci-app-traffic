#
# Copyright (C) 2026 shb110119
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-traffic
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=Traffic statistics with live chart and vnStat history
LUCI_DESCRIPTION:=LuCI 流量统计页：实时速率折线图（悬停读数、动态纵轴）+ vnStat 历史（24小时/日/月），接口列表跟随 vnStat 勾选自动同步；附带状态首页流量摘要卡片。默认展示 pon0 等 PON 接口，适合光猫/OpenWrt 一体机。
LUCI_DEPENDS:=+luci-base +vnstat2
LUCI_PKGARCH:=all

PKG_LICENSE:=MIT
PKG_MAINTAINER:=shb110119

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
