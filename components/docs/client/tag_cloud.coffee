@selected_tags = new ReactiveArray []

Template.tag_cloud.onCreated ->
    # @autorun => Meteor.subscribe('tags', selected_tags.array(), @data.filter)
    @autorun => 
        Meteor.subscribe('tags', 
            selected_tags.array()
            selected_numbers.array()
            limit=20
            view_unvoted=Session.get('view_unvoted') 
            view_upvoted=Session.get('view_upvoted') 
            view_downvoted=Session.get('view_downvoted')
        )

Template.tag_cloud.helpers
    all_tags: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find({}, limit: 20)
        # Tags.find()
        
    tag_cloud_class: ->
        button_class = switch
            when @index <= 5 then 'big'
            when @index <= 10 then 'large'
            when @index <= 15 then ''
            when @index <= 20 then 'small'
            when @index <= 25 then 'tiny'
        return button_class

    settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                matchAll: true
                template: Template.tag_result
            }
            ]
    }
    

    selected_tags: -> 
        # type = 'event'
        # console.log "selected_#{type}_tags"
        selected_tags.array()


Template.tag_cloud.events
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