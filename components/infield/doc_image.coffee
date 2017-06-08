if Meteor.isClient
    Template.doc_image.onCreated ->
        @autorun => Meteor.subscribe 'facet_doc', @data.tags 
        
        
    Template.doc_image.helpers
        doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne
                tags: split_array
    
        template_tags: ->
            Template.currentData().tags
    
        doc_classes: ->
            Template.parentData().classes

    Template.doc_image.events
        'click .edit_content': ->
            Session.set 'editing_id', @_id

        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

            
        "change input[type='file']": (e) ->
            doc_id = @_id
            files = e.currentTarget.files
    
    
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
                Docs.update @_id, 
                    $unset: image_id: 1

                # Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                #     if not err
                #         # Do Stuff with res
                #         # console.log res
                #         Docs.update @_id, 
                #             $unset: image_id: 1
    
                #     else
                #         throw new Meteor.Error "it failed miserably"
    
        #         console.log Cloudinary
        # 		Cloudinary.delete "37hr", (err,res) ->
        # 		    if err 
        # 		        console.log "Upload Error: #{err}"
        # 		    else
        #     			console.log "Upload Result: #{res}"
        #                 # Docs.update @_id, 
        #                 #     $unset: image_id: 1
