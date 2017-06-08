Meteor.methods 
    enroll: (slug)->
        Meteor.users.update Meteor.userId(),
            $addToSet: courses: slug
            
            
    generate_upvoted_cloud: ->
        match = {}
        match.upvoters = $in: [Meteor.userId()]
        match.type = 'facet'

        
        upvoted_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvoted_list = (tag.name for tag in upvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvoted_cloud: upvoted_cloud
                upvoted_list: upvoted_list



    generate_downvoted_cloud: ->
        match = {}
        match.downvoters = $in: [Meteor.userId()]
        match.type = 'facet'
        downvoted_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list
            
            
            
    add_doc: (body, parent_id, tags) ->
        result = Docs.insert
            body: body
            parent_id: parent_id
            tags: tags
        console.log result
                