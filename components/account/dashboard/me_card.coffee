if Meteor.isClient
    Template.me_card.onCreated ->
        @autorun -> 
            Meteor.subscribe('me_card')
    
    Template.me_card.helpers
        me: -> 
            Meteor.user()
