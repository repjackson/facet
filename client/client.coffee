Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id
Template.registerHelper 'is_user', () ->  Meteor.userId() is @_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

        
Template.registerHelper 'segment_class', () -> 
    if Roles.userIsInRole 'admin'
        if @published then 'raised blue' else ''
    else
        ''
Template.registerHelper 'ribbon_class', () -> if @published then 'blue' else 'basic'

Template.registerHelper 'from_now', () -> moment(@timestamp).fromNow()

Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do, h:mm a")
# Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")


Template.registerHelper 'in_course', () -> @_id in Meteor.user().courses
Template.registerHelper 'in_sol', () -> Roles.userIsInRole 'sol_member'
Template.registerHelper 'in_demo', () -> Roles.userIsInRole 'sol_demo_member'


Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment


        