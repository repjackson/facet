if Meteor.isClient
    FlowRouter.route '/marketplace', action: ->
        BlazeLayout.render 'layout',
            # sub_nav: 'account_nav'
            main: 'marketplace'

    Template.marketplace.onCreated ->
        @autorun -> Meteor.subscribe('selected_products')
        Session.set 'layout_view', 'list'
    
    Template.marketplace.helpers
        products: -> 
            Docs.find {type: 'product'},
                sort:
                    publish_date: -1
                limit: 5
                
        is_grid_view: -> Session.equals 'layout_view', 'grid'        
        is_list_view: -> Session.equals 'layout_view', 'list'        
                
        list_layout_button_class: -> if Session.get('layout_view') is 'list' then 'teal' else 'basic'
        grid_layout_button_class: -> if Session.get('layout_view') is 'grid' then 'teal' else 'basic'
                
    Template.marketplace.events
        'click #add_product': ->
            id = Docs.insert
                type: 'product'
            FlowRouter.go "/edit/#{id}"
    
        'click #make_list_layout': -> Session.set 'layout_view', 'list'
        'click #make_grid_layout': -> Session.set 'layout_view', 'grid'
        
    Template.product_item.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'teal' else 'basic'
    
        can_edit: -> @author_id is Meteor.userId()
    
    Template.product_item.events
        'click .product_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    
if Meteor.isServer
    Meteor.publish 'selected_products', ->
        
        self = @
        match = {}
        match.type = 'product'
        if not @userId or not Roles.userIsInRole(@userId, ['admin'])
            match.published = true
        
    
        Docs.find match
    
    
    Meteor.publish 'product', (doc_id)->
        Docs.find doc_id

    
