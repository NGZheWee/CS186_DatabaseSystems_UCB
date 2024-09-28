db.credits.aggregate([
    {
        $unwind: "$crew",
    },
    {
        $match: {
            "crew.id": 5655,
            "crew.job": "Director",
        }
    },
    {
        $unwind: "$cast",
    },
    {
        $group: {
            _id: "$cast.id",
            name: { $first: "$cast.name", },
            count: { $sum: 1, }
        }
    },
    {
        $sort: { count: -1, _id: 1, }
    },
    {
        $limit: 5,
    },
    {
        $project: {
            _id: 0,
            id: "$_id",
            name: 1,
            count: 1,
        }
    }
]);
