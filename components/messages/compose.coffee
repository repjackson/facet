if Meteor.isClient
    FlowRouter.route '/compose', 
        name: 'compose_message'
        action: (params) ->
            BlazeLayout.render 'layout',
                main: 'compose'

    Template.compose.onCreated ->
        @autorun -> Meteor.subscribe('usernames')
        
    Template.compose.helpers
        compose_settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Meteor.users
                    field: 'username'
                    matchAll: false
                    template: Template.user_pill
                }
                ]
        }
    

    Template.compose.events
        'click #submit_new_message': ->
            username = FlowRouter.getParam('username')
            message_text = $('#new_message_body').val()
            # console.log username
            # console.log message_text
            Messages.insert
                tags: ['message']
                recipient_username: username
                read: false
                body: message_text
            $('#new_message_body').val('')
                

if Meteor.isServer
    Meteor.publish 'usernames', ->
        Meteor.users.find {},
            fields: username: 1