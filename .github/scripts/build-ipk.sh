#!/bin/sh
# 生成 luci-app-traffic 的 .ipk 包（OpenWrt 23.05 / opkg 使用）
#
# 本包是纯 LuCI 资源包（JS + JSON + ucode/shell 脚本），没有任何需要编译的内容，
# 因此不依赖 OpenWrt SDK：直接按 ipk 格式（ar + control.tar.gz + data.tar.gz）
# 手工打包即可。产物 Architecture: all，任意 CPU 通用。
#
# 用法：在仓库根目录执行 sh .github/scripts/build-ipk.sh
set -eu

VER=$(sed -n 's/^PKG_VERSION:=//p' Makefile | head -1)
REL=$(sed -n 's/^PKG_RELEASE:=//p' Makefile | head -1)
VER=${VER:-1.0.0}
REL=${REL:-1}

# 源文件 -> 目标路径:权限
FILES="
htdocs/luci-static/resources/view/traffic/overview.js|www/luci-static/resources/view/traffic/overview.js|644
root/usr/share/rpcd/ucode/luci.traffic|usr/share/rpcd/ucode/luci.traffic|755
root/usr/share/rpcd/acl.d/luci-app-traffic.json|usr/share/rpcd/acl.d/luci-app-traffic.json|644
root/usr/share/luci/menu.d/luci-app-traffic.json|usr/share/luci/menu.d/luci-app-traffic.json|644
root/etc/uci-defaults/98-vnstat-persist|etc/uci-defaults/98-vnstat-persist|755
"

WORK=$(mktemp -d)
STAGE="$WORK/data"
CTRL="$WORK/control"
mkdir -p "$STAGE" "$CTRL" out

printf '%s\n' "$FILES" | while IFS='|' read -r src dst mode; do
	[ -n "$src" ] || continue
	[ -f "$src" ] || { echo "缺少源文件: $src" >&2; exit 1; }
	mkdir -p "$STAGE/$(dirname "$dst")"
	cp "$src" "$STAGE/$dst"
	chmod "$mode" "$STAGE/$dst"
	echo "  + $dst ($mode)"
done

SIZE=$(du -sk "$STAGE" | cut -f1)
STAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat > "$CTRL/control" <<EOF
Package: luci-app-traffic
Version: ${VER}-${REL}
Depends: luci-base, vnstat2
Provides:
Source: package/luci-app-traffic
SourceName: luci-app-traffic
License: MIT
LicenseFiles: LICENSE
Section: luci
SourceDateEpoch: $(date +%s)
Maintainer: shb110119
Architecture: all
Installed-Size: ${SIZE}
URL: https://github.com/shb110119/luci-app-traffic
Description: LuCI 流量统计：实时速率折线图（悬停读数/动态纵轴）+ vnStat 历史，
 接口跟随 vnStat 勾选自动同步，界面仿老毛子(Padavan)风格。
EOF

# control.tar.gz：内容以 ./ 开头
tar --force-local -czf "$WORK/control.tar.gz" -C "$CTRL" --owner=0 --group=0 --numeric-owner .
# data.tar.gz：同上
tar --force-local -czf "$WORK/data.tar.gz" -C "$STAGE" --owner=0 --group=0 --numeric-owner .
# debian-binary 版本号
printf '2.0\n' > "$WORK/debian-binary"

OUT="$(pwd)/out/luci-app-traffic_${VER}-${REL}_all.ipk"
rm -f "$OUT"
(cd "$WORK" && ar rc "$OUT" debian-binary control.tar.gz data.tar.gz)

echo
echo "生成完毕: $OUT"
ls -la "$OUT"
echo "--- 校验 ---"
ar t "$OUT"
tar --force-local -tzf "$WORK/data.tar.gz" | sed 's/^/  data: /'
echo "--- control ---"
cat "$CTRL/control"
echo "构建时间: $STAMP"
