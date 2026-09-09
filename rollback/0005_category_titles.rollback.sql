UPDATE categories
SET title_fr = (
      SELECT b.title_fr FROM rollback_0005_category_titles b
      WHERE b.id = categories.id
    ),
    title_zh = (
      SELECT b.title_zh FROM rollback_0005_category_titles b
      WHERE b.id = categories.id
    )
WHERE id IN (SELECT id FROM rollback_0005_category_titles);

DROP TABLE category_title_provenance;
DROP TABLE rollback_0005_category_titles;
