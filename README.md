# flutter-app
The flutter implementation for Identiflora.

# Environment

The environment class (in lib/environment.dart) is setup to allow easy swapping between local development and cloud testing. There are just a couple of things to complete locally to set it up. 

1. Create 2 files with the following names: 
    - `.env.production` (for cloud testing)
    - `.env.development` (for local development)
2. IMPORTANT: Double check that both of these files are present in .gitignore. 
3. Use the environment variable names from `.env.example` to populate both files. 
4. It is setup so that if you build in debug mode, it will use `.env.development`, and if you run in release mode it will use `.env.production`. To run in release mode, use 

    ```flutter run --release```

## Usage:

If you need to add a new environment variable for any reason, you must add it to all of the `.env` files, and add a get method for it in the Environment class. 

Once a get method is implemented, environment variables can be accessed using Environment.exampleVariable. 



# BELOW INFORMATION IS OUTDATED AND NEEDS TO BE MOVED

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




