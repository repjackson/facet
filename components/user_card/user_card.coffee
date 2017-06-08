
if Meteor.isClient
    Template.user_card.onCreated ->
        @autorun -> 
            Meteor.subscribe('person_card', Template.currentData().author_id)
    
    Template.user_card.helpers
        person: -> 
            Meteor.users.findOne( _id: Template.currentData().author_id )
