// Task 1i

db.keywords.aggregate([
    {
        $match: {
            "keywords": {
                $elemMatch: {
                    $or: [
                        {"name": "marvel comic"},
                        {"name": "mickey mouse"},
                    ]
                }
            }
        }
    },
    {
        $sort: {"movieId": 1},
    },
    {
        $project: {"_id": 0, "movieId": 1, },
    }
]);