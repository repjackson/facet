Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'



Template.tags.events
    'keydown #add_tag': (e,t)->
        if e.which is 13
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Docs.update @_id,
                    $addToSet: tags: tag
                    # $set: tag_count: @tags.length
                $('#add_tag').val('')

    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Docs.update Template.currentData()._id,
            $pull: tags: tag
            # $set: tag_count: Template.currentData().tags.length
        $('#add_tag').val(tag)



            

Template.content.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)

        Docs.update @_id,
            $set: content: html
                

Template.content.helpers
    getFEContext: ->
        @current_doc = Docs.findOne @_id
        self = @
        {
            _value: self.content
            _keepMarkers: true
            _className: 'froala-reactive-meteorized-override'
            toolbarInline: false
            initOnClick: false
            imageInsertButtons: ['imageBack', '|', 'imageByURL']
            tabSpaces: false
            height: 300
        }


Template.delete_button.events
