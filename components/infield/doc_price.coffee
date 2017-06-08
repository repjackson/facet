if Meteor.isClient
    Template.doc_price.onCreated ->
        @autorun => Meteor.subscribe 'facet_doc', @data.tags
        @editing = new ReactiveVar(false)

    Template.doc_price.helpers
        editing: -> Template.instance().editing.get()
        doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne tags: split_array
    
        template_tags: -> Template.currentData().tags
    
        doc_classes: -> Template.parentData().classes

    Template.doc_price.events
        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

        'change #price': ->
            price = parseInt $('#price').val()
            Docs.update @_id,
                $set: price: price
                
        'click .edit_this': (e,t)-> t.editing.set true
        'click .save_doc': (e,t)-> t.editing.set false
