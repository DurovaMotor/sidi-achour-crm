# HighTac → Sidi Achour

HighTac 为 Sidi Achour 使用的内部摩托车配件目录、报价与进口额度管理网站。

线上地址：https://sidi-achour-crm.pages.dev/

- 法语入口：https://sidi-achour-crm.pages.dev/
- 中文入口：https://sidi-achour-crm.pages.dev/Adam
- 客户优先出货入口：https://sidi-achour-crm.pages.dev/Sidi

## 架构

- Cloudflare Pages：网页、产品图片和品牌 Logo
- Pages Functions：产品、分类、数量、新价格和备注接口
- D1：637 个产品行、原订单状态、客户优先出货状态及 35 个分类的额度统计
- 固定汇率：`1 USD = 6.67 CNY`
- 千克额度：下单数量 × `产品数据库.xlsx` 中的毛重 ÷ 每箱数量
- 轮胎分类：规格列切换为 `Remarks`，内容来自客户版英文轮胎报价表
- 分类名称：法语严格使用 `Sidi.xlsx` 的 `Licence!D5:D46`，中文逐项对应翻译
- 品牌界面：仅显示 Sidi Achour Logo，并使用约 1 秒的白、红、黑渐变开屏
- 中文页面导出：普通版包含配件图片和编码，脱敏版移除图片和编码；两种版本均可选择中文或法语 Excel

项目不使用 R2。`public/` 是唯一部署目录；`/` 与 `/Adam` 的填写状态保存在 `product_order_state`，`/Sidi` 的优先出货数量与备注独立保存在 `sidi_priority_order_state`。

## 发布

```powershell
.\deploy.ps1
```

每次发布自动生成唯一版本号，按 JS/CSS 内容生成 16 位 SHA-256 指纹文件名，并同步写入页面、`public/version.json`、Cloudflare commit hash/message 和本地 `deployment-history/`。

详细说明见 [DEPLOYMENT.md](DEPLOYMENT.md)。

重量匹配来源和需复核的名称参考项位于 `audit/`；回滚步骤位于 `rollback/`。

## 生产数据库快照

最新生产 D1 完整 SQL 快照位于 `database/sidi-achour-orders-production.sql`，对应的导出时间、SHA-256 和数据行数记录在 `database/snapshot.json`。该目录包含客户订单状态，仅保存在私有 GitHub 仓库中。
