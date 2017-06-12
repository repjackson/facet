Template.docs.onCreated ->
    # @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('editing_id'))
    @autorun => 
        Meteor.subscribe('docs', 
            selected_tags.array() 
            limit=null 
            view_unvoted=Session.get('view_unvoted') 
            view_upvoted=Session.get('view_upvoted') 
            view_downvoted=Session.get('view_downvoted') 
        )
    @autorun -> Meteor.subscribe 'unvoted_count'
    @autorun -> Meteor.subscribe 'voted_up_count'
    @autorun -> Meteor.subscribe 'voted_down_count'

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
    one_doc: -> Docs.find().count() is 1
    voted_up_count: -> Counts.get('voted_up_count')
    voted_down_count: -> Counts.get('voted_down_count')

    voted_up_class: -> 
        if Session.equals 'view_upvoted', true then 'active' else ''
    voted_down_class: -> 
        if Session.equals 'view_downvoted', true then 'active' else ''
    unvoted_item_class: -> 
        if Session.equals('view_unvoted', true) and Session.equals('view_upvoted', false) and Session.equals('view_downvoted', false) then 'active' else ''
    
    all_item_class: -> 
        if Session.equals('view_unvoted', false) and Session.equals('view_upvoted', false) and Session.equals('view_unvoted', false)
            'active' 
        else ''


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


    'click #set_mode_to_all': -> 
        if Meteor.userId() 
            Session.set 'view_unvoted', false
            Session.set 'view_upvoted', false
            Session.set 'view_downvoted', false
        else FlowRouter.go '/sign-in'

    'click #select_unvoted': -> 
        if Meteor.userId() 
            Session.set 'view_unvoted', true
            Session.set 'view_upvoted', false
            Session.set 'view_downvoted', false
        else FlowRouter.go '/sign-in'
    
    'click #toggle_voted_up': -> 
        if Meteor.userId() 
            if Session.equals 'view_upvoted', true
                Session.set 'view_upvoted', false
            else 
                Session.set 'view_upvoted', true
                Session.set 'view_downvoted', false
                Session.set 'view_unvoted', false
        else FlowRouter.go '/sign-in'
    
    'click #toggle_voted_down': -> 
        if Meteor.userId() 
            if Session.equals 'view_downvoted', true
                Session.set 'view_downvoted', false
            else 
                Session.set 'view_downvoted', true
                Session.set 'view_upvoted', false
                Session.set 'view_unvoted', false
        else FlowRouter.go '/sign-in'



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
        