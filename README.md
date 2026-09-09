# HighTac → Sidi Achour

HighTac 为 Sidi Achour 使用的内部摩托车配件目录、报价与进口额度管理网站。

线上地址：https://sidi-achour-crm.pages.dev/

## 架构

- Cloudflare Pages：网页、产品图片和品牌 Logo
- Pages Functions：产品、分类、数量、新价格和备注接口
- D1：613 个产品行的订单状态及 35 个分类的额度统计
- 固定汇率：`1 USD = 6.67 CNY`
- 千克额度：下单数量 × `产品数据库.xlsx` 中的毛重 ÷ 每箱数量
- 轮胎分类：规格列切换为 `Remarks`，内容来自客户版英文轮胎报价表

项目不使用 R2。`public/` 是唯一部署目录；右侧可编辑状态按 `record_id` 保存。

## 发布

```powershell
.\deploy.ps1
```

每次发布自动生成唯一版本号，按 JS/CSS 内容生成 16 位 SHA-256 指纹文件名，并同步写入页面、`public/version.json`、Cloudflare commit hash/message 和本地 `deployment-history/`。

详细说明见 [DEPLOYMENT.md](DEPLOYMENT.md)。

重量匹配来源和需复核的名称参考项位于 `audit/`；回滚步骤位于 `rollback/`。
