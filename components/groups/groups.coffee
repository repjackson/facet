if Meteor.isClient
    FlowRouter.route '/groups', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            main: 'groups'
     
    Template.groups.onCreated ->
        @autorun -> Meteor.subscribe 'members'
    
    
    Template.groups.helpers
        members: -> 
            Meteor.users.find {}
            
