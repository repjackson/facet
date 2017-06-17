if Meteor.isClient
    FlowRouter.route '/goldrun', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            main: 'goldrun'
     
    Template.goldrun.onCreated ->
        @autorun -> Meteor.subscribe 'members'
    
    
    Template.goldrun.helpers
        members: -> 
            Meteor.users.find {}
            
