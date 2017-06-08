
if Meteor.isClient
    FlowRouter.route '/account/favorites/', action: (params) ->
        BlazeLayout.render 'layout',
            sub_nav: 'account_nav'
            main: 'favorites'
    
    Template.favorites.onCreated ->
        @autorun -> Meteor.subscribe 'favorites'
    
    
    
    Template.favorites.helpers
        favorited_items: -> 
            Docs.find {favoriters: $in: [Meteor.userId()]}
            
        five_tags: -> @tags[0..5]
    Template.favorites.events


if Meteor.isServer
    Meteor.publish 'favorites', ->
        Docs.find
            favoriters: $in: [@userId]