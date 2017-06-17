
Template.start_end_time.events
    'change #start_datetime': ->
        start_datetime = $('#start_datetime').val()
        
        Docs.update FlowRouter.getParam('event_id'),
            $set: start_datetime: start_datetime


    'change #end_datetime': ->
        end_datetime = $('#end_datetime').val()
        
        Docs.update FlowRouter.getParam('event_id'),
            $set: end_datetime: end_datetime
            
            
Template.subtitle.events
    'blur #subtitle': ->
        subtitle = $('#subtitle').val()
        Docs.update @_id,
            $set: subtitle: subtitle
            
Template.plain.events
    'blur #plain': ->
        plain = $('#plain').val()
        Docs.update @_id,
            $set: plain: plain
            
            
# Template.child_tags.events
#     'keydown #add_tag': (e,t)->
#         if e.which is 13
#             tag = $('#add_tag').val().toLowerCase().trim()
#             if tag.length > 0
#                 Docs.update Template.parentData()._id,
#                     $addToSet: tags: tag
#                 $('#add_tag').val('')

#     'click .doc_tag': (e,t)->
#         tag = @valueOf()
#         Docs.update Template.parentData()._id,
#             $pull: tags: tag
#         $('#add_tag').val(tag)

Template.tags.events
    'keydown #add_tag': (e,t)->
        if e.which is 13
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Docs.update Template.currentData()._id,
                    $addToSet: tags: tag
                $('#add_tag').val('')
            

    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Docs.update Template.currentData()._id,
            $pull: tags: tag
        $('#add_tag').val(tag)

Template.tags.helpers
    tag_subset: ->
        _.difference(Template.parentData().tags, @filter)



Template.price.events
    'change #price': ->
        price = parseInt $('#price').val()

        Docs.update @_id,
            $set: price: price
            
            
Template.number.events
    'blur #number': (e) ->
        # console.log @
        val = $(e.currentTarget).closest('#number').val()
        number = parseInt val
        # console.log number
        Docs.update @_id,
            $set: number: number
            
Template.slots.events
    'blur #slots': (e) ->
        # console.log @
        val = $(e.currentTarget).closest('#slots').val()
        slots = parseInt val
        # console.log slots
        Docs.update @_id,
            $set: slots: slots
            
            
Template.title.events
    'blur #title': (e,t)->
        # alert 'hi'
        title = $(e.currentTarget).closest('#title').val()
        Docs.update @_id,
            $set: title: title
            
            
Template.slug.events
    'blur #slug': (e,t)->
        # alert 'hi'
        slug = $(e.currentTarget).closest('#slug').val()
        Docs.update @_id,
            $set: slug: slug
            
            
Template.link.events
    'blur #link': (e,t)->
        link = $(e.currentTarget).closest('#link').val()
        Docs.update @_id,
            $set: link: link
            
            
Template.page_name.events
    'blur #name': (e,t)->
        name = $(e.currentTarget).closest('#name').val()
        Docs.update @_id,
            $set: name: name
            
            
Template.type.events
    'blur #type': (e,t)->
        type = $('#type').val()
        Docs.update @_id,
            $set: type: type
            
            
Template.image.events
    "change input[type='file']": (e) ->
        doc_id = @_id
        files = e.currentTarget.files
        console.log files

        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                # console.log "Upload Error: #{err}"
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    Docs.update doc_id, $set: image_id: res.public_id
                return

    'keydown #input_image_id': (e,t)->
        if e.which is 13
            doc_id = @_id
            image_id = $('#input_image_id').val().toLowerCase().trim()
            if image_id.length > 0
                Docs.update doc_id,
                    $set: image_id: image_id
                $('#input_image_id').val('')



    'click #remove_photo': ->
        swal {
            title: 'Remove Photo?'
            type: 'warning'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'No'
            confirmButtonText: 'Remove'
            confirmButtonColor: '#da5347'
        }, =>
            Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                if not err
                    # Do Stuff with res
                    # console.log res
                    Docs.update @_id, 
                        $unset: image_id: 1

                else
                    throw new Meteor.Error "it failed miserably"

    #         console.log Cloudinary
    # 		Cloudinary.delete "37hr", (err,res) ->
    # 		    if err 
    # 		        console.log "Upload Error: #{err}"
    # 		    else
    #     			console.log "Upload Result: #{res}"
    #                 # Docs.update @_id, 
    #                 #     $unset: image_id: 1

            
Template.location.events
    'change #location': ->
        doc_id = @_id
        location = $('#location').val()

        Docs.update doc_id,
            $set: location: location

Template.content.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
        # snippet = $('#snippet').val()
        # if snippet.length is 0
        #     snippet = $(html).text().substr(0, 300).concat('...')
        doc_id = @_id

        Docs.update doc_id,
            $set: content: html
                

Template.content.helpers
    getFEContext: ->
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
