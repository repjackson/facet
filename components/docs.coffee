@Docs = new Meteor.Collection 'docs'


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
            timestamp: Date.now()
            author_id: Meteor.userId()

        return id


if Meteor.isClient
    Template.docs.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array())

    Template.docs.helpers
        docs: -> 
            Docs.find { }, 
                sort:
                    tag_count: 1
                limit: 1
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''


    
    Template.view.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
        is_editing: -> Session.equals 'editing_id', @_id
        tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
    
        when: -> moment(@timestamp).fromNow()

    Template.view.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
    
        'click .edit': -> Session.set 'editing_id', @_id

    Template.docs.events
        'click #add': ->
            Meteor.call 'add', (err,id)->
                FlowRouter.go "/edit/#{id}"


    Template.edit.events
        'click .save': ->
            Docs.update @_id,
                $set: tag_count: @tags.length
            Session.set 'editing_id', null
            
            
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
                if FlowRouter.getParam('doc_id') 
                    FlowRouter.go "/#{self.type}"
            