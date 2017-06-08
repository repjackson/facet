FlowRouter.route '/courses', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'courses'


Template.courses.onCreated -> 
    @autorun => Meteor.subscribe('courses', view_mode=Session.get('view_mode'))


Template.courses.helpers
    courses: -> 
        Docs.find
            tags: $all:['course']

    all_item_class: -> if Session.equals 'view_mode', 'all' then 'active' else ''
    mine_item_class: -> 
        if Meteor.user()
            if Session.equals 'view_mode', 'mine' then 'active' else ''
        else
            'disabled'
Template.courses.events
    'click #set_mode_to_all': -> 
        if Meteor.userId() then Session.set 'view_mode', 'all'
        else FlowRouter.go '/sign-in'

    'click #set_mode_to_mine': -> 
        if Meteor.userId() then Session.set 'view_mode', 'mine'
        else FlowRouter.go '/sign-in'
