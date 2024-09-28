db.credits.aggregate([
    {
        $unwind: "$cast"
    },
    {
        $match: {"cast.id": 7624}
    },
    {
        $lookup: {
            from: "movies_metadata",
            localField: "movieId",
            foreignField: "movieId",
            as: "movie"
        }
    },
    {
        $unwind: "$movie"
    },
    {
        $sort: {"movie.release_date": -1}
    },
    {
        $project: {
            "title": "$movie.title",
            "release_date": "$movie.release_date",
            "character": "$cast.character",
            "_id": 0
        }
    }
]);
