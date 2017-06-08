if Meteor.isClient
    FlowRouter.route '/messages', 
        name: 'messages'
        action: (params) ->
            BlazeLayout.render 'layout',
                # sub_nav: 'account_nav'
                # sub_nav: 'account_nav'
                main: 'my_messages'

    Template.my_messages.onCreated ->
        @autorun -> Meteor.subscribe('my_messages')
        
    Template.my_messages.helpers
        my_messages: ->
            Docs.find
                tags: $in: ['message']
                author_id: Meteor.userId()  
    
       
    Template.messages_with_user.onCreated ->
        @autorun -> Meteor.subscribe('messages_with_user', FlowRouter.getParam('username'))
       
    Template.messages_with_user.helpers
        person: -> Meteor.users.findOne username:FlowRouter.getParam('username') 
        is_user: -> FlowRouter.getParam('username') is Meteor.user()?.username
        conversation_messages_with_user: ->
            username = FlowRouter.getParam('username')
            Docs.find
                tags: $in: ['message']
                recipient_username: username
  
  
            
    Template.message.events
        'click .mark_read': ->
            Docs.update @_id,
                $set: read: true
            
            
        'click .mark_unread': ->
            Docs.update @_id,
                $set: read: false
            
            
            
if Meteor.isServer
    Meteor.publish 'messages_with_user', (username)->
        Docs.find
            tags: $in: ['message']
            recipient_username: username
            author_id: @userId
            
    Meteor.publish 'my_sent_messages', ->
        Docs.find
            tags: $in: ['message']
            author_id: @userId
            
    Meteor.publish 'my_received_messages', ->
        Docs.find
            tags: $in: ['message']
            parent_id: @userId
            
            
            