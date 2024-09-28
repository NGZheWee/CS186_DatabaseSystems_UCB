// Task 2iii

db.movies_metadata.aggregate([
    {
        $project: {
            "budget": {
                $cond: {
                    if: {
                        $and: [
                            {$ne: ["$budget", false]},
                            {$ne: ["$budget", null]},
                            {$ne: ["$budget", ""]},
                            {$ne: ["$budget", undefined]}
                        ]
                    },
                    then: {
                        $cond: {
                            if: {$or: [{$isNumber: "$budget"}, {$eq: ["$budget", "unknown"]}]},
                            then: "$budget",
                            else: {$toInt: {$trim: {input: "$budget", chars: " USD$"}}}
                        }
                    },
                    else: "unknown"
                }
            }
        }
    },
    {
        $set: {
            "budget": {
                $cond: {
                    if: {$isNumber: "$budget"},
                    then: {$round: ["$budget", -7]},
                    else: "$budget"
                }
            }
        }
    },
    {
        $group: {
            "_id": "$budget",
            "count": {$sum: 1}
        }
    },
    {
        $sort: {_id: 1}
    },
    {
        $project: {
            "budget": "$_id",
            "count": 1,
            "_id": 0
        }
    }
]);
