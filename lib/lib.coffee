@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
            timestamp: Date.now()
            author_id: Meteor.userId()

        return id
