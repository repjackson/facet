if Meteor.isClient
    FlowRouter.route '/ballot', action: (params) ->
        BlazeLayout.render 'layout',
            main: 'ballot'

    @selected_ballot_tags = new ReactiveArray []

    Template.ballot.onCreated ->
        @autorun => 
            Meteor.subscribe('ballot_tags', 
                selected_ballot_tags.array()
                limit=20
                view_unvoted=Session.get('view_unvoted') 
                view_upvoted=Session.get('view_upvoted') 
                view_downvoted=Session.get('view_downvoted')
            )
        @autorun => 
            Meteor.subscribe('ballot_docs', 
                selected_ballot_tags.array() 
                limit=null 
                view_unvoted=Session.get('view_unvoted') 
                view_upvoted=Session.get('view_upvoted') 
                view_downvoted=Session.get('view_downvoted') 
            )
        @autorun -> Meteor.subscribe 'unvoted_ballot_count'
        @autorun -> Meteor.subscribe 'voted_up_ballot_count'
        @autorun -> Meteor.subscribe 'voted_down_ballot_count'



    Template.ballot.helpers
            
        ballot_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3
                Tags.find { 
                    count: $lt: doc_count
                    }, limit:10
            else
                Tags.find({}, limit:10)
        
        ballot_tag_class: -> 
            button_class = []
            if @valueOf() in selected_ballot_tags.array() then button_class.push 'teal' else button_class.push 'basic'

            button_class
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class

        selected_ballot_tags: -> selected_ballot_tags.array()
    
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
    
        ballot_docs: -> 
            if Session.get 'editing_id'
                Docs.find Session.get('editing_id')
            else
                Docs.find {type: 'ballot' }, 
                    sort:
                        tag_count: 1
            # Docs.find {}, 


        one_doc: -> Docs.find().count() is 1
    
        tag_class: -> if @valueOf() in selected_ballot_tags.array() then 'teal' else 'basic'

        selected_ballot_tags: -> selected_ballot_tags.array()
        
        voted_up_ballot_count: -> Counts.get('voted_up_ballot_count')
        voted_down_ballot_count: -> Counts.get('voted_down_ballot_count')
    
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

    
    Template.ballot.events
        'click .select_tag': -> selected_ballot_tags.push @name
        'click .unselect_tag': -> selected_ballot_tags.remove @valueOf()
        'click #clear_tags': -> selected_ballot_tags.clear()
    
        'click #add_ballot_doc': ->
            new_id = Docs.insert 
                type:'ballot'
                tags: selected_ballot_tags.array()
            Session.set 'editing_id', new_id

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_ballot_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_ballot_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_ballot_tags.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_ballot_tags.push doc.name
            $('#search').val ''

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

    Template.ballot_doc_view.helpers
        ballot_card_class: ->
            if Meteor.userId() in @upvoters then 'green'
            else if Meteor.userId() in @downvoters then 'red'




Meteor.methods
    vote_up: (id)->
        doc = Docs.findOne id
        if not doc.upvoters
            Docs.update id,
                $set: 
                    upvoters: []
                    downvoters: []
        else if Meteor.userId() in doc.upvoters #undo upvote
            Docs.update id,
                $pull: upvoters: Meteor.userId()
                $inc: points: -1
            # Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.downvoters #switch downvote to upvote
            Docs.update id,
                $pull: downvoters: Meteor.userId()
                $addToSet: upvoters: Meteor.userId()
                $inc: points: 2
            # Meteor.users.update doc.author_id, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: upvoters: Meteor.userId()
                $inc: points: 1
            # Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.call 'generate_upvoted_cloud', Meteor.userId()


    vote_down: (id)->
        doc = Docs.findOne id
        if not doc.downvoters
            Docs.update id,
                $set: 
                    upvoters: []
                    downvoters: []
        else if Meteor.userId() in doc.downvoters #undo downvote
            Docs.update id,
                $pull: downvoters: Meteor.userId()
                $inc: points: 1
            # Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.upvoters #switch upvote to downvote
            Docs.update id,
                $pull: upvoters: Meteor.userId()
                $addToSet: downvoters: Meteor.userId()
                $inc: points: -2
            # Meteor.users.update doc.author_id, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: downvoters: Meteor.userId()
                $inc: points: -1
            # Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.call 'generate_downvoted_cloud', Meteor.userId()


    favorite: (doc)->
        if doc.favoriters and Meteor.userId() in doc.favoriters
            Docs.update doc._id,
                $pull: favoriters: Meteor.userId()
                $inc: favorite_count: -1
        else
            Docs.update doc._id,
                $addToSet: favoriters: Meteor.userId()
                $inc: favorite_count: 1
    
    
    mark_complete: (doc)->
        if doc.completed_ids and Meteor.userId() in doc.completed_ids
            Docs.update doc._id,
                $pull: completed_ids: Meteor.userId()
                $inc: completed_count: -1
        else
            Docs.update doc._id,
                $addToSet: completed_ids: Meteor.userId()
                $inc: completed_count: 1
    
    
    bookmark: (doc)->
        if doc.bookmarked_ids and Meteor.userId() in doc.bookmarked_ids
            Docs.update doc._id,
                $pull: bookmarked_ids: Meteor.userId()
                $inc: bookmarked_count: -1
        else
            Docs.update doc._id,
                $addToSet: bookmarked_ids: Meteor.userId()
                $inc: bookmarked_count: 1
    
    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'Username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username


if Meteor.isServer
    publishComposite 'ballot_docs', (selected_ballot_tags, limit=null, view_unvoted, view_upvoted, view_downvoted)->
        {
            find: ->
                self = @
                match = {}
                # match.tags = $all: selected_ballot_tags
                if view_unvoted 
                    match.$or =
                        [
                            upvoters: $nin: [@userId]
                            downvoters: $nin: [@userId]
                            ]
                if view_upvoted then match.upvoters = $in: [@userId]
                if view_downvoted then match.downvoters = $in: [@userId]
                
                if selected_ballot_tags.length > 0 then match.tags = $all: selected_ballot_tags
                match.type = 'ballot'
                # console.log view_mode
                
                if limit
                    Docs.find match, 
                        limit: limit
                else
                    Docs.find match
            children: [
                { find: (doc) ->
                    Meteor.users.find 
                        _id: doc.author_id
                    }
                ]    
        }

    Meteor.publish 'ballot_tags', (selected_tags, limit, view_unvoted, view_upvoted, view_downvoted)->
        
        self = @
        match = {}
        if view_unvoted 
            match.$or =
                [
                    upvoters: $nin: [@userId]
                    downvoters: $nin: [@userId]
                    ]
        if view_upvoted then match.upvoters = $in: [@userId]
        if view_downvoted then match.downvoters = $in: [@userId]

        # match.tags = $all: selected_tags
        match.type = 'ballot'
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        
        # console.log 'limit:', limit
        
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
            
            
            
    Meteor.publish 'unvoted_ballot_count', ->
        Counts.publish this, 'unpublished_lightbank_count', Docs.find(type: 'ballot', $or:[{upvoters: $in: [@userId]},{downvoters: $in: [@userId]} ])
        return undefined    # otherwise coffeescript returns a Counts.publish
    Meteor.publish 'voted_up_ballot_count', ->
        Counts.publish this, 'voted_up_ballot_count', Docs.find(type: 'ballot', upvoters: $in: [@userId])
        return undefined    # otherwise coffeescript returns a Counts.publish
    Meteor.publish 'voted_down_ballot_count', ->
        Counts.publish this, 'voted_down_ballot_count', Docs.find(type: 'ballot', downvoters: $in: [@userId])
        return undefined    # otherwise coffeescript returns a Counts.publish
    