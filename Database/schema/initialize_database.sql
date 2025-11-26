CREATE DATABASE IF NOT EXISTS identiflora_testing_db;

USE identiflora_testing_db;

CREATE TABLE user (
  user_id int
    AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  password_hash varchar(255) NOT NULL,
  phone varchar(255),
  time_joined timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id),
  UNIQUE (email),
  UNIQUE (phone)
);

-- created when photo is submitted from user
CREATE TABLE identification_submission (
  identification_id int 
    AUTO_INCREMENT,
  img_url varchar(512) NOT NULL,
  user_id int, 
  time_submitted timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (identification_id),
  FOREIGN KEY (user_id)
    REFERENCES user(user_id)
    ON DELETE CASCADE
);

-- each plant species the model is capable of identifying
CREATE TABLE plant_species (
  species_id int
    AUTO_INCREMENT,
  common_name varchar(255) NOT NULL,
  scientific_name varchar(255) NOT NULL,
  genus varchar(255),
  img_url varchar(512) NOT NULL,

  PRIMARY KEY (species_id),
  UNIQUE (img_url)
);

-- specifies a unique option for the result of identification
CREATE TABLE identification_option (
  option_id int 
    AUTO_INCREMENT,
  identification_id int NOT NULL,
  species_id int NOT NULL,
  option_rank tinyint UNSIGNED NOT NULL,

  PRIMARY KEY (option_id),

  FOREIGN KEY (identification_id)
   REFERENCES identification_submission(identification_id)
   ON DELETE CASCADE,

  FOREIGN KEY (species_id)
   REFERENCES plant_species(species_id)
   ON DELETE CASCADE,

  UNIQUE (identification_id, option_rank),-- make sure each option for a certain submission has a unique rank
  UNIQUE (identification_id, species_id),-- make sure each option for a certain submission has a unique species
  INDEX (identification_id, option_id)
);

-- contains identification options
CREATE TABLE identification_result (
  identification_id int,
  option_id int NOT NULL,
  user_id int NOT NULL,

  PRIMARY KEY (identification_id),-- guarantees at most 1 result per submission

  FOREIGN KEY (identification_id) 
    REFERENCES identification_submission(identification_id)  
    ON DELETE CASCADE,

  FOREIGN KEY (identification_id, option_id)
   REFERENCES identification_option(identification_id, option_id)-- make sure result shows an option that is associated with the correct submission
   ON DELETE CASCADE,

  FOREIGN KEY (user_id) 
    REFERENCES user(user_id)
    ON DELETE CASCADE
);

CREATE TABLE incorrect_identification (
  identification_id int,
  correct_species_id int,
  incorrect_species_id int,
  time_submitted timestamp,

  PRIMARY KEY (identification_id),

  -- make sure the incorrect species_id comes from the right source
  FOREIGN KEY (identification_id, incorrect_species_id)
    REFERENCES identification_option(identification_id, species_id)-- may eventually want to change this so it pull id_id from result
    ON DELETE CASCADE,

  FOREIGN KEY (identification_id)
    REFERENCES identification_submission(identification_id)
    ON DELETE CASCADE,

  FOREIGN KEY (correct_species_id)
    REFERENCES plant_species(species_id)
    ON DELETE CASCADE,

  FOREIGN KEY (incorrect_species_id)
    REFERENCES plant_species(species_id)
    ON DELETE CASCADE
);

-- Stored procedures and functions
delimiter //

CREATE PROCEDURE check_ident_id_exists (IN ident_id_in int)
  BEGIN
    SELECT identification_id FROM identification_submission
    WHERE identification_id = ident_id_in;
  END//

CREATE PROCEDURE check_species_id_exists (IN species_id_in int)
  BEGIN
    SELECT species_id FROM plant_species
    WHERE species_id = species_id_in;
  END//

CREATE PROCEDURE check_incorrect_sub_exists (IN ident_id_in int)
  BEGIN
    SELECT identification_id FROM incorrect_identification
    WHERE identification_id = ident_id_in;
  END//

CREATE PROCEDURE add_incorrect_id (IN ident_id_in int, IN correct_species_id_in int, IN inc_species_id_in int)
  BEGIN
    INSERT INTO incorrect_identification
      (identification_id, correct_species_id, incorrect_species_id, time_submitted)
      VALUES (ident_id_in, correct_species_id_in, inc_species_id_in, NOW());
  END//

delimiter ;

