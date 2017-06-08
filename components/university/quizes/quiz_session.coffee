if Meteor.isClient
    FlowRouter.route '/quiz/:quiz_slug/session/:session_id/', 
        name: 'edit_quiz_session'
        action: (params) ->
            BlazeLayout.render 'layout',
                # sub_nav: 'account_nav'
                main: 'quiz_session'

    Template.quiz_session.onCreated -> 
        @autorun => Meteor.subscribe 'quiz_by_slug', FlowRouter.getParam('quiz_slug')
        @autorun -> Meteor.subscribe('quiz_questions', selected_quiz_question_tags.array(), FlowRouter.getParam('quiz_slug'))
        @autorun -> Meteor.subscribe('quiz_session', FlowRouter.getParam('session_id'))
        @autorun => Meteor.subscribe('quiz_tags', selected_quiz_question_tags.array(), FlowRouter.getParam('quiz_slug'))

    Template.quiz_session.onRendered -> 
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000

    Template.results.onRendered -> 
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.results.helpers
        quiz_session: -> 
            quiz_session = Docs.findOne type: 'quiz_session'
            # console.log quiz_session
            # quiz_session
        
        sorted_results: -> 
            sorted_results = _.sortBy(@results, 'category_percent').reverse()
            # console.log sorted_results
            sorted_results
            
        progress_class: ->
            switch @category
                when 'green' then 'green' 
                when 'gold' then 'yellow' 
                when 'blue' then 'blue' 
                when 'orange' then 'orange' 
                else 'teal'

        
    Template.quiz_session.helpers
        quiz_session: -> Docs.findOne type: 'quiz_session'
        quiz: -> Docs.findOne type: 'quiz'
        questions: -> Docs.find type: 'question'
        # quiz_finished: -> Session.get 'quiz_finished'
        quiz_cloud_tags: -> Tags.find({})
        selected_quiz_question_tags: -> selected_quiz_question_tags.array()

        all_answered: ->
            session_doc = Docs.findOne FlowRouter.getParam('session_id')
            if session_doc
                ratings = session_doc.ratings
                rating_question_ids = []
                rating_question_ids.push rating.question_id for rating in ratings
                # console.log rating_question_ids
                unanswered_count = Docs.find(
                    type: 'quiz_question'
                    quiz_slug: FlowRouter.getParam('quiz_slug')
                    _id: $nin: rating_question_ids
                ).count()
                if unanswered_count is 0 then return true else return false


        unanswered_questions: ->
            session_doc = Docs.findOne FlowRouter.getParam('session_id')
            if session_doc
                ratings = session_doc.ratings
                rating_question_ids = []
                rating_question_ids.push rating.question_id for rating in ratings
                # console.log rating_parent_ids
                Docs.find
                    type: 'quiz_question'
                    quiz_slug: FlowRouter.getParam('quiz_slug')
                    _id: $nin: rating_question_ids
                
        answered_questions: ->
            session_doc = Docs.findOne FlowRouter.getParam('session_id')
            if session_doc
                ratings = session_doc.ratings
                rating_question_ids = []
                rating_question_ids.push rating.question_id for rating in ratings
                # console.log rating_parent_ids
                Docs.find
                    type: 'quiz_question'
                    quiz_slug: FlowRouter.getParam('quiz_slug')
                    _id: $in: rating_question_ids
    
    
    Template.quiz_session.events
        'click #calculate_answers': ->
            # Session.set 'quiz_finished', true
            session_id = FlowRouter.getParam('session_id')
            # Meteor.call 'calculate_life_assessment_answers', session_id
                
            Meteor.call 'calculate_life_quiz_answers', session_id
                
                
        'click #delete_session': ->
            session_id = FlowRouter.getParam('session_id')
            quiz_slug = FlowRouter.getParam('quiz_slug')

            self = @
            swal {
                title: 'Cancel Session?'
                text: 'This will clear all of the answers.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Nevermind'
                confirmButtonText: 'Cancel Session'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove session_id, ->
                    swal("Canceled", "Your session has been canceled.", "success")
                    FlowRouter.go("/quiz/#{quiz_slug}/view")
        
        'click #delete_results': ->
            session_id = FlowRouter.getParam('session_id')
            quiz_slug = FlowRouter.getParam('quiz_slug')

            self = @
            swal {
                title: 'Delete Results?'
                text: 'This will allow you to change answers and recalculate results.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete Results'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.update session_id,
                    $unset: results: ""
                Meteor.setTimeout ->
                    $('.ui.accordion').accordion('open', 0)
                , 1000
    

        'click .select_tag': -> selected_quiz_question_tags.push @name
        'click .unselect_tag': -> selected_quiz_question_tags.remove @valueOf()
        'click #clear_tags': -> selected_quiz_question_tags.clear()

Meteor.methods
    'delete_session': (session_id)->
        Docs.remove session_id
        
    'calculate_life_assessment_answers': (session_id)->
        for tag in ['finance', 'business']        
            ratings = Docs.find({
                type: 'rating',
                session_id: session_id
                tags: $in: [tag]
                }).fetch()
            # console.log "ratings for #{tag}",ratings
            tag_score = 0    
            for rating in ratings
                tag_score += rating.rating
            # console.log tag_score
                
            Docs.update session_id,
                $addToSet:
                    results:    
                        category: tag
                        category_score: tag_score
                        category_percent: tag_score*10
                        
    'calculate_life_quiz_answers': (session_id)->
        session_doc = Docs.findOne session_id
        
        quiz_tags = _.pluck(session_doc.ratings, 'tags')
        flattened_tags = _.flatten(quiz_tags)
        unique = _.uniq flattened_tags
        # console.log session_doc.ratings
        
        # calculated_results
        
        for unique_tag in unique #money, mindset, etc
            tag_score = 0    
            for rating in session_doc.ratings 
                if _.indexOf(rating.tags, unique_tag) is 0
                    tag_score += rating.rating
            Docs.update session_id,
                $addToSet:
                    results:    
                        category: unique_tag
                        category_score: tag_score
                        category_percent: tag_score*2

        
        # result = _.map(flattened_tags, (tag) ->
        #     length = _.reject(flattened_tags, (el) ->
        #         el.id.indexOf(tag) < 0
        #         ).length
        #     {
        #         id: tag
        #         count: length
        #     }
        # )

        # console.log result
        # for tag in ['finance', 'business']        
        #     ratings = Docs.find({
        #         type: 'rating',
        #         session_id: session_id
        #         tags: $in: [tag]
        #         }).fetch()
        #     # console.log "ratings for #{tag}",ratings
        #     tag_score = 0    
        #     for rating in ratings
        #         tag_score += rating.rating
        #     # console.log tag_score
                
        #     Docs.update session_id,
        #         $addToSet:
        #             results:    
        #                 category: tag
        #                 category_score: tag_score
        #                 category_percent: tag_score*10
                        
if Meteor.isServer
            # self = @
            # match = {}
            
            # match.type = 'rating'
            # match.session_id = session_id
            
            # life_assessment_results = Docs.aggregate [
            #     { $match: match }
            #     # { $project: tags: 1 }
            #     # { $unwind: '$tags' }
            #     # { $group: _id: '$tags', count: $sum: 1 }
            #     # { $sort: count: -1, _id: 1 }
            #     # { $limit: 100 }
            #     # { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # Docs.update session_id,
            #     $set:
            #         results: life_assessment_results


    publishComposite 'quiz_session', (session_id)->
        {
            find: -> Docs.find session_id
            children: [
                { find: (session) ->
                    Docs.find
                        type: 'rating'
                        session_id: session._id
                # children: [
                #     {
                #         find: (quiz) ->
                #             Docs.find
                #                 type: 'question'
                #                 quiz_slug: quiz._id
                #     }
                # ]    
                }
                { find: (session) ->
                    Meteor.users.find
                        _id: session.author_id
                # children: [
                #     {
                #         find: (quiz) ->
                #             Docs.find
                #                 type: 'question'
                #                 quiz_slug: quiz._id
                #     }
                # ]    
                }
            ]
        }            
