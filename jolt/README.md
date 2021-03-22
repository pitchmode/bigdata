===
Drop Null

Input:
[
  {
    "refinery_id": "5682",
    "sign": null,
    "unique_id": null,
    "order_id": "328899",
    "sync_timestamp": "2021-03-22 15:39:45"
  },
  {
    "refinery_id": "5683",
    "sign": null,
    "unique_id": null,
    "order_id": "328900",
    "sync_timestamp": "2021-03-22 15:39:45"
  },
]


Transform:
[
  {
    "operation": "modify-overwrite-beta",
    "spec": {
      "*": "=recursivelySquashNulls"
    }
}
]

Output:
[
  {
    "refinery_id": "5682",
    "order_id": "328899",
    "sync_timestamp": "2021-03-22 15:39:45"
  },
  {
    "refinery_id": "5683",
    "order_id": "328900",
    "sync_timestamp": "2021-03-22 15:39:45"
  },
]
