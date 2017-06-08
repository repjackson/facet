if Meteor.isClient
    Template.tag_rating.onCreated ->
        @autorun => Meteor.subscribe('article_tags', @data._id)
    
    Template.tag_rating.helpers
        ratings: ->
            Docs.find
                type: 'tag_rating'
                parent_id: @_id
        
        person: -> Meteor.users.findOne username:FlowRouter.getParam('username') 

        my_rating: ->
            # console.log @
            my_rating = Docs.findOne 
                type: 'tag_rating'
                parent_id: @_id 
            # if my_rating then console.log my_rating
            my_rating

    Template.tag_rating.events
        'click #add_rating': ->
            new_rating_id = Docs.insert 
                type: 'tag_rating'
                parent_id: @_id 
            Session.set 'editing_id', new_rating_id    



if Meteor.isServer
    Meteor.publish 'article_tags', (doc_id)->
        Docs.find
            type: 'tag_rating'
            parent_id: doc_id