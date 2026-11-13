# luci-app-traffic

LuCI 流量统计页：实时速率折线图 + vnStat 历史图表，专为 **PON / OpenWrt 一体机**（如烽火 HG5585F）打造，普通 x86 / 路由器同样可用。

## 功能

- **实时速率折线图**：浏览器端每秒采样 `/sys/class/net` 计数器绘制，鼠标悬停显示读数
- **动态纵轴**：刻度随当前峰值自动调整（1/1.5/2/2.5/3/4/5/6/8/10 × 10^n 档位），左侧留白自适应刻度文字宽度
- **历史图表**：24 小时（5 分钟粒度）/ 按日 / 按月，数据来自 vnStat，自动剔除建库基线假点
- **接口跟随 vnStat**：接口下拉只显示 `/etc/config/vnstat` 中勾选且有计数器的接口，勾选变化每秒自动同步
- **默认接口智能选择**：优先 pon0（MAC/DMA 级计数，不受硬件加速转发影响），避免 pppoe-wan / br-lan 等软件接口在 flow offload 下的计数失真

## 依赖

- OpenWrt 21.02+（ LuCI master，JS 视图）
- `luci-base`
- `vnstat2`（历史数据后端）

## 安装

### 方式一：作为普通 package 编译

```bash
# 克隆到 buildroot 的 package/ 目录
git clone https://github.com/shb110119/luci-app-traffic package/luci-app-traffic
make menuconfig   # 选中 LuCI -> Applications -> luci-app-traffic
make package/luci-app-traffic/compile V=s
```

### 方式二：克隆进 luci feed

```bash
git clone https://github.com/shb110119/luci-app-traffic feeds/luci/applications/luci-app-traffic
```

### 方式三：已有固件上直接装 ipk/apk

```bash
apk add ./luci-app-traffic_1.0.0-1_all.apk    # OpenWrt snapshot (apk)
opkg install ./luci-app-traffic_1.0.0-1_all.ipk  # 21.02/22.03/23.05 (opkg)
```

## 注意事项

1. **vnStat 数据库持久化**：`/var/lib/vnstat` 是 tmpfs，重启即丢。本包自带 `98-vnstat-persist` uci-default 脚本，首次启动把库挪到 `/etc/vnstat` 并写进 sysupgrade 保留列表。
2. **MaxBandwidth**：`vnstat.conf` 默认 `MaxBandwidth 1000`（Mbit），2.5G PON 场景会报 "Traffic rate higher than set maximum" 导致不记账。脚本会自动改成 `2500`。
3. **硬件加速计数失真**：开启 `flow_offloading_hw` 时，pppoe-wan / br-lan 等软件接口只统计未被 PPE 加速的包，看 pon0 才是全量。
4. **改 JS 要换文件名**：LuCI 前端用固定 URL 加载 JS 无版本号，浏览器缓存顽固，改 `overview.js` 内容时建议换名并同步 menu.d。

## 文件结构

```
htdocs/luci-static/resources/view/traffic/overview.js      流量统计页前端
root/usr/share/rpcd/ucode/luci.traffic                      rpcd 后端（ucode）
root/usr/share/rpcd/acl.d/luci-app-traffic.json             ACL
root/usr/share/luci/menu.d/luci-app-traffic.json            菜单（状态 → 网络流量）
root/etc/uci-defaults/98-vnstat-persist                     vnStat 持久化
```

## License

MIT
