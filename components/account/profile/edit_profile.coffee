FlowRouter.route '/account/profile/edit/:user_id?', 
    action: (params) ->
        if not params.user_id then FlowRouter.go "/account/profile/edit/#{Meteor.userId()}"
        BlazeLayout.render 'layout',
            sub_nav: 'account_nav'
            main: 'edit_profile'




if Meteor.isClient
    Template.edit_profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_by_id', FlowRouter.getParam('user_id') 
    
    # Template.edit_profile.onRendered ->
    #     console.log Meteor.users.findOne(FlowRouter.getParam('user_id'))
    
    Template.edit_profile.helpers
        user: -> Meteor.users.findOne FlowRouter.getParam('user_id')
    
        enrolling_in_demo: -> Session.get 'enrolling_in', 'sol_demo'
    
    
    
    Template.edit_profile.events
        'blur #first_name': ->
            first_name = $('#first_name').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.first_name": first_name

        'blur #last_name': ->
            last_name = $('#last_name').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.last_name": last_name

        'blur #location': ->
            location = $('#location').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.location": location
            
        'blur #if_knew_me': ->
            if_knew_me = $('#if_knew_me').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.if_knew_me": if_knew_me
            
        'blur #about_me': ->
            about_me = $('#about_me').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.about_me": about_me
            
        'blur #if_not_working': ->
            if_not_working = $('#if_not_working').val().trim()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $set: 
                    "profile.if_not_working": if_not_working

            
        'keydown #input_image_id': (e,t)->
            if e.which is 13
                user_id = FlowRouter.getParam('user_id')
                image_id = $('#input_image_id').val().toLowerCase().trim()
                if image_id.length > 0
                    Meteor.users.update user_id,
                        $set: image_id: image_id
                    $('#input_image_id').val('')
                
                
        'keydown #add_tag': (e,t)->
            if e.which is 13
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Meteor.users.update FlowRouter.getParam('user_id'),
                        $addToSet: tags: tag
                    $('#add_tag').val('')
    
        'click .person_tag': (e,t)->
            tag = @valueOf()
            Meteor.users.update FlowRouter.getParam('user_id'),
                $pull: tags: tag
            $('#add_tag').val(tag)
    
        'click #save_profile': ->
            if Session.get 'enrolling_in', 'sol_demo' 
                user_id = FlowRouter.getParam('user_id')
                Roles.addUsersToRoles user_id, 'sol_demo'
                Meteor.users.update user_id,
                    $addToSet: courses: 'sol'
                Session.set 'enrolling_in', null
            FlowRouter.go "/profile/#{@username}"
    
        "change input[type='file']": (e) ->
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
                        Meteor.users.update FlowRouter.getParam('user_id'),
                            $set: "profile.image_id": res.public_id
                    return
    
        'click #pick_google_image': ->
            picture = Meteor.user().profile.google_image
            Meteor.call 'download_image', picture, (err, res)->
                if err
                    console.error err
                else
                    console.log typeof res
                    Cloudinary.upload res,
                        # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                        # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                        (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                            # console.log "Upload Error: #{err}"
                            # console.dir res
                            if err
                                console.error 'Error uploading', err
                            else
                                console.log 'i think this worked'
                                Meteor.users.update FlowRouter.getParam('user_id'), 
                                    $set: "profile.image_id": res.public_id
                            return
    
    
        'click #remove_photo': ->
            Meteor.users.update FlowRouter.getParam('user_id'),
                $unset: "profile.image_id": 1
                
                
                
        'change #newsletter': (e,t)->
            # console.log e.currentTarget.value
            value = $('#newsletter').is(":checked")
            Meteor.users.update FlowRouter.getParam('user_id'), 
                $set:
                    "profile.subscribe": value
    



        'click #publish': -> Meteor.users.update FlowRouter.getParam('user_id'), $set: "profile.published": true
        'click #unpublish': -> Meteor.users.update FlowRouter.getParam('user_id'), $set: "profile.published": false


if Meteor.isServer
    Meteor.publish 'my_profile', ->
        Meteor.users.find @userId,
            fields:
                tags: 1
                profile: 1
                username: 1
                image_id: 1
                courses: 1
    
    
    Meteor.publish 'user_profile', (username)->
        Meteor.users.find username:username,
            fields:
                tags: 1
                profile: 1
                username: 1
                image_id: 1
                courses: 1
                points: 1
    
    Meteor.publish 'user_by_id', (id)->
        Meteor.users.find id,
            fields:
                tags: 1
                profile: 1
                username: 1
                image_id: 1
                courses: 1
                points: 1
                
                