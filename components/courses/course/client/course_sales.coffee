FlowRouter.route '/course/sol/sales', 
    name: 'course_sale_page'
    action: (params) ->
        BlazeLayout.render 'layout',
            main: 'course_sales'



Template.course_sales.onCreated ->
    @autorun -> Meteor.subscribe 'doc_by_tags', tags=['course', 'sol']



Template.course_sales.helpers
    in_sol: -> Roles.userIsInRole(Meteor.userId(), 'sol_member')
    in_demo: -> Roles.userIsInRole(Meteor.userId(), 'sol_demo')
    sol_course: -> Docs.findOne tags: $all: ['course','sol']

Template.course_sales.events
    'click #sign_up_demo': ->
        if Meteor.user()
            Roles.addUsersToRoles(Meteor.userId(), 'sol_demo')
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    courses: 'sol'
            swal {
                title: "Thank you, #{Meteor.user().name()}."
                text: "You're now enrolled in the demo."
                type: 'success'
                animation: true
                confirmButtonText: "Continue to Course",
                closeOnConfirm: true
            }, ->
                FlowRouter.go "/course/sol/welcome"

    
        else 
            Session.set 'enrolling_in', 'sol_demo'
            FlowRouter.go '/register-sol'
            # FlowRouter.go '/sign-up'
    
    
    'click #unenroll': ->
        Roles.removeUsersFromRoles(Meteor.userId(), 'sol_demo')
