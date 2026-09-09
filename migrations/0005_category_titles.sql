CREATE TABLE category_title_provenance (
  category_id TEXT PRIMARY KEY REFERENCES categories(id) ON DELETE CASCADE,
  source_workbook TEXT NOT NULL,
  source_sheet TEXT NOT NULL,
  source_cells TEXT NOT NULL,
  title_fr TEXT NOT NULL,
  title_zh TEXT NOT NULL,
  matched_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE rollback_0005_category_titles (
  id TEXT PRIMARY KEY,
  title_fr TEXT NOT NULL,
  title_zh TEXT NOT NULL
);

INSERT INTO rollback_0005_category_titles(id, title_fr, title_zh)
SELECT id, title_fr, title_zh FROM categories;

INSERT INTO category_title_provenance(category_id, source_workbook, source_sheet, source_cells, title_fr, title_zh) VALUES
  ('plaquettes-de-frein', 'Sidi.xlsx', 'Licence', 'D5', 'Freins et dispositifs de freinage pour motocycles', '摩托车用制动器及制动装置'),
  ('pneumatiques', 'Sidi.xlsx', 'Licence', 'D6,D19', 'Pneumatiques en caoutchouc pour motocycles / Pneumatiques à chambre à air, en caoutchouc, pour motocycles', '摩托车用橡胶轮胎 / 摩托车用充气橡胶轮胎（有内胎）'),
  ('filtres-a-huile', 'Sidi.xlsx', 'Licence', 'D7', 'Filtres à huile pour motocycles', '摩托车用机油滤清器'),
  ('batteries', 'Sidi.xlsx', 'Licence', 'D8', 'Batteries pour motocycles', '摩托车用蓄电池'),
  ('radiateurs', 'Sidi.xlsx', 'Licence', 'D9', 'Radiateurs pour motocycles', '摩托车用散热器'),
  ('vilebrequins', 'Sidi.xlsx', 'Licence', 'D10', 'Vilebrequins', '曲轴'),
  ('embrayages', 'Sidi.xlsx', 'Licence', 'D11', 'Disques d’embrayage pour motocycles', '摩托车用离合器片'),
  ('bougies', 'Sidi.xlsx', 'Licence', 'D13', 'Bougies d’allumage pour motocycles', '摩托车用点火火花塞'),
  ('chambres-a-air', 'Sidi.xlsx', 'Licence', 'D14', 'Chambres à air pour motocycles', '摩托车用内胎'),
  ('moteurs', 'Sidi.xlsx', 'Licence', 'D15', 'Moteurs pour motocycles', '摩托车用发动机'),
  ('carburateurs', 'Sidi.xlsx', 'Licence', 'D16', 'Carburateurs', '化油器'),
  ('cylindres-et-carters', 'Sidi.xlsx', 'Licence', 'D17', 'Blocs-cylindres, cylindres, carters de vilebrequin et culasses', '气缸体、气缸、曲轴箱及气缸盖'),
  ('filtres-a-air', 'Sidi.xlsx', 'Licence', 'D18', 'Filtres à air pour motocycles', '摩托车用空气滤清器'),
  ('chaines-de-distribution', 'Sidi.xlsx', 'Licence', 'D22', 'Chaînes de distribution pour motocycles', '摩托车用正时链条'),
  ('pare-brise-et-deflecteurs', 'Sidi.xlsx', 'Licence', 'D20,D23,D28', 'Pare-brise pour motocycles — PUIG / Pare-brise pour motocycles / Pare-brise pour motocycles — GIVI', '摩托车用挡风玻璃 — PUIG / 摩托车用挡风玻璃 / 摩托车用挡风玻璃 — GIVI'),
  ('eclairage', 'Sidi.xlsx', 'Licence', 'D24,D43', 'Lampes pour motocycles / Lampes pour motocycles — PUIG', '摩托车用灯具 / 摩托车用灯具 — PUIG'),
  ('pignons-et-chaines', 'Sidi.xlsx', 'Licence', 'D25', 'Pignons et couronnes pour motocycles', '摩托车用小齿轮及齿圈'),
  ('fourches-avant', 'Sidi.xlsx', 'Licence', 'D26', 'Fourches avant pour motocycles', '摩托车用前叉'),
  ('jantes', 'Sidi.xlsx', 'Licence', 'D27', 'Jantes pour motocycles', '摩托车用轮辋'),
  ('demarreurs', 'Sidi.xlsx', 'Licence', 'D29', 'Démarreurs électriques', '电动起动机'),
  ('amortisseurs', 'Sidi.xlsx', 'Licence', 'D30', 'Amortisseurs pour motocycles', '摩托车用减震器'),
  ('galets-et-rouleaux', 'Sidi.xlsx', 'Licence', 'D31', 'Rouleaux et galets pour motocycles', '摩托车用滚子及滚轮'),
  ('cables-et-durites', 'Sidi.xlsx', 'Licence', 'D32', 'Câbles d’embrayage, de frein et d’accélérateur', '离合器、制动器及油门拉索'),
  ('guidons', 'Sidi.xlsx', 'Licence', 'D33', 'Guidons pour motocycles', '摩托车用车把'),
  ('bobines-et-allumage', 'Sidi.xlsx', 'Licence', 'D34', 'Bobines et composants d’allumage pour motocycles', '摩托车用点火线圈及点火部件'),
  ('bielles', 'Sidi.xlsx', 'Licence', 'D35', 'Bielles pour motocycles', '摩托车用连杆'),
  ('vis-boulons-et-bagues', 'Sidi.xlsx', 'Licence', 'D36,D37', 'Vis, boulons et anneaux métalliques', '螺钉、螺栓及金属环'),
  ('pompes-a-huile', 'Sidi.xlsx', 'Licence', 'D38', 'Pompes à huile pour motocycles', '摩托车用机油泵'),
  ('filtres-a-carburant', 'Sidi.xlsx', 'Licence', 'D39', 'Filtres à carburant pour motocycles', '摩托车用燃油滤清器'),
  ('pistons', 'Sidi.xlsx', 'Licence', 'D40', 'Pistons', '活塞'),
  ('roulements-a-billes', 'Sidi.xlsx', 'Licence', 'D41', 'Roulements à billes pour motocycles', '摩托车用滚珠轴承'),
  ('joints-et-rondelles', 'Sidi.xlsx', 'Licence', 'D42', 'Anneaux et rondelles pour motocycles', '摩托车用环及垫圈'),
  ('soupapes-et-valves', 'Sidi.xlsx', 'Licence', 'D44', 'Soupapes et valves pour motocycles', '摩托车用气门及阀门'),
  ('cles-et-serrures', 'Sidi.xlsx', 'Licence', 'D45,D46', 'Clés et serrures / Clés et serrures — GIVI', '钥匙及锁具 / 钥匙及锁具 — GIVI'),
  ('devis-sur-demande', 'Sidi.xlsx', 'Licence', 'D12,D21', 'Pneumatiques à chambre à air, en caoutchouc, pour bicyclettes / Pneumatiques en caoutchouc pour bicyclettes', '自行车用充气橡胶轮胎（有内胎） / 自行车用橡胶轮胎');

UPDATE categories
SET title_fr = (
      SELECT p.title_fr FROM category_title_provenance p
      WHERE p.category_id = categories.id
    ),
    title_zh = (
      SELECT p.title_zh FROM category_title_provenance p
      WHERE p.category_id = categories.id
    )
WHERE id IN (SELECT category_id FROM category_title_provenance);
