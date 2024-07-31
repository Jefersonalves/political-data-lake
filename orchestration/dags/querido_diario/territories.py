import json


def fetch_target_territories(date: str):
    territory_list = ["2704302", "1302603", "1600303", "1721000"]
    data = [
        json.dumps(
            {
                "date": date,
                "territory_id": territory,
                "bucket_name": "political-datalake-raw",
            }
        )
        for territory in territory_list
    ]
    return data
