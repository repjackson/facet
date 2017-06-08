if Meteor.isClient
    Template.doc_content.onCreated ->
        @editing = new ReactiveVar(false)

        @autorun => Meteor.subscribe 'facet_doc', @data.tags 
        
        
    Template.doc_body.onCreated ->
        @editing = new ReactiveVar(false)

        @autorun => Meteor.subscribe 'facet_doc', @data.tags 
        
        
    Template.doc_content.helpers
        editing: -> Template.instance().editing.get()

        doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne
                tags: split_array
    
        template_tags: ->
            Template.currentData().tags
    
        doc_classes: ->
            Template.parentData().classes

    
    Template.doc_body.helpers
        editing: -> Template.instance().editing.get()

        doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne
                tags: split_array
    
        template_tags: ->
            Template.currentData().tags
    
        doc_classes: ->
            Template.parentData().classes

    
    
    Template.doc_content.events
        'click .edit_this': (e,t)-> t.editing.set true
        'click .save_doc': (e,t)-> t.editing.set false

        'click .edit_content': ->
            Session.set 'editing_id', @_id

        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

            
    Template.doc_body.events
        'click .edit_this': (e,t)-> t.editing.set true
        'click .save_doc': (e,t)-> t.editing.set false

        'click .edit_content': ->
            Session.set 'editing_id', @_id

        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

            
    Template.edit_content.helpers
        edit_doc_context: ->
            @current_doc = Docs.findOne @_id 
            self = @
            {
                _value: self.current_doc.content
                _keepMarkers: true
                _className: 'froala-reactive-meteorized-override'
                toolbarInline: false
                initOnClick: false
                imageInsertButtons: ['imageBack', '|', 'imageByURL']
                tabSpaces: false
                height: 300
            }

    
    Template.edit_content.events            
        'blur .froala-container': (e,t)->
            html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
            
            Docs.update @_id,
                $set: content: html
                
        'click .save_content': ->
            Session.set 'editing_id', null
            
            
            
    Template.edit_body_field.events        
        'blur #body': (e,t)->
            body = $(e.currentTarget).closest('#body').val()
            Docs.update @_id,
                $set: body: body
                
        'keyup #body': (e,t)->
            if e.which is 13
                body = $(e.currentTarget).closest('#body').val()
                Docs.update @_id,
                    $set: body: body
                Session.set 'editing_id', null
                            
    Template.edit_parentid_field.events        
        'blur #parent_id': (e,t)->
            parent_id = $(e.currentTarget).closest('#parent_id').val()
            Docs.update @_id,
                $set: parent_id: parent_id
                
        # 'keyup #body': (e,t)->
        #     if e.which is 13
        #         body = $(e.currentTarget).closest('#body').val()
        #         Docs.update @_id,
        #             $set: body: body
        #         Session.set 'editing_id', null
                            
            
    Template.edit_body.events            
        'blur #body': (e,t)->
            body = $(e.currentTarget).closest('#body').val()
            Docs.update @_id,
                $set: body: body
            
        'click .save_content': ->
            Session.set 'editing_id', null
            
            
            
            
if Meteor.isServer
    Meteor.publish 'facet_doc', (tags)->
        split_array = tags.split ','
        Docs.find
            tags: split_array