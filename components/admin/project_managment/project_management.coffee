if Meteor.isClient
    FlowRouter.route '/admin_edit/:doc_id', action: (params) ->
        BlazeLayout.render 'layout',
            main: 'admin_edit'

    Template.admin_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    
    Template.admin_edit.helpers
        doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    
    
    Template.admin_edit.events
        'click #save_admin_doc': ->
            selected_admin_tags.clear()
            for tag in @tags
                selected_admin_tags.push tag
            FlowRouter.go '/admin/project_management'
    
        
    FlowRouter.route '/admin/project_management', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            sub_nav: 'admin_nav'
            main: 'project_management'


    @selected_admin_tags = new ReactiveArray []

    Template.project_management.onCreated ->
        @autorun => Meteor.subscribe('admin_tags', selected_admin_tags.array(), limit=20, view_mode=Session.get('view_mode'))
        @autorun -> Meteor.subscribe('admin_docs', selected_admin_tags.array(), limit=10, view_mode=Session.get('view_mode'))

    Template.project_management.helpers
            
        admin_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3
                Tags.find { 
                    count: $lt: doc_count
                    }, limit:10
            else
                Tags.find({}, limit:10)
        
        admin_tag_class: -> 
            button_class = []
            if @valueOf() in selected_admin_tags.array() then button_class.push 'teal' else button_class.push 'basic'

            button_class
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class

        selected_admin_tags: -> selected_admin_tags.array()
    
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: false
                    template: Template.tag_result
                }
                ]
        }
    
        admin_docs: -> 
            Docs.find {type: 'admin' }, 
                sort:
                    tag_count: 1
            # Docs.find {}, 


        one_doc: -> Docs.find().count() is 1
        tag_class: -> if @valueOf() in selected_admin_tags.array() then 'teal' else 'basic'
        selected_admin_tags: -> selected_admin_tags.array()
        all_item_class: -> if Session.equals 'view_mode', 'all' then 'active' else ''
        mine_item_class: -> 
            if Meteor.user()
                if Session.equals 'view_mode', 'completed' then 'active' else ''
            else
                'disabled'
    
    
    
    Template.project_management.events
        'click #set_mode_to_all': -> 
            if Meteor.userId() then Session.set 'view_mode', 'all'
            else FlowRouter.go '/sign-in'
    
        'click #set_mode_to_mine': -> 
            if Meteor.userId() then Session.set 'view_mode', 'mine'
            else FlowRouter.go '/sign-in'

    
        'click .select_tag': -> selected_admin_tags.push @name
        'click .unselect_tag': -> selected_admin_tags.remove @valueOf()
        'click #clear_tags': -> selected_admin_tags.clear()
    
        'click #add': ->
            new_id = Docs.insert 
                type:'admin'
                tags: selected_admin_tags.array()
            FlowRouter.go "/admin_edit/#{new_id}"

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_admin_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_admin_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_admin_tags.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_admin_tags.push doc.name
            $('#search').val ''


    Template.admin_doc_view.helpers
        project_card_class: ->
            if 'done' in @tags then 'green'



if Meteor.isServer
    publishComposite 'admin_docs', (selected_admin_tags, limit, view_mode)->
        {
            find: ->
                self = @
                match = {}
                # match.tags = $all: selected_admin_tags
                if selected_admin_tags.length > 0 then match.tags = $all: selected_admin_tags
                match.type = 'admin'
                # console.log view_mode
                if view_mode is 'completed' then match.completed = true
                Docs.find match, 
                    limit: limit
            children: [
                { find: (doc) ->
                    Meteor.users.find 
                        _id: doc.author_id
                    }
                ]    
        }

    Meteor.publish 'admin_tags', (selected_tags, limit, view_mode)->
        
        self = @
        match = {}
        
        # match.tags = $all: selected_tags
        match.type = 'admin'
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        
        if view_mode is 'completed' then match.completed = true
        
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
            