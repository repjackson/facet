FlowRouter.route '/admin', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'admin'
        
FlowRouter.route '/admin/users', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'users'
        
FlowRouter.route '/admin/content', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'all_content'


Template.content.onCreated ->
    @autorun -> Meteor.subscribe 'all_docs'


Template.content.helpers
    docs: -> Docs.find()



Template.content.events
    'click #add_page': ->
        id = Docs.insert 
            type: 'page'
        FlowRouter.go "/page/edit/#{id}"

    'click #add_doc': ->
        id = Docs.insert({})
        FlowRouter.go "/edit/#{id}"
