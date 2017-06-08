if Meteor.isClient
    Template.tag_person.onCreated ->
        @autorun => Meteor.subscribe('person_tags', @data._id)
        @autorun -> Meteor.subscribe('user_profile', FlowRouter.getParam('username'))

    Template.tag_person.helpers
        ratings: ->
            Docs.find
                type: 'tag_person'
                parent_id: @_id
    
        my_rating: ->
            # console.log @
            my_rating = Docs.findOne 
                type: 'tag_person'
                parent_id: @_id 
            # if my_rating then console.log my_rating
            my_rating

    Template.tag_person.events
        'click #add_person_tags': ->
            new_person_tags_id = Docs.insert 
                type: 'tag_person'
                parent_id: @_id 
            Session.set 'editing_id', new_person_tags_id    



if Meteor.isServer
    Meteor.publish 'person_tags', (doc_id)->
        Docs.find
            type: 'tag_person'
            parent_id: doc_id