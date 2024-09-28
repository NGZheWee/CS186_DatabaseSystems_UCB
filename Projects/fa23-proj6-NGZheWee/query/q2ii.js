// Task 2ii
db.movies_metadata.aggregate([
    // TODO: Write your query here
    {
        $project: {
            "tagwords": {
                $split: [
                    "$tagline", ' ',
                ]
            }
        }
    },
    {
        $unwind: "$tagwords",
    },
    {
        $group: {
            _id: {
                $trim: {
                    input:{
                        $toLower: "$tagwords",
                    }, 
                    chars:" .,?!",
                }
            }, "count": {
                $sum: 1,
            }
        }
    },
    {
        $project: {
            "_id": 1, 
            "count":1, 
            "len":{
                $strLenCP:"$_id",
            }
        }
    },
    {
        $match: {
            len:{
                $gt:3,
            }
        }
    },
    {
        $sort:{
            count: -1,
        }
    },
    {
        $limit:20,
    },
    {
        $project: {
            "_id": 1, 
            "count":1,
        }
    }
]);