const copy = {
  zh: {
    skip: "跳到内容", brandFlow: "Sidi Achour", businessPages: "业务页面", languageLabel: "语言",
    catalogNav: "产品目录", licenceNav: "进口申报", categories: "产品分类", allProducts: "全部产品",
    searchLabel: "搜索产品", searchPlaceholder: "搜索产品编码、名称或规格", sortLabel: "排序",
    sortSource: "原表顺序", sortPriceAsc: "价格从低到高", sortPriceDesc: "价格从高到低", sortCode: "产品编码 A–Z",
    image: "图片", productCode: "产品编码", productName: "产品名称", specModel: "规格 / 适配车型", remarksHeader: "Remarks", price: "单价",
    newPrice: "新价格", quantity: "数量", remark: "备注", productTableLabel: "产品列表", noResults: "没有匹配的产品", quote: "询价",
    quantityScore: "数量", amountScore: "金额", previous: "上一页", next: "下一页", goToPage: "跳至页", go: "跳转",
    paginationLabel: "分页", licenceTitle: "进口申报", licenceSearchLabel: "搜索进口申报",
    licenceSearchPlaceholder: "搜索 HS 编码或产品名称", number: "序号", hsCode: "HS 编码", designation: "商品名称",
    brand: "品牌 / 关键词", origin: "原产国", supplierCountry: "供应国", quotaQuantity: "进口额度数量",
    unitPrice: "申报单价", value: "申报价值", offers: "报价", viewOffers: "查看",
  },
  fr: {
    skip: "Aller au contenu", brandFlow: "Sidi Achour", businessPages: "Pages métier", languageLabel: "Langue",
    catalogNav: "Catalogue", licenceNav: "Déclaration", categories: "Catégories", allProducts: "Tous les produits",
    searchLabel: "Rechercher un produit", searchPlaceholder: "Rechercher un nom ou une spécification", sortLabel: "Trier",
    sortSource: "Ordre du classeur", sortPriceAsc: "Prix croissant", sortPriceDesc: "Prix décroissant", sortCode: "Code produit A–Z",
    image: "Image", productCode: "Code produit", productName: "Désignation", specModel: "Spécification / modèles", remarksHeader: "Remarks", price: "Prix",
    newPrice: "Nouveau prix", quantity: "Quantité", remark: "Remarque", productTableLabel: "Liste des produits", noResults: "Aucun produit correspondant", quote: "Sur demande",
    quantityScore: "Qté", amountScore: "Montant", previous: "Précédent", next: "Suivant", goToPage: "Aller à la page", go: "Aller",
    paginationLabel: "Pagination", licenceTitle: "Déclaration d'importation", licenceSearchLabel: "Rechercher dans la déclaration",
    licenceSearchPlaceholder: "Rechercher un code SH ou une désignation", number: "N°", hsCode: "Code SH", designation: "Désignation",
    brand: "Marque / mot-clé", origin: "Origine", supplierCountry: "Pays fournisseur", quotaQuantity: "Quota d’importation",
    unitPrice: "Prix déclaré", value: "Valeur déclarée", offers: "Offres", viewOffers: "Voir",
  },
};

const exportCopy = {
  zh: {
    sheet: "订单",
    title: "Sidi Achour 摩托车配件订单",
    redactedTitle: "Sidi Achour 摩托车配件订单",
    exportedAt: "导出时间",
    currencyNote: "币种：CNY；单价优先使用新价格",
    total: "订单总金额（CNY）",
    file: "订单",
    redactedFile: "客户订单",
    headers: {
      number: "序号", image: "图片", code: "配件编码", name: "中文名称", category: "产品分类",
      specification: "规格 / Remarks", unit: "单位", price: "单价（CNY）", quantity: "数量", amount: "金额（CNY）", remark: "备注",
    },
  },
  fr: {
    sheet: "Commande",
    title: "Commande de pièces pour motocycles — Sidi Achour",
    redactedTitle: "Commande de pièces pour motocycles — Sidi Achour",
    exportedAt: "Date d’exportation",
    currencyNote: "Devise : CNY. Le nouveau prix est utilisé en priorité.",
    total: "Montant total de la commande (CNY)",
    file: "Commande_FR",
    redactedFile: "Commande_Client_FR",
    headers: {
      number: "N°", image: "Image", code: "Code produit", name: "Désignation", category: "Catégorie",
      specification: "Spécification / Remarks", unit: "Unité", price: "Prix (CNY)", quantity: "Quantité", amount: "Montant (CNY)", remark: "Remarque",
    },
  },
};

const pagePath = window.location.pathname.replace(/\/+$/u, "") || "/";
const effectivePagePath = pagePath === "/Sidi/Key" || pagePath === "/Sidi/Key.html"
  ? "/Sidi"
  : pagePath === "/Key" || pagePath === "/Key.html"
    ? "/"
    : pagePath;

const state = {
  isAdam: effectivePagePath === "/Adam",
  language: effectivePagePath === "/Adam" ? "zh" : "fr",
  workspace: effectivePagePath === "/Sidi" ? "sidi" : effectivePagePath === "/Adam" ? "adam" : "default",
  activeTab: "catalog",
  category: "all",
  query: "",
  sort: "source",
  page: 1,
  pageSize: 50,
  total: 0,
  totalPages: 1,
  categories: [],
  products: [],
  licence: null,
  saveTimers: new Map(),
  dirtyProducts: new Map(),
  saveRequests: new Map(),
  editRevisions: new Map(),
  searchTimer: null,
};

const release = {
  current: document.querySelector('meta[name="app-version"]').content,
  available: null,
  checking: false,
  applying: false,
  interval: null,
};

const elements = {
  splashScreen: document.querySelector("#splashScreen"),
  adminActions: document.querySelector("#adminActions"),
  exportOrdersButton: document.querySelector("#exportOrdersButton"),
  exportRedactedButton: document.querySelector("#exportRedactedButton"),
  exportOrdersMenu: document.querySelector("#exportOrdersMenu"),
  exportRedactedMenu: document.querySelector("#exportRedactedMenu"),
  accessControlButton: document.querySelector("#accessControlButton"),
  logoutButton: document.querySelector("#logoutButton"),
  accessControlPanel: document.querySelector("#accessControlPanel"),
  accessControlForm: document.querySelector("#accessControlForm"),
  hideAccessControlButton: document.querySelector("#hideAccessControlButton"),
  accessEnabled: document.querySelector("#accessEnabled"),
  blockChineseLanguage: document.querySelector("#blockChineseLanguage"),
  blockChinaTimezone: document.querySelector("#blockChinaTimezone"),
  blockChinaIp: document.querySelector("#blockChinaIp"),
  saveAccessControlButton: document.querySelector("#saveAccessControlButton"),
  accessControlStatus: document.querySelector("#accessControlStatus"),
  catalogTab: document.querySelector("#catalogTab"), licenceTab: document.querySelector("#licenceTab"),
  catalogPanel: document.querySelector("#catalogPanel"), licencePanel: document.querySelector("#licencePanel"),
  categoryCount: document.querySelector("#categoryCount"), categoryList: document.querySelector("#categoryList"),
  fxNotice: document.querySelector("#fxNotice"), catalogSearch: document.querySelector("#catalogSearch"),
  sortProducts: document.querySelector("#sortProducts"), activeCategoryTitle: document.querySelector("#activeCategoryTitle"),
  specColumnHeader: document.querySelector("#specColumnHeader"),
  resultsSummary: document.querySelector("#resultsSummary"), productTableBody: document.querySelector("#productTableBody"),
  pageSummary: document.querySelector("#pageSummary"), pageButtons: document.querySelector("#pageButtons"),
  mobilePage: document.querySelector("#mobilePage"), previousPage: document.querySelector("#previousPage"),
  nextPage: document.querySelector("#nextPage"), pageJumpForm: document.querySelector("#pageJumpForm"),
  pageJump: document.querySelector("#pageJump"), declarationSearch: document.querySelector("#declarationSearch"),
  declarationSummary: document.querySelector("#declarationSummary"), declarationBody: document.querySelector("#declarationBody"),
  releaseVersion: document.querySelector("#releaseVersion"),
};

function t(key) { return copy[state.language][key]; }
function locale() { return state.language === "zh" ? "zh-CN" : "fr-FR"; }
function formatNumber(value) { return new Intl.NumberFormat(locale(), { maximumFractionDigits: 2 }).format(Number(value)); }
function formatCny(value) { return new Intl.NumberFormat(locale(), { style: "currency", currency: "CNY", maximumFractionDigits: 2 }).format(Number(value)); }
function formatUsd(value) { return new Intl.NumberFormat(locale(), { style: "currency", currency: "USD", maximumFractionDigits: 2 }).format(Number(value)); }

function escapeHtml(value) {
  return String(value ?? "").replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#039;");
}

function cleanText(value) {
  if (value === null || value === undefined || value === "") return "";
  return String(value).split(/\r?\n/).filter((line) => line.trim().toLowerCase() !== "null").join("\n").trim();
}

function requireAdamSession(response) {
  if (state.isAdam && response.status === 401) {
    window.location.replace("/login?next=%2FAdam");
    throw new Error("Adam session expired");
  }
  return response;
}

function fillAccessControlForm(settings) {
  elements.accessEnabled.checked = settings.enabled;
  elements.blockChineseLanguage.checked = settings.blockChineseLanguage;
  elements.blockChinaTimezone.checked = settings.blockChinaTimezone;
  elements.blockChinaIp.checked = settings.blockChinaIp;
}

async function openAccessControl() {
  if (!state.isAdam) return;
  elements.accessControlButton.hidden = false;
  elements.accessControlPanel.hidden = false;
  elements.accessControlStatus.textContent = "正在读取…";
  const response = requireAdamSession(await fetch("/api/admin/access-control", { cache: "no-store" }));
  fillAccessControlForm(await response.json());
  elements.accessControlStatus.textContent = "";
}

function hideAccessControl() {
  elements.accessControlPanel.hidden = true;
  elements.accessControlButton.hidden = true;
}

async function saveAccessControl(event) {
  event.preventDefault();
  elements.saveAccessControlButton.disabled = true;
  elements.accessControlStatus.textContent = "正在保存…";
  const response = requireAdamSession(await fetch("/api/admin/access-control", {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      enabled: elements.accessEnabled.checked,
      blockChineseLanguage: elements.blockChineseLanguage.checked,
      blockChinaTimezone: elements.blockChinaTimezone.checked,
      blockChinaIp: elements.blockChinaIp.checked,
    }),
  }));
  fillAccessControlForm(await response.json());
  elements.saveAccessControlButton.disabled = false;
  elements.accessControlStatus.textContent = "规则已保存";
}

function productCode(product) {
  const fields = product.fields;
  return cleanText(product.productCode || fields.reference || fields.customerModelPolarity || fields.hsCode || product.id);
}

function productName(product) {
  if (state.language === "fr") return cleanText(product.displayName || product.categoryTitle);
  const fields = product.fields;
  return cleanText(fields.designation || fields.suppliedModel || fields.customerSpecification || fields.reference || productCode(product));
}

function productSpecification(product) {
  if (state.language === "fr") return cleanText(product.displaySpecification);
  const fields = product.fields;
  if (product.categoryId === "pneumatiques") return cleanText(fields.remarks);
  const values = [fields.compatibleModels, fields.specification, fields.customerSpecification, fields.requestedPattern, fields.description, fields.remarks]
    .map(cleanText).filter(Boolean);
  return [...new Set(values)].join("\n");
}

function productUnit(product) {
  const fields = product.fields;
  return cleanText(fields.unit || (state.language === "zh" ? fields.option : fields.option));
}

function scoreMarkup(category) {
  return `<span class="score-line"><span class="score-label">${t("quantityScore")}</span><span class="score-fraction" title="${escapeHtml(`${formatNumber(category.quantity.ordered)} ${category.quantity.unit} / ${formatNumber(category.quantity.quota)} ${category.quantity.unit}`)}"><span class="score-current">${formatNumber(category.quantity.ordered)} ${escapeHtml(category.quantity.unit)}</span><span class="score-separator">/</span><span class="score-limit">${formatNumber(category.quantity.quota)} ${escapeHtml(category.quantity.unit)}</span></span></span>
    <span class="score-line"><span class="score-label">${t("amountScore")}</span><span class="score-fraction" title="${escapeHtml(`${formatCny(category.amount.orderedCny)} / ${formatCny(category.amount.quotaCny)}`)}"><span class="score-current">${formatCny(category.amount.orderedCny)}</span><span class="score-separator">/</span><span class="score-limit">${formatCny(category.amount.quotaCny)}</span></span></span>`;
}

function renderCategories() {
  elements.categoryCount.textContent = state.categories.length;
  elements.categoryList.innerHTML = `<button type="button" class="all-category ${state.category === "all" ? "active" : ""}" data-category="all"><span class="category-name">${t("allProducts")}</span></button>` +
    state.categories.map((category) => `<button type="button" class="${state.category === category.id ? "active" : ""}" data-category="${category.id}"><span class="category-name">${escapeHtml(category.title)}</span><span class="category-score" data-score-category="${category.id}">${scoreMarkup(category)}</span></button>`).join("");
}

function renderCategoryScore(categoryId) {
  const category = state.categories.find((item) => item.id === categoryId);
  const score = elements.categoryList.querySelector(`[data-score-category="${categoryId}"]`);
  if (score) score.innerHTML = scoreMarkup(category);
}

function productRow(product) {
  const name = productName(product);
  const inputLabel = state.language === "fr" ? name : productCode(product);
  const image = product.image
    ? `<span class="product-thumb"><img src="${product.image.url}" alt="${escapeHtml(name)}" width="${product.image.width}" height="${product.image.height}" loading="lazy" decoding="async" draggable="false"></span>`
    : `<span class="no-image">—</span>`;
  const displayedPriceCny = state.language === "fr" ? (product.newPriceCny ?? product.unitPriceCny) : product.unitPriceCny;
  const price = displayedPriceCny === null ? t("quote") : formatCny(displayedPriceCny);
  const unit = productUnit(product);
  const newPriceCell = state.language === "zh"
    ? `<td><input class="order-new-price" type="text" inputmode="decimal" autocomplete="off" value="${product.newPriceCny ?? ""}" data-order-new-price aria-label="${escapeHtml(`${t("newPrice")} CNY ${inputLabel}`)}"></td>`
    : "";
  return `<tr data-record-id="${product.id}">
    <td>${image}</td>
    <td class="product-code">${escapeHtml(productCode(product))}</td>
    <td class="product-name">${escapeHtml(name)}</td>
    <td class="product-spec">${escapeHtml(productSpecification(product) || "—")}</td>
    <td class="product-price">${price}${unit ? `<small>/${escapeHtml(unit)}</small>` : ""}</td>
    ${newPriceCell}
    <td><input class="order-quantity" type="text" inputmode="decimal" autocomplete="off" value="${product.orderedQuantity || ""}" data-order-quantity aria-label="${escapeHtml(`${t("quantity")} ${inputLabel}`)}"></td>
    <td><input class="order-remark" type="text" value="${escapeHtml(product.remark)}" data-order-remark aria-label="${escapeHtml(`${t("remark")} ${inputLabel}`)}"></td>
  </tr>`;
}

function renderProducts() {
  elements.specColumnHeader.textContent = state.category === "pneumatiques" ? t("remarksHeader") : t("specModel");
  elements.productTableBody.innerHTML = state.products.length ? state.products.map(productRow).join("") : `<tr><td colspan="${state.language === "fr" ? 6 : 8}">${t("noResults")}</td></tr>`;
  const active = state.categories.find((category) => category.id === state.category);
  elements.activeCategoryTitle.textContent = active ? active.title : t("allProducts");
  const start = state.total === 0 ? 0 : (state.page - 1) * state.pageSize + 1;
  const end = Math.min(state.page * state.pageSize, state.total);
  elements.resultsSummary.textContent = state.language === "zh" ? `共 ${formatNumber(state.total)} 条` : `${formatNumber(state.total)} produit(s)`;
  elements.pageSummary.textContent = state.language === "zh" ? `第 ${formatNumber(start)}–${formatNumber(end)} 条，共 ${formatNumber(state.total)} 条` : `${formatNumber(start)}–${formatNumber(end)} sur ${formatNumber(state.total)}`;
  renderPagination();
}

function paginationItems() {
  const pages = new Set([1, state.totalPages, state.page - 1, state.page, state.page + 1]);
  return [...pages].filter((page) => page >= 1 && page <= state.totalPages).sort((a, b) => a - b);
}

function renderPagination() {
  const pages = paginationItems();
  let previous = 0;
  elements.pageButtons.innerHTML = pages.map((page) => {
    const gap = previous && page - previous > 1 ? `<span class="page-ellipsis">…</span>` : "";
    previous = page;
    return `${gap}<button type="button" data-page="${page}" class="${page === state.page ? "active" : ""}" aria-current="${page === state.page ? "page" : "false"}">${page}</button>`;
  }).join("");
  elements.mobilePage.textContent = `${state.page} / ${state.totalPages}`;
  elements.previousPage.disabled = state.page <= 1;
  elements.nextPage.disabled = state.page >= state.totalPages;
  elements.pageJump.max = state.totalPages;
}

async function loadCategories() {
  const response = requireAdamSession(await fetch(`/api/categories?locale=${state.language}&workspace=${state.workspace}`));
  const payload = await response.json();
  state.categories = payload.data;
  state.pageSize = payload.pageSize;
  elements.fxNotice.textContent = payload.fxNotice;
  renderCategories();
}

async function loadProducts() {
  const params = new URLSearchParams({ locale: state.language, workspace: state.workspace, category: state.category, q: state.query, sort: state.sort, page: String(state.page) });
  const response = requireAdamSession(await fetch(`/api/products?${params}`));
  const payload = await response.json();
  state.products = payload.data;
  state.page = payload.page;
  state.pageSize = payload.pageSize;
  state.total = payload.total;
  state.totalPages = payload.totalPages;
  renderProducts();
}

function updateLocalTotals(product, nextQuantity, nextPriceCny = product.newPriceCny) {
  const category = state.categories.find((item) => item.id === product.categoryId);
  const previousAmount = product.orderedQuantity * Number(product.newPriceCny ?? product.unitPriceCny ?? 0);
  const delta = nextQuantity - product.orderedQuantity;
  product.orderedQuantity = nextQuantity;
  product.newPriceCny = nextPriceCny;
  product.orderedAmountCny = nextQuantity * Number(nextPriceCny ?? product.unitPriceCny ?? 0);
  category.quantity.ordered += delta * (category.quantity.mode === "weight_kg" ? product.unitWeightKg : 1);
  category.amount.orderedCny += product.orderedAmountCny - previousAmount;
  renderCategoryScore(product.categoryId);
}

function queueSave(product) {
  const revision = (state.editRevisions.get(product.id) ?? 0) + 1;
  state.editRevisions.set(product.id, revision);
  state.dirtyProducts.set(product.id, product);
  clearTimeout(state.saveTimers.get(product.id));
  state.saveTimers.set(product.id, setTimeout(() => {
    state.saveTimers.delete(product.id);
    void saveProduct(product, revision);
  }, 350));
}

function saveProduct(product, revision) {
  const order = { orderedQuantity: product.orderedQuantity, remark: product.remark };
  if (state.isAdam) order.newPriceCny = product.newPriceCny;
  const body = JSON.stringify(order);
  const previous = state.saveRequests.get(product.id) ?? Promise.resolve();
  const request = previous.then(async () => {
    const response = requireAdamSession(await fetch(`/api/products/${encodeURIComponent(product.id)}/order?workspace=${state.workspace}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body,
    }));
    if (!response.ok) throw new Error(`Order save: ${response.status}`);
    const payload = await response.json();
    if (state.editRevisions.get(product.id) !== revision) return;
    state.dirtyProducts.delete(product.id);
    if (state.dirtyProducts.size === 0) {
      for (const stats of payload.categoryStats) {
        const category = state.categories.find((item) => item.id === stats.categoryId);
        category.quantity.ordered = stats.orderedQuantity;
        category.quantity.quota = stats.quotaQuantity;
        category.amount.orderedCny = stats.orderedAmountCny;
        category.amount.quotaCny = stats.quotaAmountCny;
        renderCategoryScore(stats.categoryId);
      }
    }
  }).catch((error) => {
    console.error(error);
  }).finally(() => {
    if (state.saveRequests.get(product.id) === request) state.saveRequests.delete(product.id);
  });
  state.saveRequests.set(product.id, request);
  return request;
}

async function flushOrderSaves() {
  for (const [id, product] of state.dirtyProducts) {
    if (state.saveRequests.has(id)) continue;
    clearTimeout(state.saveTimers.get(id));
    state.saveTimers.delete(id);
    void saveProduct(product, state.editRevisions.get(id));
  }
  await Promise.all(state.saveRequests.values());
}

function renderLicence() {
  if (!state.licence) return;
  const query = elements.declarationSearch.value.trim().toLocaleLowerCase();
  const entries = state.licence[state.language].filter((entry) => [entry.hsCode10, entry.designation, entry.requestedBrandKeyword].join(" ").toLocaleLowerCase().includes(query));
  elements.declarationBody.innerHTML = entries.map((entry) => `<tr>
    <td>${entry.number}</td><td class="product-code">${escapeHtml(entry.hsCode10)}</td><td>${escapeHtml(cleanText(entry.designation))}</td>
    <td>${escapeHtml(cleanText(entry.requestedBrandKeyword) || "—")}</td><td>${escapeHtml(cleanText(entry.originCountry))}</td><td>${escapeHtml(cleanText(entry.supplierCountry))}</td>
    <td class="numeric">${formatNumber(entry.requestedQuantity)} ${escapeHtml(cleanText(entry.unit))}</td><td class="numeric">${formatUsd(entry.declaredUnitPriceUsd)}</td>
    <td class="numeric">${formatUsd(entry.calculatedValueUsd)}</td><td>${entry.targetCategoryId ? `<button class="category-link" type="button" data-declaration-category="${entry.targetCategoryId}">${t("viewOffers")}</button>` : "—"}</td>
  </tr>`).join("");
  elements.declarationSummary.textContent = state.language === "zh" ? `${entries.length} 条` : `${entries.length} position(s)`;
}

async function imageAsPngDataUrl(url) {
  const blob = await (await fetch(url)).blob();
  const bitmap = await createImageBitmap(blob);
  const canvas = document.createElement("canvas");
  canvas.width = 160;
  canvas.height = 160;
  const context = canvas.getContext("2d");
  context.fillStyle = "#ffffff";
  context.fillRect(0, 0, 160, 160);
  const scale = Math.min(148 / bitmap.width, 148 / bitmap.height);
  const width = bitmap.width * scale;
  const height = bitmap.height * scale;
  context.drawImage(bitmap, (160 - width) / 2, (160 - height) / 2, width, height);
  bitmap.close();
  return canvas.toDataURL("image/png");
}

async function exportOrders(redacted, exportLanguage) {
  await flushOrderSaves();
  const button = redacted ? elements.exportRedactedButton : elements.exportOrdersButton;
  const label = button.textContent;
  const labels = exportCopy[exportLanguage];
  button.disabled = true;
  button.textContent = "生成中…";

  const exportResponse = requireAdamSession(await fetch(`/api/export/orders?locale=${exportLanguage}`, { cache: "no-store" }));
  const payload = await exportResponse.json();
  const workbook = new ExcelJS.Workbook();
  workbook.creator = "Sidi Achour";
  workbook.created = new Date();
  const worksheet = workbook.addWorksheet(labels.sheet, {
    properties: { defaultRowHeight: 24 },
    pageSetup: { orientation: "landscape", fitToPage: true, fitToWidth: 1, fitToHeight: 0 },
    views: [{
      state: "frozen",
      xSplit: redacted ? 3 : 4,
      ySplit: 5,
      topLeftCell: redacted ? "D6" : "E6",
      activeCell: "A6",
      showGridLines: false,
    }],
  });

  const columns = redacted ? [
    { header: labels.headers.number, key: "number", width: 6 },
    { header: labels.headers.category, key: "category", width: 28 },
    { header: labels.headers.name, key: "name", width: 32 },
    { header: labels.headers.specification, key: "specification", width: 40 },
    { header: labels.headers.unit, key: "unit", width: 10 },
    { header: labels.headers.price, key: "price", width: 14 },
    { header: labels.headers.quantity, key: "quantity", width: 12 },
    { header: labels.headers.amount, key: "amount", width: 17 },
    { header: labels.headers.remark, key: "remark", width: 28 },
  ] : [
    { header: labels.headers.number, key: "number", width: 6 },
    { header: labels.headers.image, key: "image", width: 14 },
    { header: labels.headers.code, key: "code", width: 20 },
    { header: labels.headers.name, key: "name", width: 28 },
    { header: labels.headers.category, key: "category", width: 28 },
    { header: labels.headers.specification, key: "specification", width: 40 },
    { header: labels.headers.unit, key: "unit", width: 10 },
    { header: labels.headers.price, key: "price", width: 14 },
    { header: labels.headers.quantity, key: "quantity", width: 12 },
    { header: labels.headers.amount, key: "amount", width: 17 },
    { header: labels.headers.remark, key: "remark", width: 28 },
  ];
  worksheet.columns = columns.map(({ key, width }) => ({ key, width }));
  const columnCount = columns.length;
  worksheet.mergeCells(1, 1, 1, columnCount);
  worksheet.getCell(1, 1).value = redacted ? labels.redactedTitle : labels.title;
  worksheet.getCell(1, 1).font = { name: "Microsoft YaHei", size: 20, bold: true, color: { argb: "FF000000" } };
  worksheet.getCell(1, 1).alignment = { vertical: "middle", horizontal: "left" };
  worksheet.getRow(1).height = 32;
  worksheet.mergeCells(2, 1, 2, 2);
  worksheet.getCell(2, 1).value = "Sidi Achour";
  worksheet.getCell(2, 1).font = { name: "Microsoft YaHei", size: 11, bold: true, color: { argb: "FF1A1A1A" } };
  worksheet.mergeCells(2, 3, 2, columnCount);
  worksheet.getCell(2, 3).value = `${labels.exportedAt}${exportLanguage === "fr" ? " : " : "："}${new Intl.DateTimeFormat(exportLanguage === "fr" ? "fr-FR" : "zh-CN", { dateStyle: "medium", timeStyle: "medium", hour12: false }).format(new Date())}`;
  worksheet.getCell(2, 3).font = { name: "Microsoft YaHei", size: 11, color: { argb: "FF1A1A1A" } };
  worksheet.getCell(2, 3).alignment = { horizontal: "right", vertical: "middle" };
  worksheet.mergeCells(3, 1, 3, columnCount);
  worksheet.getCell(3, 1).value = labels.currencyNote;
  worksheet.getCell(3, 1).font = { name: "Microsoft YaHei", size: 10, italic: true, color: { argb: "FF6B6B6B" } };
  worksheet.getRow(4).height = 8;

  const headerRow = worksheet.getRow(5);
  headerRow.values = columns.map((column) => column.header);
  headerRow.height = 36;
  headerRow.eachCell((cell) => {
    cell.font = { name: "Microsoft YaHei", size: 11, bold: true, color: { argb: "FFFFFFFF" } };
    cell.fill = { type: "pattern", pattern: "solid", fgColor: { argb: "FF000000" } };
    cell.alignment = { horizontal: "center", vertical: "middle", wrapText: true };
    cell.border = { right: { style: "thin", color: { argb: "FFFFFFFF" } } };
  });

  const imageIds = new Map();
  if (!redacted) {
    const imageUrls = [...new Set(payload.data.map((row) => row.imageUrl).filter(Boolean))];
    await Promise.all(imageUrls.map(async (url) => {
      const imageId = workbook.addImage({ base64: await imageAsPngDataUrl(url), extension: "png" });
      imageIds.set(url, imageId);
    }));
  }

  payload.data.forEach((order, index) => {
    const values = redacted ? [
      index + 1,
      order.category,
      order.productName,
      order.specification,
      order.salesUnit,
      order.effectivePriceCny,
      order.orderedQuantity,
      order.orderedAmountCny,
      order.orderRemark,
    ] : [
      index + 1,
      order.imageUrl ? "" : "—",
      order.productCode,
      order.productName,
      order.category,
      order.specification,
      order.salesUnit,
      order.effectivePriceCny,
      order.orderedQuantity,
      order.orderedAmountCny,
      order.orderRemark,
    ];
    const row = worksheet.addRow(values);
    row.height = redacted ? 42 : 56;
    row.eachCell({ includeEmpty: true }, (cell, columnNumber) => {
      cell.font = { name: "Microsoft YaHei", size: 11, color: { argb: "FF1A1A1A" } };
      cell.fill = { type: "pattern", pattern: "solid", fgColor: { argb: index % 2 ? "FFF7F7F7" : "FFFFFFFF" } };
      cell.alignment = { vertical: "middle", horizontal: "left", wrapText: true };
      cell.border = { bottom: { style: "thin", color: { argb: "FFCCCCCC" } } };
      const numericColumns = redacted ? [1, 6, 7, 8] : [1, 8, 9, 10];
      if (numericColumns.includes(columnNumber)) cell.alignment = { vertical: "middle", horizontal: "right" };
    });
    const priceColumn = redacted ? 6 : 8;
    const quantityColumn = redacted ? 7 : 9;
    const amountColumn = redacted ? 8 : 10;
    row.getCell(priceColumn).numFmt = '#,##0.00';
    row.getCell(quantityColumn).numFmt = '#,##0.##';
    row.getCell(amountColumn).numFmt = '#,##0.00';
    if (!redacted && order.imageUrl) {
      worksheet.addImage(imageIds.get(order.imageUrl), {
        tl: { col: 1.15, row: row.number - 0.92 },
        ext: { width: 64, height: 64 },
        editAs: "oneCell",
      });
    }
  });

  worksheet.autoFilter = `A5:${worksheet.getColumn(columnCount).letter}${5 + payload.data.length}`;
  const totalRow = worksheet.addRow(new Array(columnCount).fill(null));
  const amountColumn = redacted ? 8 : 10;
  worksheet.mergeCells(totalRow.number, 1, totalRow.number, amountColumn - 1);
  totalRow.getCell(1).value = labels.total;
  totalRow.getCell(1).alignment = { horizontal: "right", vertical: "middle" };
  totalRow.getCell(amountColumn).value = payload.data.reduce((sum, order) => sum + Number(order.orderedAmountCny ?? 0), 0);
  totalRow.getCell(amountColumn).numFmt = '#,##0.00';
  totalRow.height = 30;
  totalRow.eachCell({ includeEmpty: true }, (cell) => {
    cell.font = { name: "Microsoft YaHei", size: 11, bold: true, color: { argb: "FF000000" } };
    cell.border = { top: { style: "medium", color: { argb: "FFD42A1D" } } };
  });

  worksheet.pageSetup.printTitlesRow = "1:5";
  const buffer = await workbook.xlsx.writeBuffer();
  const downloadUrl = URL.createObjectURL(new Blob([buffer], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }));
  const anchor = document.createElement("a");
  anchor.href = downloadUrl;
  anchor.download = `Sidi_Achour_${redacted ? labels.redactedFile : labels.file}_${new Date().toISOString().slice(0, 10)}.xlsx`;
  anchor.click();
  window.setTimeout(() => { URL.revokeObjectURL(downloadUrl); }, 1000);
  button.disabled = false;
  button.textContent = label;
}

function applyLanguageCopy() {
  document.documentElement.lang = state.language === "zh" ? "zh-CN" : "fr";
  document.title = `Sidi Achour | ${state.activeTab === "catalog" ? t("catalogNav") : t("licenceTitle")}`;
  document.querySelectorAll("[data-i18n]").forEach((node) => { node.textContent = t(node.dataset.i18n); });
  document.querySelectorAll("[data-i18n-aria-label]").forEach((node) => { node.setAttribute("aria-label", t(node.dataset.i18nAriaLabel)); });
  elements.adminActions.hidden = state.language !== "zh";
  elements.catalogSearch.placeholder = t("searchPlaceholder");
  elements.sortProducts.querySelector('option[value="code"]').hidden = state.language === "fr";
  elements.declarationSearch.placeholder = t("licenceSearchPlaceholder");
}

function setTab(tab) {
  state.activeTab = tab;
  const catalog = tab === "catalog";
  elements.catalogPanel.hidden = !catalog;
  elements.licencePanel.hidden = catalog;
  elements.catalogTab.classList.toggle("active", catalog);
  elements.licenceTab.classList.toggle("active", !catalog);
  elements.catalogTab.setAttribute("aria-selected", String(catalog));
  elements.licenceTab.setAttribute("aria-selected", String(!catalog));
  document.title = `Sidi Achour | ${catalog ? t("catalogNav") : t("licenceTitle")}`;
}

function closeExportMenus() {
  for (const [button, menu] of [
    [elements.exportOrdersButton, elements.exportOrdersMenu],
    [elements.exportRedactedButton, elements.exportRedactedMenu],
  ]) {
    menu.hidden = true;
    button.setAttribute("aria-expanded", "false");
  }
}

function toggleExportMenu(button, menu) {
  const willOpen = menu.hidden;
  closeExportMenus();
  if (willOpen) {
    menu.hidden = false;
    button.setAttribute("aria-expanded", "true");
    menu.querySelector("button").focus();
  }
}

function wireInteractions() {
  document.addEventListener("keydown", (event) => {
    const commandKey = event.ctrlKey || event.metaKey;
    const key = event.key.toLowerCase();
    if (state.isAdam && commandKey && event.shiftKey && key === "g") {
      event.preventDefault();
      event.stopPropagation();
      void openAccessControl();
      return;
    }
    if (commandKey && (key === "s" || key === "p")) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);
  document.addEventListener("contextmenu", (event) => {
    event.preventDefault();
  }, true);
  document.addEventListener("dragstart", (event) => {
    if (event.target.closest("img, .product-thumb")) event.preventDefault();
  }, true);
  document.querySelector(".primary-tabs").addEventListener("click", (event) => {
    const button = event.target.closest("[data-tab]");
    if (button) setTab(button.dataset.tab);
  });
  elements.exportOrdersButton.addEventListener("click", () => { toggleExportMenu(elements.exportOrdersButton, elements.exportOrdersMenu); });
  elements.exportRedactedButton.addEventListener("click", () => { toggleExportMenu(elements.exportRedactedButton, elements.exportRedactedMenu); });
  elements.accessControlButton.addEventListener("click", () => { void openAccessControl(); });
  elements.hideAccessControlButton.addEventListener("click", hideAccessControl);
  elements.accessControlForm.addEventListener("submit", (event) => { void saveAccessControl(event); });
  elements.logoutButton.addEventListener("click", async () => {
    await fetch("/api/auth/logout", { method: "POST" });
    window.location.replace("/login");
  });
  elements.adminActions.addEventListener("click", (event) => {
    const option = event.target.closest("[data-export-language]");
    if (!option) return;
    closeExportMenus();
    void exportOrders(option.dataset.exportRedacted === "true", option.dataset.exportLanguage);
  });
  document.addEventListener("click", (event) => {
    if (!event.target.closest(".export-control")) closeExportMenus();
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeExportMenus();
  });
  elements.categoryList.addEventListener("click", (event) => {
    const button = event.target.closest("[data-category]");
    if (!button) return;
    state.category = button.dataset.category;
    state.page = 1;
    renderCategories();
    void loadProducts();
  });
  elements.catalogSearch.addEventListener("input", (event) => {
    state.query = event.target.value;
    state.page = 1;
    clearTimeout(state.searchTimer);
    state.searchTimer = setTimeout(() => { void loadProducts(); }, 250);
  });
  elements.sortProducts.addEventListener("change", (event) => { state.sort = event.target.value; state.page = 1; void loadProducts(); });
  elements.previousPage.addEventListener("click", () => { state.page -= 1; void loadProducts(); });
  elements.nextPage.addEventListener("click", () => { state.page += 1; void loadProducts(); });
  elements.pageButtons.addEventListener("click", (event) => {
    const button = event.target.closest("[data-page]");
    if (button) { state.page = Number(button.dataset.page); void loadProducts(); }
  });
  elements.pageJumpForm.addEventListener("submit", (event) => {
    event.preventDefault();
    state.page = Math.min(state.totalPages, Math.max(1, Number(elements.pageJump.value)));
    void loadProducts();
  });
  elements.productTableBody.addEventListener("input", (event) => {
    const row = event.target.closest("[data-record-id]");
    if (!row) return;
    const product = state.products.find((item) => item.id === row.dataset.recordId);
    if (event.target.matches("[data-order-new-price]")) updateLocalTotals(product, product.orderedQuantity, event.target.value === "" ? null : Number(event.target.value.replace(",", ".")));
    if (event.target.matches("[data-order-quantity]")) updateLocalTotals(product, Number(event.target.value.replace(",", ".") || 0));
    if (event.target.matches("[data-order-remark]")) product.remark = event.target.value;
    queueSave(product);
  });
  elements.declarationSearch.addEventListener("input", renderLicence);
  elements.declarationBody.addEventListener("click", (event) => {
    const button = event.target.closest("[data-declaration-category]");
    if (!button) return;
    state.category = button.dataset.declarationCategory;
    state.page = 1;
    setTab("catalog");
    renderCategories();
    void loadProducts();
    window.scrollTo({ top: 0, behavior: "smooth" });
  });
}

function isEditing() {
  return document.activeElement.matches('input, textarea, select, [contenteditable="true"]');
}

function captureView() {
  return {
    activeTab: state.activeTab, category: state.category,
    query: state.query, sort: state.sort, page: state.page,
    declarationQuery: elements.declarationSearch.value,
    scrollX: window.scrollX, scrollY: window.scrollY,
    tableScroll: document.querySelector('.product-table-wrap').scrollLeft,
    categoryScroll: elements.categoryList.scrollLeft,
    railScroll: document.querySelector('.category-rail').scrollTop,
    declarationScroll: document.querySelector('.declaration-table-wrap').scrollLeft,
  };
}

async function applyAvailableRelease() {
  if (!release.available || release.applying || document.hidden || isEditing()) return;
  if (sessionStorage.getItem('sidi-last-reloaded-version') === release.available.version) return;
  release.applying = true;
  try {
    await flushOrderSaves();
    if (state.dirtyProducts.size || document.hidden || isEditing()) return;
    await Promise.all(release.available.assets.map(async (url) => {
      const response = await fetch(url, { cache: 'force-cache', signal: AbortSignal.timeout(15000) });
      if (!response.ok) throw new Error(`Release asset: ${response.status}`);
      await response.arrayBuffer();
    }));
    if (state.dirtyProducts.size || document.hidden || isEditing()) return;
    sessionStorage.setItem('sidi-resume-view', JSON.stringify(captureView()));
    sessionStorage.setItem('sidi-last-reloaded-version', release.available.version);
    window.location.reload();
  } catch (error) {
    console.debug('Release update postponed:', error.message);
  } finally {
    release.applying = false;
  }
}

async function checkForRelease() {
  if (release.current === 'development' || document.hidden || release.checking || release.applying) return;
  release.checking = true;
  try {
    const response = await fetch('/version.json', { cache: 'no-store', signal: AbortSignal.timeout(10000) });
    if (!response.ok) return;
    const latest = await response.json();
    release.available = latest.version === release.current ? null : latest;
    await applyAvailableRelease();
  } catch (error) {
    console.debug('Release check postponed:', error.message);
  } finally {
    release.checking = false;
  }
}

function startReleaseChecks() {
  const schedule = () => {
    clearInterval(release.interval);
    if (document.hidden) return;
    void checkForRelease();
    release.interval = setInterval(checkForRelease, 60000);
  };
  document.addEventListener('visibilitychange', schedule);
  window.addEventListener('online', () => { void checkForRelease(); });
  window.addEventListener('pageshow', (event) => { if (event.persisted) schedule(); });
  document.addEventListener('focusout', () => {
    setTimeout(() => { void applyAvailableRelease(); }, 400);
  });
  schedule();
}

async function start() {
  elements.releaseVersion.textContent = release.current;
  const resume = JSON.parse(sessionStorage.getItem('sidi-resume-view') ?? 'null');
  if (resume) {
    for (const key of ['activeTab', 'category', 'query', 'sort', 'page']) state[key] = resume[key];
    if (state.language === "fr" && state.sort === "code") state.sort = "source";
    elements.catalogSearch.value = state.query;
    elements.sortProducts.value = state.sort;
    elements.declarationSearch.value = resume.declarationQuery;
  }
  wireInteractions();
  applyLanguageCopy();
  setTab(state.activeTab);
  const licenceResponse = await fetch("/data/licence.json");
  state.licence = await licenceResponse.json();
  await Promise.all([loadCategories(), loadProducts()]);
  renderLicence();
  if (resume) {
    sessionStorage.removeItem('sidi-resume-view');
    document.querySelector('.product-table-wrap').scrollLeft = resume.tableScroll;
    elements.categoryList.scrollLeft = resume.categoryScroll;
    document.querySelector('.category-rail').scrollTop = resume.railScroll;
    document.querySelector('.declaration-table-wrap').scrollLeft = resume.declarationScroll;
    requestAnimationFrame(() => window.scrollTo({ left: resume.scrollX, top: resume.scrollY, behavior: 'instant' }));
  }
  startReleaseChecks();
}

async function boot() {
  const minimumSplash = new Promise((resolve) => window.setTimeout(resolve, 900));
  await Promise.all([start(), minimumSplash]);
  elements.splashScreen.classList.add("is-leaving");
  document.body.removeAttribute("aria-busy");
  window.setTimeout(() => { elements.splashScreen.hidden = true; }, 180);
}

void boot();
