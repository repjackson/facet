@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@People_tags = new Meteor.Collection 'people_tags'


Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    doc.tag_count = doc.tags?.length
    doc.points = 0
    doc.upvoters = []
    doc.downvoters = []
    doc.published = false
    return


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
