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
                Session.set 'editing_id', id


    Template.edit.events
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
                if FlowRouter.getParam('doc_id') 
                    FlowRouter.go "/#{self.type}"
            