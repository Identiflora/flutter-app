--created when photo is submitted from user
CREATE TABLE identification_submission (
  identification_id int PRIMARY KEY,
  img_url varchar(255),
  user_id int, --will reference user_id's once implemented
  time_submitted timestamp
);

--each plant species the model is capable of identifying
CREATE TABLE plant_species (
  species_id int PRIMARY KEY,
  common_name varchar(255),
  genus varchar(255),
  img_url varchar(255)
);

--specifies a unique option for the result of identification
CREATE TABLE identification_option (
  option_id int PRIMARY KEY,
  identification_id int NOT NULL FOREIGN KEY 
    UNIQUE
    REFERENCES identification_submission(identification_id)
    ON DELETE CASCADE,
  species_id int NOT NULL FOREIGN KEY
    UNIQUE
    REFERENCES plant_species(species_id)
    ON DELETE CASCADE,
  rank int UNIQUE
    CHECK (rank BETWEEN 1 AND 5)--assuming we give 4 alternative options. Can change later if needed
);

--contains identification options
CREATE TABLE identification_result (
  identification_id int PRIMARY KEY 
    REFERENCES identification_submission(identification_id)
    ON DELETE CASCADE,
  option_id int NOT NULL FOREIGN KEY 
    REFERENCES identification_option(option_id)
    ON DELETE CASCADE
);

-- INSERT INTO identification_submission(identification_id)
--   VALUES