
import pandas as pd
import os

data_file_path = 'GBIF_Data'

occ_1 = pd.read_csv(os.path.join(data_file_path, "occurrence.txt"), sep="\t", nrows=100, dtype=str, low_memory=False, usecols=['gbifID', 
                                                                                                                               'license', 
                                                                                                                               'scientificName', 
                                                                                                                               'family',
                                                                                                                               'genus',
                                                                                                                               'genericName',
                                                                                                                               'datasetKey',
                                                                                                                               'mediaType',
                                                                                                                               ])
mm_1  = pd.read_csv(os.path.join(data_file_path, "multimedia.txt"), sep="\t", nrows=100, dtype=str, low_memory=False, usecols=['gbifID',
                                                                                                                               'type',
                                                                                                                               'format',
                                                                                                                               'identifier',
                                                                                                                               'title',
                                                                                                                               'source'
                                                                                                                               ])

joined = pd.merge(mm_1, occ_1, left_on='gbifID', right_on='gbifID', how='inner')

print("occurence first row:")
# print(occ_1.to_dict(orient="records")[0])
row_0_o = occ_1.iloc[0]
for key, value in row_0_o.items():
    if not pd.isna(value):
        print(f"{key}: {value}")
print()
print("\nmultimedia first row:")
row_0_m = mm_1.iloc[0]
for key, value in row_0_m.items():
    if not pd.isna(value):
        print(f"{key}: {value}")

print()
print("\nJoined first row")
row_0_j = joined.iloc[0]
for key, value in row_0_j.items():
    if not pd.isna(value):
        print(f"{key}: {value}")
