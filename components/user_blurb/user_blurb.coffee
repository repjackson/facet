if Meteor.isClient
    Template.user_blurb.onCreated ->
        @autorun -> 
            Meteor.subscribe('person', Template.currentData().author_id)
    
    Template.user_blurb.helpers
        person: -> 
            Meteor.users.findOne( _id: Template.currentData().author_id )
    
