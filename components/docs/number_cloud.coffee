if Meteor.isClient
    @selected_numbers = new ReactiveArray []
    
    Template.number_cloud.onCreated ->
        # @autorun => Meteor.subscribe('numbers', selected_numbers.array(), @data.filter)
        @autorun => 
            Meteor.subscribe('numbers', 
                selected_tags.array()
                selected_numbers.array()
                limit=20
                view_unvoted=Session.get('view_unvoted') 
                view_upvoted=Session.get('view_upvoted') 
                view_downvoted=Session.get('view_downvoted')
            )
    
    Template.number_cloud.helpers
        all_numbers: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                Numbers.find {count: $lt: doc_count},
                    sort: name: 1
            else 
                Numbers.find {},
                    limit: 20
                    sort: name: 1
            # Numbers.find()
            
        # number_cloud_class: ->
        #     button_class = switch
        #         when @index <= 20 then 'big'
        #         when @index <= 40 then 'large'
        #         when @index <= 60 then ''
        #         when @index <= 80 then 'small'
        #         when @index <= 100 then 'tiny'
        #     return button_class
    
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Numbers
                    field: 'name'
                    matchAll: true
                    template: Template.number_result
                }
                ]
        }
        
    
        selected_numbers: -> 
            # type = 'event'
            # console.log "selected_#{type}_numbers"
            selected_numbers.array()
    
    
    Template.number_cloud.events
        'click .select_number': -> selected_numbers.push @name
        'click .unselect_number': -> selected_numbers.remove @valueOf()
        'click #clear_numbers': -> selected_numbers.clear()
        
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_numbers.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_numbers.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_numbers.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_numbers.push doc.name
            $('#search').val ''


if Meteor.isServer
    Meteor.publish 'numbers', (selected_tags, selected_numbers, limit, view_unvoted, view_upvoted, view_downvoted)->
        self = @
        match = {}
        if selected_numbers.length > 0 then match.number = $all: selected_numbers
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if filter then match.type = filter
        if view_unvoted 
            match.$or =
                [
                    upvoters: $nin: [@userId]
                    downvoters: $nin: [@userId]
                    ]
        if view_upvoted then match.upvoters = $in: [@userId]
        if view_downvoted then match.downvoters = $in: [@userId]
        match.number = $ne: null
    
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "number": 1 }
            # { $unwind: "$numbers" }
            { $group: _id: "$number", count: $sum: 1 }
            { $match: _id: $nin: selected_numbers }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
    
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
    
        cloud.forEach (number, i) ->
            self.added 'numbers', Random.id(),
                name: number.name
                count: number.count
                index: i
    
        self.ready()
