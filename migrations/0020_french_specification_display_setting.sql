ALTER TABLE access_control_settings
ADD COLUMN show_all_french_specifications INTEGER NOT NULL DEFAULT 0 CHECK (show_all_french_specifications IN (0, 1));
