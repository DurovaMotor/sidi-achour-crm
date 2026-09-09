const copy = {
  zh: {
    skip: "跳到内容", brandFlow: "HighTac 向 Sidi Achour 供应", businessPages: "业务页面", languageLabel: "语言",
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
    skip: "Aller au contenu", brandFlow: "HighTac fournit Sidi Achour", businessPages: "Pages métier", languageLabel: "Langue",
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

const state = {
  language: "zh",
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

function productCode(product) {
  const fields = product.fields;
  return cleanText(product.productCode || fields.reference || fields.customerModelPolarity || fields.hsCode || product.id);
}

function productName(product) {
  const fields = product.fields;
  return cleanText(fields.designation || fields.suppliedModel || fields.customerSpecification || (state.language === "fr" ? product.categoryTitle : fields.reference || productCode(product)));
}

function productSpecification(product) {
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
  elements.productTableBody.innerHTML = state.products.length ? state.products.map(productRow).join("") : `<tr><td colspan="${state.language === "fr" ? 7 : 8}">${t("noResults")}</td></tr>`;
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
  const response = await fetch(`/api/categories?locale=${state.language}`);
  const payload = await response.json();
  state.categories = payload.data;
  state.pageSize = payload.pageSize;
  elements.fxNotice.textContent = payload.fxNotice;
  renderCategories();
}

async function loadProducts() {
  const params = new URLSearchParams({ locale: state.language, category: state.category, q: state.query, sort: state.sort, page: String(state.page) });
  const response = await fetch(`/api/products?${params}`);
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
  const body = JSON.stringify({ newPriceCny: product.newPriceCny, orderedQuantity: product.orderedQuantity, remark: product.remark });
  const previous = state.saveRequests.get(product.id) ?? Promise.resolve();
  const request = previous.then(async () => {
    const response = await fetch(`/api/products/${encodeURIComponent(product.id)}/order`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body,
    });
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

function applyLanguageCopy() {
  document.documentElement.lang = state.language === "zh" ? "zh-CN" : "fr";
  document.title = `HighTac → Sidi Achour | ${state.activeTab === "catalog" ? t("catalogNav") : t("licenceTitle")}`;
  document.querySelectorAll("[data-i18n]").forEach((node) => { node.textContent = t(node.dataset.i18n); });
  document.querySelectorAll("[data-i18n-aria-label]").forEach((node) => { node.setAttribute("aria-label", t(node.dataset.i18nAriaLabel)); });
  document.querySelectorAll("[data-language]").forEach((button) => {
    const active = button.dataset.language === state.language;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  });
  elements.catalogSearch.placeholder = t("searchPlaceholder");
  elements.sortProducts.querySelector('option[value="code"]').hidden = state.language === "fr";
  elements.declarationSearch.placeholder = t("licenceSearchPlaceholder");
}

async function changeLanguage(language) {
  await flushOrderSaves();
  state.language = language;
  if (language === "fr" && state.sort === "code") {
    state.sort = "source";
    elements.sortProducts.value = "source";
  }
  applyLanguageCopy();
  await Promise.all([loadCategories(), loadProducts()]);
  renderLicence();
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
  document.title = `HighTac → Sidi Achour | ${catalog ? t("catalogNav") : t("licenceTitle")}`;
}

function wireInteractions() {
  document.querySelector(".primary-tabs").addEventListener("click", (event) => {
    const button = event.target.closest("[data-tab]");
    if (button) setTab(button.dataset.tab);
  });
  document.querySelector(".language-switch").addEventListener("click", (event) => {
    const button = event.target.closest("[data-language]");
    if (button) void changeLanguage(button.dataset.language);
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
  elements.productTableBody.addEventListener("contextmenu", (event) => {
    if (event.target.closest(".product-thumb")) event.preventDefault();
  });
  elements.productTableBody.addEventListener("dragstart", (event) => {
    if (event.target.closest(".product-thumb")) event.preventDefault();
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
    language: state.language, activeTab: state.activeTab, category: state.category,
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
    for (const key of ['language', 'activeTab', 'category', 'query', 'sort', 'page']) state[key] = resume[key];
    elements.catalogSearch.value = state.query;
    elements.sortProducts.value = state.sort;
    elements.declarationSearch.value = resume.declarationQuery;
  }
  wireInteractions();
  applyLanguageCopy();
  setTab(state.activeTab);
  const licenceResponse = await fetch("data/licence.json");
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

void start();
