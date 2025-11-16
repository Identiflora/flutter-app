CREATE DATABASE IF NOT EXISTS identiflora_db;

USE identiflora_db;

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

  PRIMARY KEY (species_id)  
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
