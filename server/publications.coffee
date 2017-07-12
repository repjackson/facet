Meteor.publish 'userStatus', ->
    Meteor.users.find { 'status.online': true }, 
        fields: 
            points: 1
            tags: 1
            
            
            
# Meteor.publish 'user_status_notification', ->
#     Meteor.users.find('status.online': true).observe
#         added: (id) ->
#             console.log "#{id} just logged in"
#         removed: (id) ->
#             console.log "#{id} just logged out"

Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}

    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 42 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()


publishComposite 'docs', (selected_tags)->
    {
        find: ->
            # if editing_id
            #     Docs.find editing_id
            # else
            self = @
            match = {}

            # if selected_tags.length > 0 then match.tags = $all: selected_tags
            match.tags = $all: selected_tags
            if limit
                Docs.find match, 
                    limit: limit
            else
                Docs.find match,
                    sort: tag_count: 1
                    limit: 5
                
                
    }
                    
publishComposite 'doc', (id)->
    {
        find: ->
            Docs.find id
        children: [
            {
                find: (doc)->
                    Meteor.users.find
                        _id: doc.author_id
            }
            {
                find: (doc)->
                    if doc.attached_users
                        Meteor.users.find
                            _id: $in: doc.attached_users
            }
        ]
    }


Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields: 
            courses: 1
            friends: 1
            points: 1
            status: 1
            cart: 1
            completed_ids: 1
            bookmarked_ids: 1
    