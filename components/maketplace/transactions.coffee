if Meteor.isClient
    FlowRouter.route '/transactions', action: (params) ->
        BlazeLayout.render 'layout',
            sub_nav: 'account_nav'
            main: 'transactions'
    
    Template.transactions.onCreated ->
        @autorun => Meteor.subscribe 'transactions'
        
    Template.transactions.helpers
        transactions: -> 
            Docs.find
                type: 'transaction'
                author_id: Meteor.userId()
                
        parent_doc: ->
            Docs.findOne @parent_id

if Meteor.isServer
    publishComposite 'transactions', ->
        {
            find: ->
                Docs.find
                    type: 'transaction'
                    author_id: @userId            
            children: [
                { find: (transaction) ->
                    Docs.find transaction.parent_id
                    }
                ]    
        }
