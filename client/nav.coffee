Template.nav.events
    'click #logout': -> AccountsTemplates.logout()
    
    'click #add_doc': ->
        Meteor.call 'add', (err,id)->
            FlowRouter.go "/edit/#{id}"


Template.layout.events
    'click #logout': -> AccountsTemplates.logout()

Template.body.events
    'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')
    
Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'cart'
    
# Template.nav.onRendered ->
#     Meteor.setTimeout =>
#         $('.ui.dropdown').dropdown()
#     , 500


Template.nav.helpers
    cart_items: -> Docs.find({type: 'cart_item'},{author_id: Meteor.userId()}).count()

Template.sidebar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context.example .ui.sidebar')
                    .sidebar({
                        context: $('.context.example .bottom.segment')
                        dimPage: false
                        transition:  'push'
                    })
                    .sidebar('attach events', '.context.example .menu .toggle_sidebar.item')
                    ;
            , 500