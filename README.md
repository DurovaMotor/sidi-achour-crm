# HighTac → Sidi Achour

HighTac 为 Sidi Achour 使用的内部摩托车配件目录、报价与进口额度管理网站。

线上地址：https://sidi-achour-crm.pages.dev/

- 法语入口：https://sidi-achour-crm.pages.dev/
- 中文入口：https://sidi-achour-crm.pages.dev/Adam
- 客户优先出货入口：https://sidi-achour-crm.pages.dev/Sidi

## 架构

- Cloudflare Pages：网页、加密的产品图片密文和品牌 Logo
- Pages Functions：产品、分类、数量、新价格、备注及产品预览图解密接口
- D1：637 个产品行、原订单状态、客户优先出货状态及 35 个分类的额度统计
- 固定汇率：`1 USD = 6.67 CNY`
- 千克额度：下单数量 × `产品数据库.xlsx` 中的毛重 ÷ 每箱数量
- 轮胎分类：规格列切换为 `Remarks`，内容来自客户版英文轮胎报价表
- 分类名称：法语严格使用 `Sidi.xlsx` 的 `Licence!D5:D46`，中文逐项对应翻译
- 品牌界面：仅显示 Sidi Achour Logo，并使用约 1 秒的白、红、黑渐变开屏
- 中文页面导出：普通版包含配件图片和编码，脱敏版移除图片和编码；两种版本均可选择中文或法语 Excel

项目不使用 R2。`public/` 是唯一部署目录；`/` 与 `/Adam` 的填写状态保存在 `product_order_state`，`/Sidi` 的优先出货数量与备注独立保存在 `sidi_priority_order_state`。

产品原图不进入 Pages 明文目录。客户预览图最长边约640px并带重复水印；原图和预览图均使用AES-256-GCM加密为 `.bin`，Pages Secret `CATALOG_MEDIA_AES_KEY` 仅在运行时解密预览图。密钥不写入源码、D1或GitHub。

## 发布

```powershell
.\deploy.ps1
```

首次启用或轮换产品图片密钥时，运行 `scripts/rotate_catalog_media_key.ps1`。脚本在内存中生成密钥、重新加密全部产品图片并写入Pages Secret；本地明文原图保存在Git忽略的 `private/catalog-originals/`，不会部署。

每次发布自动生成唯一版本号与随机资源 ID 文件名，并同步写入页面、`public/version.json`、Cloudflare 发布引用/消息和本地 `deployment-history/`；发布过程不对本地源码、资源或构建产物做哈希校验。

详细说明见 [DEPLOYMENT.md](DEPLOYMENT.md)。

重量匹配来源和需复核的名称参考项位于 `audit/`；回滚步骤位于 `rollback/`。

## 生产数据库快照

最新生产 D1 完整 SQL 快照位于 `database/sidi-achour-orders-production.sql`，对应的导出时间、SHA-256 和数据行数记录在 `database/snapshot.json`。该目录包含客户订单状态，仅保存在私有 GitHub 仓库中。
