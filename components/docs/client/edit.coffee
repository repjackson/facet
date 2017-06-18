FlowRouter.route '/edit/:doc_id',
    action: (params) ->
        BlazeLayout.render 'layout',
            # top: 'nav'
            main: 'edit'




Template.edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.view_youtube.onRendered ->
    Meteor.setTimeout (->
        $('.ui.embed').embed()
    ), 2000

    # Meteor.setTimeout (->
    #     $('#datetimepicker').datetimepicker(
    #         onChangeDateTime: (dp,$input)->
    #             val = $input.val()

    #             # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #             minute = moment(val).minute()
    #             hour = moment(val).format('h')
    #             date = moment(val).format('Do')
    #             ampm = moment(val).format('a')
    #             weekdaynum = moment(val).isoWeekday()
    #             weekday = moment().isoWeekday(weekdaynum).format('dddd')

    #             month = moment(val).format('MMMM')
    #             year = moment(val).format('YYYY')

    #             datearray = [hour, minute, ampm, weekday, month, date, year]

    #             doc_id = FlowRouter.getParam 'doc_id'

    #             doc = Docs.findOne doc_id
    #             tagsWithoutDate = _.difference(doc.tags, doc.datearray)
    #             tagsWithNew = _.union(tagsWithoutDate, datearray)

    #             Docs.update doc_id,
    #                 $set:
    #                     tags: tagsWithNew
    #                     datearray: datearray
    #                     dateTime: val
    #         )), 2000

    # @autorun ->
    #     if GoogleMaps.loaded()
    #         $('#place').geocomplete().bind 'geocode:result', (event, result) ->
    #             doc_id = Session.get 'editing'
    #             Meteor.call 'updatelocation', doc_id, result, ->

Template.edit.helpers
    doc: -> 
        doc_id = FlowRouter.getParam('doc_id')
        # console.log doc_id
        Docs.findOne doc_id 

    # elements:->
    #     [
    #         'title'
    #         'number'
    #         'content'
    #         'price'
    #         'location'
    #         'start_time'
    #         'end_time'
    #         'attached_users'
    #         'voting'
    #         'star_rating'
    #         'tag_rating'
    #         'comments'
    #         'link'
    #         'image'
    #         'youtube video'
    #         'vimeo video'
    #         'file'
    #         ]

Template.edit.events
    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('doc_id'),
                        $addToSet: tags: tag
                    $('#addTag').val('')
                else
                    FlowRouter.go '/'
                    selected_tags.clear()
                    selected_tags.push tag for tag in @tags

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')
    
    'click #clear_content': ->
        swal {
            title: 'clear content?'
            type: 'warning'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'no'
            confirmButtonText: 'clear'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            Docs.update FlowRouter.getParam('doc_id'),
                $unset:
                    content: 1
            swal 'content cleared', 'success'


    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: @valueOf()
        $('#addTag').val(tag)


    'click #saveDoc': ->
        FlowRouter.go '/'
        selected_tags.clear()
        selected_tags.push tag for tag in @tags

    'click #deleteDoc': ->
        if confirm 'Delete this doc?'
            Docs.remove @_id
            FlowRouter.go '/'


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
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call "c.delete_by_public_id", doc.image_id, (err,res) ->
                if err
                    throw new Meteor.Error "it failed miserably"
                    # Do Stuff with res
                    # console.log res
                    # console.log doc._id
                # else
            Docs.update doc._id, 
                $unset: 
                    image_id: 1
                    image_url: 1

    #         console.log Cloudinary
    # 		Cloudinary.delete "37hr", (err,res) ->
    # 		    if err 
    # 		        console.log "Upload Error: #{err}"
    # 		    else
    #     			console.log "Upload Result: #{res}"
    #                 # Docs.update @_id, 
    #                 #     $unset: image_id: 1


    'blur #image_url': ->
        image_url = $('#image_url').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: image_url: image_url
            
