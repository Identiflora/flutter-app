# flutter-app
The flutter implementation for Identiflora.

# GBIF Data Formatting Script

This script prepares a subset of the GBIF / Pl@ntNet dataset for model training. It:

1. Reads **`occurrence.txt`** and **`multimedia.txt`** from the GBIF Darwin Core Archive.
2. Merges them on **`gbifID`** to attach scientific names to each image.
3. Filters out non-image or invalid records.
4. Selects species such that:
   - Every selected species has **at least 3 images**.
   - The **total number of images** never exceeds a user-specified limit.
5. Splits images into **train / validation / test**, ensuring:
   - All three splits contain the **same set of species**.
   - Each species appears **at least once** in each split.
   - The number of images per species may vary between splits.
6. Downloads the images into a folder structure compatible with `torchvision.datasets.ImageFolder`.

## Requirements

### Python

- Tested on Python 3.10.5.

### Dependencies

- pandas version 2.3.3
- requests version 2.32.5

Dependencies can be installed locally by running the following command:

  ```pip install -r requirements.txt```

## Running the script

To run the script, run the following command:

```
python .\Model\data_formatting\format_gbif_data.py 
  --dwca_dir "\path_to_dataset_dir"
  --output_dir "\path_to_desired_output_location" 
  --max_images 500 
  --max_multimedia_rows 500 
  --max_occurence_rows 500
```

where dwca_dir is the path to the directory containing the GBIF dataset, and output_dir is the desired output location of the image folder.

# Database Documentation
Below is all necessary information regarding the database design, implementation and use. All database testing has been done with MySQL Server 8.0.44

### Notes
- The database will need to be hosted on someone's machine for the application to work properly. Doing this for the demo only should be sufficient for this semester. 

### Running database instructions
1. Download MySQL from here: https://dev.mysql.com/downloads/file/?id=546163, make sure you're downloading MySQL 8.0.44.0
2. Follow the installer setup
3. Run this command in terminal to connect to the server: '& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p' (If you installed MySQL in a different location, use your path to mysql.exe)
4. To build the database on your machine, run: 'SOURCE initialize_database.sql;'
5. The above format can be used to run any .sql file from the mysql terminal.

## Tables
### plant_species
One entry exists for each plant the model is able to identify.

- **species_id**
  - **Datatype -** int
  - **Description -** auto-incrementing primary key identifier.
- **common_name**
  - **Datatype -** varchar(255)
  - **Description -** common name of the plant.
- **scientific_name**
  - **Datatype -** varchar(255)
  - **Description -** scientific (Latin) species name of the plant.
- **genus**
  - **Datatype -** varchar(255)
  - **Description -** genus to which the plant belongs.
- **img_url**
  - **Datatype -** varchar(512)
  - **Description -** URL to an example reference image of the plant.

---

### identification_submission
Entry is created when a user submits a photo for identification. 

- **identification_id**
  - **Datatype -** int
  - **Description -** auto-incrementing primary key identifier.
- **img_url**
  - **Datatype -** varchar(512)
  - **Description -** URL to the image the user submitted. 
- **user_id**
  - **Datatype -** int
  - **Description -** references the PK identifier of the user that submitted the photo. 
- **time_submitted**
  - **Datatype -** timestamp
  - **Description -** time when the entry was added to the database. 

---

### identification_option
Specifies one possible species option for an identification submission. Each submission may have up to five ranked options.

- **option_id**
  - **Datatype -** int
  - **Description -** auto-incrementing primary key identifier for an option.
- **identification_id**
  - **Datatype -** int
  - **Description -** Foreign key, references the submission this option belongs to.
- **species_id**
  - **Datatype -** int
  - **Description -** Foreign key, references the plant species associated with this option.
- **rank**
  - **Datatype -** int
  - **Description -** position of this option within the N-best list (1-5), ensuring each rank is unique per submission.

**Additional Constraints**
- Each option for a submission must have a unique **rank**.  
- Each option for a submission must reference a unique **species**.  
- Cascading deletes ensure options are removed when their submission or species is deleted.

---

### identification_result
Stores the final chosen result (best-ranked) for an identification submission. Each submission may have at most one result.

- **identification_id**
  - **Datatype -** int
  - **Description -** primary key, foreign key referencing the submission. Guarantees one result per submission.
- **option_id**
  - **Datatype -** int
  - **Description -** references the selected option that was chosen for final result.

**Additional Constraints**
- Ensures the chosen option belongs to the same submission by enforcing the composite foreign key **(identification_id, option_id)**. This ensures that the option_id references an option that is associated with the correct submission.
- Cascading deletes ensure results are removed automatically if the associated submission or option is deleted.

---

### incorrect_identification
Stores a user-reported incorrect prediction for a submission.

- **identification_id**
  - **Datatype -** int
  - **Description -** primary key; FK to identification_submission.
- **correct_species_id**
  - **Datatype -** int
  - **Description -** FK to plant_species (true species).
- **incorrect_species_id**
  - **Datatype -** int
  - **Description -** FK to plant_species (model-predicted species).
- **time_submitted**
  - **Datatype -** timestamp
  - **Description -** time when the incorrect report was added.

**Additional Constraints**
- Composite FK **(identification_id, incorrect_species_id)** must match an option in **identification_option** (ensures the reported incorrect species was one of the model's options for that submission).
- Cascading deletes clean up rows if submissions or species are removed.

## Database API (FastAPI)
The Python API in `Database/api/database_api.py` exposes a minimal endpoint to record incorrect identifications in MySQL.

### Requirements
- Python 3.10+
- Install dependencies: `pip install -r requirements.txt`
- Running MySQL instance with the schema from `Database/schema/initialize_database.sql`

### Configuration
Connection settings are read from environment variables (defaults in parentheses):
- `DB_HOST` (`localhost`)
- `DB_PORT` (`3306`)
- `DB_USER` (`root`)
- `DB_PASSWORD` (from `Database/api/database_password.txt` if not set)
- `DB_NAME` (`identiflora_testing_db`)
- `PORT` (`8000`, only for the dev server in `__main__`)

### Run locally
Start the API (from repo root):
```
uvicorn Database.api.database_api:app --host localhost --port 8000
```
or run the file directly, change the global variable HOST to desired host: `python Database/api/database_api.py`

### Endpoint: Report incorrect identification
- **Method/Path**: `POST /incorrect-identifications`
- **Purpose**: Record that a specific identification submission was wrong, linking the correct and incorrect species.
- **Request body** (`application/json`):
  ```
  {
    "identification_id": 1,
    "correct_species_id": 2,
    "incorrect_species_id": 3
  }
  ```
  - `identification_id`: Must already exist in `identification_submission`.
  - `correct_species_id` / `incorrect_species_id`: Must exist in `plant_species` and cannot be equal.
  - `incorrect_species_id` must also exist as an option in `identification_option` for that `identification_id` (composite FK).
- **Behavior**:
  - Validates referenced submission and species; ensures the incorrect species is one of the submission's options.
  - Inserts into `incorrect_identification` with `time_submitted = NOW()`; image URLs are available via joins if needed.
- **Responses** (examples):
  - `200 OK`:
    ```
    {
      "identification_id": 1,
      "correct_species_id": 2,
      "incorrect_species_id": 3,
      "message": "Incorrect identification recorded."
    }
    ```
  - `404 Not Found`: Missing submission or species rows.
  - `400 Bad Request`: Correct/incorrect species are the same, or required image URLs are missing.
  - `409 Conflict`: An incorrect identification already exists for this submission.
  - `500 Internal Server Error`: Database/connectivity issues.

### Testing script
`Database/testing/database_testing.sql` seeds `identiflora_testing_db` with example data and exercises the full flow, including the new incorrect_identification FKs. You can run it after initializing the schema to verify constraints and sample inserts.

## File Guide

- `Database/schema/initialize_database.sql`
  - Creates the full schema (users, submissions, options, results, incorrect_identification).
  - Key notes: `img_url` columns are 512 chars; composite FK ensures `incorrect_species_id` is one of the submission’s options; cascading deletes clean up children.
  - Usage: Run via MySQL `SOURCE Database/schema/initialize_database.sql;` to create the database. To reset for a fresh testing canvas, run DROP DATABASE `identiflora_testing_db;`.

- `Database/testing/database_testing.sql`
  - Seeds `identiflora_testing_db` with a sample user, species, submission, options, chosen result, and an incorrect_identification row.
  - Key notes: Assumes the schema is initialized; verifies constraints with select queries.
  - Usage: `SOURCE Database/testing/database_testing.sql;` after initializing the DB to populate test data.

- `Database/api/database_api_helpers.py`
  - SQLAlchemy helper module: builds the engine, defines the request model, validates IDs, and inserts into `incorrect_identification`.
  - Key notes: Uses `mysql+pymysql` connection string; URL-encodes credentials; transaction via `engine.begin()`; only writes IDs and timestamp (URLs of images can be retrieved via joins if needed).
  - Usage: Imported by database_api.py. Should not be run directly. 

- `Database/api/database_api.py`
  - FastAPI entrypoint wiring the `/incorrect-identifications` POST route to the helper logic.
  - Key notes: Instantiates the engine; minimal code beyond app setup and route handler.
  - Usage: Run with `uvicorn Database.api.database_api:app --host 0.0.0.0 --port 8000` (or `python Database/api/database_api.py`).

- `Database/api/database_api_testing.dart`
  - Simple testing script for accessing the API with Dart.
  - Key notes: Only tests submitting an incorrect identification.
  - Usage: Change global variables for parameters of incorrect_identification for testing, then run the file.

- `lib/database_utils.dart`
  - Dart helper function `submitIncorrectIdentification` to call the API from Flutter.
  - Key notes: Uses `HttpClient` to POST JSON; accepts `identificationId`, `correctSpeciesId`, `incorrectSpeciesId`, optional `apiBaseUrl`; returns `true` on 2xx else throws. Add this to button handlers or other app logic.
  - Usage: Call directly in UI code, e.g., `onPressed: () => submitIncorrectIdentification(identificationId: 1, correctSpeciesId: 2, incorrectSpeciesId: 3);`
