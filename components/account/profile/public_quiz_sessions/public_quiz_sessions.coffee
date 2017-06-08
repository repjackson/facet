if Meteor.isClient
    Template.public_quiz_sessions.onCreated -> 
        @autorun -> Meteor.subscribe('public_quiz_sessions', FlowRouter.getParam('username'))


    Template.public_quiz_sessions.helpers
        public_quiz_sessions: -> 
            user = Meteor.users.findOne username:username
            Docs.find
                type: 'quiz_session'
                author_id: user._id
                published: true
    
    
if Meteor.isServer
    Meteor.publish 'public_quiz_sessions', (username) ->
        user = Meteor.users.findOne username:username
        Docs.find
            type: 'quiz_session'
            author_id: user._id
            published: true