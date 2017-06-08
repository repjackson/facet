publishComposite 'docs', (selected_tags, editing_id)->
    {
        find: ->
            if editing_id
                Docs.find editing_id
            else
                self = @
                match = {}
                match.tags = $all: selected_tags
                Docs.find match,
                    sort: tag_count: 1
                    limit: 5
        children: [
            find: (doc)->
                Meteor.users.find
                    _id: doc.author_id
            ]
        
    }
                    
publishComposite 'doc', (id)->
    {
        find: ->
            Docs.find id
        children: [
            find: (doc)->
                Meteor.users.find
                    _id: doc.author_id
            ]
    }



Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
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



Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        # if userId and doc._id == userId
        #     # console.log 'user allowed to modify own account'
        #     true

# Kadira.connect('Dmhg2hdSobHy3fXWE', '940bb181-70ce-42c4-a557-77696e5da41d')



Meteor.publish 'userStatus', ->
    Meteor.users.find { 'status.online': true }, 
        fields: 
            points: 1
            tags: 1
            
            
            
Meteor.publish 'user_status_notification', ->
    Meteor.users.find('status.online': true).observe
        added: (id) ->
            console.log "#{id} just logged in"
        removed: (id) ->
            console.log "#{id} just logged out"


Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


if Meteor.isDevelopment
    secret_key = Meteor.settings.private.stripe.testSecretKey
    # console.log 'using test secret key'
else if Meteor.isProduction
    secret_key = Meteor.settings.private.stripe.liveSecretKey
else 
    console.log 'not dev or prod'

Stripe = StripeAPI(secret_key)
Meteor.methods
    processPayment: (charge) ->
        handleCharge = Meteor.wrapAsync(Stripe.charges.create, Stripe.charges)
        payment = handleCharge(charge)
        # console.log payment
        payment



Accounts.onCreateUser (options, user) ->
    return user

# AccountsMeld.configure
#     askBeforeMeld: false
#     # meldDBCallback: meldDBCallback
#     # serviceAddedCallback: serviceAddedCallback


Docs.allow
    insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId
    update: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId
    remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId

