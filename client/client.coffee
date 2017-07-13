Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id
Template.registerHelper 'is_user', () ->  Meteor.userId() is @_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'from_now', () -> moment(@timestamp).fromNow()

Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do, h:mm a")
# Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")



Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment


$.cloudinary.config
    cloud_name:"facet"
        