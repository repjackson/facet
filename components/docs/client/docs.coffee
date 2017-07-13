Template.docs.onCreated ->
    # @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('editing_id'))
    @autorun => Meteor.subscribe('docs', selected_tags.array() )

Template.docs.helpers
    docs: -> 
        Docs.find { }, 
            sort:
                tag_count: 1
            limit: 1

    tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
    is_editing: -> Session.equals 'editing_id', @_id
    one_doc: -> Docs.find().count() is 1


Template.view.helpers
    is_editing: -> Session.equals 'editing_id', @_id
    is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''

    when: -> moment(@timestamp).fromNow()
    day: -> moment(@start_datetime).format("dddd, MMMM Do");
    start_time: -> moment(@start_datetime).format("h:mm a")
    end_time: -> moment(@end_datetime).format("h:mm a")


Template.view.events
    'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
    'click .clone': -> 
        id = Docs.insert tags: @tags
        FlowRouter.go "/edit/#{id}"

    'click .expand_card': (e,t)->
            $(e.currentTarget).closest('.card').toggleClass 'fluid'



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
                # split_tags = tags.split(',')
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
        
