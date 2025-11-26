-- ============================================================
-- test_data.sql
-- Standard use case test for identiflora_testing_db
-- ============================================================

-- 0) Use the correct database
USE identiflora_testing_db;

-- ------------------------------------------------------------
-- 1) Clean out existing data so the test is repeatable
-- ------------------------------------------------------------

-- Delete in dependency order (child + parent) to respect FKs
DELETE FROM incorrect_identification;
DELETE FROM identification_result;
DELETE FROM identification_option;
DELETE FROM identification_submission;
DELETE FROM plant_species;
DELETE FROM user;

-- Optional: reset AUTO_INCREMENT counters for nicer IDs
ALTER TABLE user                      AUTO_INCREMENT = 1;
ALTER TABLE identification_submission AUTO_INCREMENT = 1;
ALTER TABLE plant_species             AUTO_INCREMENT = 1;
ALTER TABLE identification_option     AUTO_INCREMENT = 1;

-- ============================================================
-- 2) User joins the app
-- ============================================================

INSERT INTO user (email, password_hash, phone)
VALUES ('alice@example.com',
        'fake_hash_for_demo_only',
        '+1-555-000-1234');

-- save user id to use later
SET @user_id := LAST_INSERT_ID();

-- ============================================================
-- 3) Pre-load some plant species the model can identify
-- ============================================================

INSERT INTO plant_species (common_name, scientific_name, genus, img_url)
VALUES 
  ('Common Sunflower', 'Helianthus annuus', 'Helianthus',
   'https://example.com/img/sunflower_ref.jpg'),
  ('English Oak', 'Quercus robur', 'Quercus',
   'https://example.com/img/english_oak_ref.jpg'),
  ('Dandelion', 'Taraxacum officinale', 'Taraxacum',
   'https://example.com/img/dandelion_ref.jpg');

-- Store species IDs in variables for convenience
SELECT @sunflower_id := species_id
FROM plant_species
WHERE scientific_name = 'Helianthus annuus';

SELECT @oak_id := species_id
FROM plant_species
WHERE scientific_name = 'Quercus robur';

SELECT @dandelion_id := species_id
FROM plant_species
WHERE scientific_name = 'Taraxacum officinale';

-- ============================================================
-- 4) User uploads a photo for identification
-- ============================================================

INSERT INTO identification_submission (img_url, user_id)
VALUES ('https://example.com/uploads/user_photo_001.jpg', @user_id);

SET @identification_id := LAST_INSERT_ID();

-- ============================================================
-- 5) Model returns top-N predictions (options)
--    Assume the model predicts:
--      Rank 1: Sunflower
--      Rank 2: Dandelion
--      Rank 3: Oak
-- ============================================================

-- Rank 1 option
INSERT INTO identification_option (identification_id, species_id, option_rank)
VALUES (@identification_id, @sunflower_id, 1);

SET @best_option_id := LAST_INSERT_ID();  -- model's top-ranked option

-- Rank 2 option
INSERT INTO identification_option (identification_id, species_id, option_rank)
VALUES (@identification_id, @dandelion_id, 2);

-- Rank 3 option
INSERT INTO identification_option (identification_id, species_id, option_rank)
VALUES (@identification_id, @oak_id, 3);

-- ============================================================
-- 6) Store the chosen result
--    (accept the model's best-ranked option for now)
-- ============================================================

INSERT INTO identification_result (identification_id, option_id, user_id)
VALUES (@identification_id, @best_option_id, @user_id);

-- ============================================================
-- 7) User reports an incorrect identification
--    Correct species is Oak; incorrect prediction was Sunflower (also the chosen result)
--    Note: incorrect_species_id must align with identification_result via the FK.
-- ============================================================

-- INSERT INTO incorrect_identification (
--     identification_id,
--     correct_species_id,
--     incorrect_species_id,
--     time_submitted
-- )
-- VALUES (
--     @identification_id,
--     @oak_id,
--     @sunflower_id,
--     NOW()
-- );

-- ============================================================
-- 8) Verification queries
-- ============================================================

-- N-best list for the submission
SELECT s.identification_id,
       s.img_url AS submitted_image,
       u.email   AS submitted_by,
       o.option_id,
       o.option_rank,
       ps.common_name,
       ps.scientific_name
FROM identification_submission s
JOIN user u
  ON s.user_id = u.user_id
JOIN identification_option o
  ON s.identification_id = o.identification_id
JOIN plant_species ps
  ON o.species_id = ps.species_id
WHERE s.identification_id = @identification_id
ORDER BY o.option_rank;

-- Final chosen result
SELECT r.identification_id,
       s.img_url AS submitted_image,
       u.email   AS chosen_by,
       o.option_id,
       o.option_rank,
       ps.common_name,
       ps.scientific_name
FROM identification_result r
JOIN identification_submission s
  ON r.identification_id = s.identification_id
JOIN user u
  ON r.user_id = u.user_id
JOIN identification_option o
  ON r.option_id = o.option_id
JOIN plant_species ps
  ON o.species_id = ps.species_id
WHERE r.identification_id = @identification_id;

-- Incorrect identification report
SELECT ii.identification_id,
       ps_correct.common_name   AS correct_common_name,
       ps_incorrect.common_name AS incorrect_common_name,
       ii.time_submitted
FROM incorrect_identification ii
JOIN plant_species ps_correct
  ON ii.correct_species_id = ps_correct.species_id
JOIN plant_species ps_incorrect
  ON ii.incorrect_species_id = ps_incorrect.species_id
WHERE ii.identification_id = @identification_id;
