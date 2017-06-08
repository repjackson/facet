if Meteor.isClient
    Template.my_excercises.onCreated -> 
        @autorun -> Meteor.subscribe('my_excercises')


    Template.my_excercises.helpers
        my_excercises: -> 
            if Meteor.user()?.courses
                Docs.find
                    type: 'course'
                    _id: $in: Meteor.user().courses
    
        in_course: ->
            Meteor.user()?.my_excercises and @title in Meteor.user().my_excercises
    
if Meteor.isServer
    Meteor.publish 'my_excercises', ->
        me = Meteor.users.findOne @userId
        Docs.find
            type: 'excercise'
            