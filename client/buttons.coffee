Template.voting.helpers
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @upvoters and Meteor.userId() in @upvoters then 'green'
        else 'outline'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @downvoters and Meteor.userId() in @downvoters then 'red'
        else 'outline'

Template.voting.events
    'click .vote_up': (e,t)-> 
        if Meteor.userId()
            Meteor.call 'vote_up', @_id
            $(e.currentTarget).closest('.vote_up').transition('pulse')
        else FlowRouter.go '/sign-in'

    'click .vote_down': -> 
        if Meteor.userId() then Meteor.call 'vote_down', @_id
        else FlowRouter.go '/sign-in'


Template.big_both_voter.helpers
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @upvoters and Meteor.userId() in @upvoters then 'green'
        else 'outline'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @downvoters and Meteor.userId() in @downvoters then 'red'
        else 'outline'

Template.big_both_voter.events
    'click .vote_up': (e,t)-> 
        if Meteor.userId() 
            Meteor.call 'vote_up', @_id
            # $(e.currentTarget).closest('.vote_up').transition('pulse')
        else FlowRouter.go '/sign-in'

    'click .vote_down': (e,t)-> 
        if Meteor.userId() 
            Meteor.call 'vote_down', @_id
            # $(e.currentTarget).closest('.vote_down').transition('pulse')
        else FlowRouter.go '/sign-in'



Template.toggle_friend.helpers
    is_friend: -> if Meteor.user()?.friends then @_id in Meteor.user().friends
        
Template.toggle_friend.events
    'click #add_friend': (e,t)-> 
        Meteor.users.update Meteor.userId(), $addToSet: friends: @_id
        $(e.currentTarget).closest('#add_friend').transition('pulse')

    'click #remove_friend': (e,t)-> 
        Meteor.users.update Meteor.userId(), $pull: friends: @_id
        $(e.currentTarget).closest('#remove_friend').transition('pulse')


Template.published.events
    'click #publish': -> Docs.update @_id, $set: published: true
    'click #unpublish': -> Docs.update @_id, $set: published: false


Template.edit_button.onCreated ->
    @editing = new ReactiveVar(false)
Template.edit_button.helpers
    editing: -> Template.instance().editing.get()
Template.edit_icon.onCreated ->
    @editing = new ReactiveVar(false)
Template.edit_icon.helpers
    editing: -> Template.instance().editing.get()
Template.edit_link.onCreated ->
    @editing = new ReactiveVar(false)
Template.edit_link.helpers
    editing: -> Template.instance().editing.get()

Template.edit_button.events
    'click .edit_this': (e,t)-> 
        # console.log t.editing
        t.editing.set true
    'click .save_doc': (e,t)-> 
        # console.log t.editing
        t.editing.set false



Template.session_edit_button.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_button.helpers
    button_classes: -> Template.currentData().classes

Template.session_edit_icon.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_icon.helpers
    button_classes: -> Template.currentData().classes


Template.edit_icon.events
    'click .edit_this': (e,t)-> 
        console.log t.editing
        t.editing.set true
    'click .save_doc': (e,t)-> 
        console.log t.editing
        t.editing.set false
Template.edit_link.events
    'click .edit_this': (e,t)-> 
        console.log t.editing
        t.editing.set true
    'click .save_doc': (e,t)-> 
        console.log t.editing
        t.editing.set false


Template.rating.onRendered ->
    # console.log 'template data', @data
    self = @
    
    @autorun =>
        if @subscriptionsReady()
            session_id = FlowRouter.getParam('session_id')
            existing_rating =         
                Docs.findOne
                    parent_id: self.data._id
                    type: 'rating'
                    session_id: session_id
            # console.log 'existing rating', existing_rating
            if existing_rating then initial_rating = existing_rating.rating
            else initial_rating = 0
            # console.log initial_rating
            Meteor.setTimeout ->
                $('.ui.rating').rating
                    # initialRating: initial_rating,
                    maxRating: 5
                    # onRate: (value)->
                    #     console.log value
            , 2000
            # console.log 'subs ready'
Template.rating.helpers
    question_rating: ->
        session_doc = Docs.findOne FlowRouter.getParam('session_id')
        if session_doc
            rating = _.findWhere(session_doc.ratings, {question_id: @_id})?.rating
            rating
# Template.rank.helpers
#     rank_doc: ->
#         rank_doc = 
#             Docs.findOne
#                 parent_id: @_id
#                 type: 'rank'
#                 author_id: Meteor.userId()
#         rank_doc
            
#     button_class: ->
        

# Template.rank.events
#     'click #increase_index': ->
#         rank_doc = 
#             Docs.findOne
#                 parent_id: @_id
#                 type: 'rank'
#                 author_id: Meteor.userId()
#                 group: 'personality_colors'
#         if rank_doc
#             Docs.update rank_doc._id, 
#                 $inc: number: 1
#             one_up = rank_doc.number + 1
#             existing_rank_doc = 
#                 Docs.findOne
#                     type: 'rank'
#                     author_id: Meteor.userId()
#                     number: one_up
#                     group: 'personality_colors'
#             console.log existing_rank_doc
#             if existing_rank_doc
#                 Docs.update existing_rank_doc._id,
#                     $inc: number: -1
#         else
#             Docs.insert
#                 type: 'rank'
#                 parent_id: @_id
#                 number: 1
#                 group: 'personality_colors'
Template.rating.events
    'click .rating': (e,t)->
        session_id = FlowRouter.getParam('session_id')
        rating = $(e.currentTarget).closest('.rating').rating('get rating')
        if Docs.findOne({_id: session_id, 'ratings.question_id': @_id})
            # alert @_id, ' found'
            # alert rating
            Meteor.call 'update_rating', session_id, rating, @_id
        else
            # alert 'rating not found'
            $(e.currentTarget).closest('.ui.card').transition('horizontal flip')
            Meteor.setTimeout =>
                Docs.update {_id:session_id},
                    $addToSet:
                        ratings:
                            rating: rating
                            question_id: @_id
                            tags: @tags
            , 250







# doc version
# Template.rating.events
#     'click .rating': (e,t)->
#         session_id = FlowRouter.getParam('session_id')
#         rating = $(e.currentTarget).closest('.rating').rating('get rating')
#         rating_doc = 
#             Docs.findOne
#                 parent_id: @_id
#                 type: 'rating'
#                 session_id: session_id
#         if rating_doc
#             new_tags = @tags
#             new_tags.push 'rating'

#             Docs.update rating_doc._id, 
#                 $set: 
#                     rating: rating
#                     tags: new_tags
#         else
#             new_tags = @tags
#             new_tags.push 'rating'
#             Docs.insert
#                 type: 'rating'
#                 parent_id: @_id
#                 tags: new_tags
#                 rating: rating
#                 session_id: session_id

Template.delete_button.events
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
Template.delete_link.events
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


Template.favorite_button.helpers
    favorite_count: -> @favorite_count
    
    favorite_item_class: -> 
        if Meteor.userId()
            if @favoriters and Meteor.userId() in @favoriters then 'red' else 'outline'
        else 'grey disabled'
Template.favorite_button.events
    'click .favorite_item': (e,t)-> 
        if Meteor.userId()
            Meteor.call 'favorite', Template.parentData(0)
            $(e.currentTarget).closest('.favorite_item').transition('pulse')

        else FlowRouter.go '/sign-in'


Template.resonate_button.helpers
    resonate_button_class: -> 
        if Meteor.userId()
            if @favoriters and Meteor.userId() in @favoriters then 'teal' else 'basic'
        else 'grey disabled'
Template.resonate_button.events
    'click .resonate_button': (e,t)-> 
        if Meteor.userId() 
            Meteor.call 'favorite', Template.parentData(0)
            $(e.currentTarget).closest('.resonate_button').transition('pulse')
        else FlowRouter.go '/sign-in'





Template.mark_complete_button.helpers
    complete_button_class: -> 
        if Meteor.user()
            if @completed_ids and Meteor.userId() in @completed_ids then 'teal' else 'basic'
        else 'grey disabled'
    completed: -> 
        if Meteor.user()
            if @completed_ids and Meteor.userId() in @completed_ids then true else false
        else false
Template.mark_complete_button.events
    'click .mark_complete': (e,t)-> 
        if Meteor.userId() 
            Meteor.call 'mark_complete', Template.parentData(0)
            $(e.currentTarget).closest('.mark_complete').transition('pulse')
        else FlowRouter.go '/sign-in'


Template.mark_doc_complete_button.helpers
    complete_button_class: -> if @complete then 'active' else 'basic'
Template.mark_doc_complete_button.events
    'click .mark_complete': (e,t)-> 
        if @complete is true then Docs.update @_id, $set: complete: false else  Docs.update @_id, $set:complete: true



Template.bookmark_button.helpers
    bookmark_button_class: -> 
        if Meteor.user()
            if @bookmarked_ids and Meteor.userId() in  @bookmarked_ids then 'teal' else 'basic'
        else 'grey disabled'
        
    bookmarked: -> Meteor.user()?.bookmarked_ids and @_id in Meteor.user().bookmarked_ids
Template.bookmark_button.events
    'click .bookmark_button': (e,t)-> 
        if Meteor.userId() 
            Meteor.call 'bookmark', Template.parentData(0)
            $(e.currentTarget).closest('.bookmark_button').transition('pulse')
        else FlowRouter.go '/sign-in'


Template.featured.events
    'click #make_featured': -> Docs.update FlowRouter.getParam('doc_id'), $set: featured: true
    'click #make_unfeatured': -> Docs.update FlowRouter.getParam('doc_id'), $set: featured: false


Template.add_to_cart.onCreated ->
    @autorun => Meteor.subscribe 'cart'

Template.add_to_cart.events
    'click #add_to_cart': (e,t)-> 
        # console.log t.data.tags
        # Session.set 'cart_item', @_id
        # FlowRouter.go '/cart'
        if Meteor.userId() then Meteor.call 'add_to_cart', @_id, =>
            Bert.alert "#{@title} Added to Cart", 'success', 'growl-top-right'
        else FlowRouter.go '/sign-in'

    'click #remove_from_cart': ->
        Meteor.call 'remove_from_cart', @_id, =>
            Bert.alert "#{@title} Removed from Cart", 'info', 'growl-top-right'
        
Template.add_to_cart.helpers
    added: ->
        Docs.findOne 
            type: 'cart_item'
            parent_id: @_id
            author_id: Meteor.userId()