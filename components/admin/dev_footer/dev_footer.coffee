if Meteor.isClient
    @selected_authors = new ReactiveArray []

    Template.dev_footer.onCreated ->
        @autorun => Meteor.subscribe('page_tags', selected_tags.array(), selected_authors.array())
    
    Template.dev_footer.helpers
        page_tags: ->
            Tags.find({}, limit:10)
                
        cloud_tag_class: ->
            button_class = []
            switch
                when @index <= 5 then button_class.push ' large'
                when @index <= 12 then button_class.push ' '
                when @index <= 20 then button_class.push ' small'
            return button_class
    
        selected_tags: -> selected_tags.array()
        selected_authors: -> selected_authors.array()

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
    
        docs: -> 
            if selected_tags.array().length > 0
                Docs.find {tags:$all: selected_tags.array()}, 
                    sort:
                        tag_count: 1
            else
                Docs.find {}, 
                    sort:
                        tag_count: 1
  
    
    Template.dev_doc.events
        'click .sel': (e)->
            if e.target.innerHTML in selected_authors.array() then selected_authors.remove e.target.innerHTML else selected_authors.push e.target.innerHTML
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    Template.dev_doc.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
    
    
    Template.dev_footer.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
    
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tags.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_tags.push doc.name
            $('#search').val ''
    

if Meteor.isServer
    Meteor.publish 'page_tags', (selected_tags)->
        
        self = @
        match = {}
        
        # match.tags = $all: selected_tags
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        
        # console.log 'limit:', limit
        
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
        
