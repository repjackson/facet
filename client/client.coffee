Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id
Template.registerHelper 'is_user', () ->  Meteor.userId() is @_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

        
Template.registerHelper 'segment_class', () -> 
    if Roles.userIsInRole 'admin'
        if @published then 'raised blue' else ''
    else
        ''
Template.registerHelper 'ribbon_class', () -> if @published then 'blue' else 'basic'

Template.registerHelper 'from_now', () -> moment(@timestamp).fromNow()

Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do, h:mm a")
# Template.registerHelper 'long_date', () -> moment(@timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")


Template.registerHelper 'in_course', () -> @_id in Meteor.user().courses
Template.registerHelper 'in_sol', () -> Roles.userIsInRole 'sol_member'
Template.registerHelper 'in_demo', () -> Roles.userIsInRole 'sol_demo_member'


Template.registerHelper 'is_editing', () -> 
    # console.log 'this', @
    Session.equals 'editing_id', @_id


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment


Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('editing_id'))

Template.docs.helpers
    docs: -> 
        if Session.get 'editing_id'
            Docs.find Session.get('editing_id')
        else    
            Docs.find { }, 
                sort:
                    tag_count: 1
                limit: 1

    tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
    is_editing: -> Session.equals 'editing_id', @_id
    one_doc: ->
        Docs.find().count() is 1


Template.view.helpers
    is_editing: -> Session.equals 'editing_id', @_id
    is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''

    when: -> moment(@timestamp).fromNow()

Template.view.events
    'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    'click .edit': -> Session.set 'editing_id', @_id

Template.docs.events
    'click #add': ->
        Meteor.call 'add', selected_tags.array(), (err,id)->
            Session.set 'editing_id', id
    
    'keyup #quick_add': (e,t)->
        e.preventDefault
        tags = $('#quick_add').val().toLowerCase()
        if e.which is 13
            if tags.length > 0
                split_tags = tags.match(/\S+/g)
                $('#quick_add').val('')
                Docs.insert
                    tags: split_tags
                selected_tags.clear()
                for tag in split_tags
                    selected_tags.push tag


Template.edit.events
    'keydown #add_tag': (e,t)->
        if e.which is 13
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Docs.update @_id,
                    $addToSet: tags: tag
                $('#add_tag').val('')
            else
                Docs.update @_id,
                    $set: tag_count: @tags.length
                Session.set 'editing_id', null
                selected_tags.clear()
                selected_tags.push tag for tag in @tags 


    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Docs.update Template.currentData()._id,
            $pull: tags: tag
        $('#add_tag').val(tag)
        
        
        
    'click .save': ->
        Docs.update @_id,
            $set: tag_count: @tags.length
        Session.set 'editing_id', null
        selected_tags.clear()
        selected_tags.push tag for tag in @tags 
        
        
    'click #delete': ->
        self = @
        swal {
            title: 'Delete?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, ->
            Docs.remove self._id
            Session.set 'editing_id', null
        
        
        
        
        