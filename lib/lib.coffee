@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Numbers = new Meteor.Collection 'numbers'
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



# Meteor.methods
#     vote_up: (id)->
#         doc = Docs.findOne id
#         if not doc.upvoters
#             Docs.update id,
#                 $set: 
#                     upvoters: []
#                     downvoters: []
#         else if Meteor.userId() in doc.upvoters #undo upvote
#             Docs.update id,
#                 $pull: upvoters: Meteor.userId()
#                 $inc: points: -1
#             Meteor.users.update doc.author_id, $inc: points: -1
#             Meteor.users.update Meteor.userId(), $inc: points: 1

#         else if Meteor.userId() in doc.downvoters #switch downvote to upvote
#             Docs.update id,
#                 $pull: downvoters: Meteor.userId()
#                 $addToSet: upvoters: Meteor.userId()
#                 $inc: points: 2
#             Meteor.users.update doc.author_id, $inc: points: 2
#             Meteor.users.update Meteor.userId(), $inc: points: -2

#         else #clean upvote
#             Docs.update id,
#                 $addToSet: upvoters: Meteor.userId()
#                 $inc: points: 1
#             Meteor.users.update doc.author_id, $inc: points: 1
#             Meteor.users.update Meteor.userId(), $inc: points: -1
#         Meteor.call 'generate_upvoted_cloud', Meteor.userId()


#     vote_down: (id)->
#         doc = Docs.findOne id
#         if not doc.downvoters
#             Docs.update id,
#                 $set: 
#                     upvoters: []
#                     downvoters: []
#         else if Meteor.userId() in doc.downvoters #undo downvote
#             Docs.update id,
#                 $pull: downvoters: Meteor.userId()
#                 $inc: points: 1
#             Meteor.users.update doc.author_id, $inc: points: 1
#             Meteor.users.update Meteor.userId(), $inc: points: 1

#         else if Meteor.userId() in doc.upvoters #switch upvote to downvote
#             Docs.update id,
#                 $pull: upvoters: Meteor.userId()
#                 $addToSet: downvoters: Meteor.userId()
#                 $inc: points: -2
#             Meteor.users.update doc.author_id, $inc: points: -2
#             Meteor.users.update Meteor.userId(), $inc: points: 2

#         else #clean downvote
#             Docs.update id,
#                 $addToSet: downvoters: Meteor.userId()
#                 $inc: points: -1
#             Meteor.users.update doc.author_id, $inc: points: -1
#             Meteor.users.update Meteor.userId(), $inc: points: -1
#         Meteor.call 'generate_downvoted_cloud', Meteor.userId()

