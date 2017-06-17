





Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        # if userId and doc._id == userId
        #     # console.log 'user allowed to modify own account'
        #     true

# Kadira.connect('Dmhg2hdSobHy3fXWE', '940bb181-70ce-42c4-a557-77696e5da41d')




Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


# if Meteor.isDevelopment
#     secret_key = Meteor.settings.private.stripe.testSecretKey
#     # console.log 'using test secret key'
# else if Meteor.isProduction
#     secret_key = Meteor.settings.private.stripe.liveSecretKey
# else 
#     console.log 'not dev or prod'


Accounts.onCreateUser (options, user) ->
    user.points = 0
    return user

# AccountsMeld.configure
#     askBeforeMeld: false
#     # meldDBCallback: meldDBCallback
#     # serviceAddedCallback: serviceAddedCallback


Docs.allow
    insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId
    update: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId
    remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin') or doc.author_id is userId

