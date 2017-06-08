FlowRouter.route '/cart',
    triggersEnter: [ AccountsTemplates.ensureSignedIn ]
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart'

FlowRouter.route '/cart-profile/:user_id',
    triggersEnter: [ AccountsTemplates.ensureSignedIn ]
    action: ->
        BlazeLayout.render 'layout',
            main: 'cart_profile'


if Meteor.isClient
    Template.cart.onCreated ->
        if Meteor.isDevelopment
            stripe_key = Meteor.settings.public.stripe.testPublishableKey
            # console.log 'using test key'
        else if Meteor.isProduction
            stripe_key = Meteor.settings.public.stripe.livePublishableKey
        else 
            console.log 'not dev or prod'
        
        @autorun -> Meteor.subscribe 'cart'
        Template.instance().checkout = StripeCheckout.configure(
            key: stripe_key
            image: '/toriwebster-logomark-04.png'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # console.log token
                purchasing_item = Docs.findOne Session.get 'purchasing_item'
                console.dir 'purchasing_item', purchasing_item
                charge = 
                    amount: purchasing_item.price*100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    receipt_email: token.email
                Meteor.call 'processPayment', charge, (error, response) =>
                    if error then Bert.alert error.reason, 'danger'
                    else
                        Meteor.call 'register_purchase', purchasing_item._id, (err, response)->
                            if err then console.error err
                            else
                                Bert.alert "You have purchased #{purchasing_item.title}.", 'success'
                                Docs.remove Session.get('current_cart_item')
                                FlowRouter.go "/account"
            # closed: ->
            #     Bert.alert "Payment Canceled", 'info', 'growl-top-right'
        )

    Template.cart_checkout.helpers 
        cart_items: ->
            Docs.find
                type: 'cart_item'
                author_id: Meteor.userId()
                
        parent_doc: -> Docs.findOne @parent_id
            
        total_items: -> Docs.find({type: 'cart_item'},{author_id: Meteor.userId()}).count()
            
        subtotal: ->    
            subtotal = 0
            cart_items = Docs.find({type: 'product'}).fetch()
            for cart_item in cart_items
                subtotal += cart_item.price
            subtotal
            
    Template.cart.events
        # 'click .buy_course': ->
        #     if @price > 0
        #         Template.instance().checkout.open
        #             name: @title
        #             description: @subtitle
        #             amount: @price*100
        #     else
        #         Meteor.call 'enroll', @_id, (err,res)=>
        #             if err then console.error err
        #             else
        #                 Bert.alert "You are now enrolled in #{@title}", 'success'
        #                 # FlowRouter.go "/course/#{_id}"

        'click .purchase_item': ->
            Session.set 'purchasing_item', @parent_id
            Session.set 'current_cart_item', @_id
            parent_doc = Docs.findOne @parent_id
            if parent_doc.price > 0
                Template.instance().checkout.open
                    name: 'Tori Webster Inspires, LLC'
                    description: parent_doc.title
                    amount: parent_doc.price*100
            else
                Meteor.call 'register_purchase', @parent_id, (err,response)=>
                    if err then console.error err
                    else
                        Bert.alert "Thank you for your purchase.", 'success'
                        Docs.remove @_id
                        FlowRouter.go "/account"
                        
                    


if Meteor.isServer
    Meteor.methods
        'add_to_cart': (doc_id)->
            Docs.insert
                type: 'cart_item'
                parent_id: doc_id
                number: 1
        
        'remove_from_cart': (doc_id)->
            Docs.remove
                type: 'cart_item'
                parent_id: doc_id
        
        'register_purchase': (product_id)->
            product = Docs.findOne product_id
            Docs.insert
                type: 'purchase'
                parent_id: product_id
                sale_price: product.price
        
        
    publishComposite 'cart', ->
        {
            find: ->
                Docs.find
                    type: 'cart_item'
                    author_id: @userId            
            children: [
                { find: (cart_item) ->
                    Docs.find cart_item.parent_id
                    }
                ]    
        }
