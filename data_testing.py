
import pandas as pd
import os

data_file_path = 'GBIF_Data'

import requests, itertools

#determine how many classes in dataset
# DATASET = "7a3679ef-5582-4aaa-81f0-8c2545cafc81"
# FACET = "speciesKey"
# LIMIT = 1000

# seen = set()
# for offset in itertools.count(0, LIMIT):
#     url = ("https://api.gbif.org/v1/occurrence/search"
#            f"?datasetKey={DATASET}&limit=0&facet={FACET}"
#            f"&facetLimit={LIMIT}&facetOffset={offset}")
#     r = requests.get(url, timeout=30)
#     r.raise_for_status()
#     data = r.json()
#     facets = data.get("facets", [])
#     if not facets or not facets[0].get("counts"):
#         break
#     for b in facets[0]["counts"]:
#         # b['name'] is the speciesKey as string
#         seen.add(b["name"])
# print("Distinct species (by speciesKey):", len(seen))

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

# print("occurence first row:")
# # print(occ_1.to_dict(orient="records")[0])
# row_0_o = occ_1.iloc[0]
# for key, value in row_0_o.items():
#     if not pd.isna(value):
#         print(f"{key}: {value}")
# print()
# print("\nmultimedia first row:")
# row_0_m = mm_1.iloc[0]
# for key, value in row_0_m.items():
#     if not pd.isna(value):
#         print(f"{key}: {value}")

# print()
print("\nJoined first row")
row_0_j = joined.iloc[0]
for key, value in row_0_j.items():
    if not pd.isna(value):
        print(f"{key}: {value}")
