Template.nav.events
    'click #logout': -> AccountsTemplates.logout()
    
    'click #add_doc': ->
        Meteor.call 'add', (err,id)->
            FlowRouter.go "/edit/#{id}"
