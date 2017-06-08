# loggedIn = FlowRouter.group
#     triggersEnter: [ ->
#         unless Meteor.loggingIn() or Meteor.userId()
#             route = FlowRouter.current()
#         unless route.route.name is 'login'
#             Session.set 'redirectAfterLogin', route.path
#             FlowRouter.go 'login'
#         ]




FlowRouter.route '/course/sol', 
    name: 'course_home'
    triggersEnter: [ (context, redirect) ->
        if Meteor.user() and Roles.userIsInRole(Meteor.userId(), 'sol_member') or Roles.userIsInRole(Meteor.userId(), 'sol_demo')
            redirect "/course/sol/welcome"
        else 
            redirect "/course/sol/sales"
    ]





# FlowRouter.route '/course/:slug/reminders', 
#     name: 'course_reminders'
#     action: (params) ->
#         BlazeLayout.render 'view_course',
#             course_content: 'course_reminders'

FlowRouter.route '/register-sol', 
    name: 'register-sol'
    action: (params) ->
        BlazeLayout.render 'layout',
            main: 'register_sol'



Template.view_course.onCreated ->
    @autorun -> Meteor.subscribe 'doc_by_tags', ['course','sol']
    @autorun -> Meteor.subscribe 'sol_members', selected_course_member_tags.array()

Template.view_course.helpers
    course: -> Docs.findOne tags: ['course','sol']
    



Template.view_course.events
    # 'click #add_module': ->
    #     slug = FlowRouter.getParam('slug')
    #     new_module_id = Modules.insert
    #         parent_course_slug:slug 
    #     FlowRouter.go "/course/#{slug}/module/#{new_module_id}/edit"
            