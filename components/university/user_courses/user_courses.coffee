if Meteor.isClient
    Template.user_courses.onCreated -> 
        @autorun -> Meteor.subscribe('user_courses')


    Template.user_courses.helpers
        user_courses: -> 
            if Meteor.user()?.courses
                Docs.find
                    type: 'course'
                    _id: $in: Meteor.user().courses
    
        in_course: ->
            Meteor.user()?.user_courses and @title in Meteor.user().user_courses
    
if Meteor.isServer
    Meteor.publish 'user_courses', ->
        me = Meteor.users.findOne @userId
        if me.courses
            Docs.find
                type: 'course'
                _id: $in: me.courses