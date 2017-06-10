if Meteor.isClient
    Template.product_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.product_edit.helpers
        product: ->
            Docs.findOne FlowRouter.getParam('doc_id')
        
            
    Template.product_edit.events
        'click #save_product': ->
            FlowRouter.go "/product/#{@_id}/view"
