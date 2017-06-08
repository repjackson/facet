if Meteor.isClient
    FlowRouter.route '/quiz/:quiz_slug/view', 
        name: 'view_quiz'
        action: (params) ->
            BlazeLayout.render 'layout',
                # sub_nav: 'account_nav'
                main: 'quiz_page'
    
    @selected_quiz_question_tags = new ReactiveArray []
    
    Template.quiz_page.onCreated ->
        @autorun => Meteor.subscribe 'quiz_by_slug', FlowRouter.getParam('quiz_slug')
        @autorun => Meteor.subscribe 'quiz_sessions', FlowRouter.getParam('quiz_slug')
        @autorun => Meteor.subscribe 'quiz_questions', selected_quiz_question_tags.array(), FlowRouter.getParam('quiz_slug')
        @autorun => Meteor.subscribe('quiz_tags', selected_quiz_question_tags.array(), FlowRouter.getParam('quiz_slug'))
    
    Template.quiz_page.onRendered ->
        @autorun =>
            if @subscriptionsReady()
                Meteor.setTimeout ->
                    $('.ui.accordion').accordion()
                , 500
                # console.log 'subs ready'

    Template.quiz_page.helpers
        quiz_cloud_tags: -> Tags.find({})
        selected_quiz_question_tags: -> selected_quiz_question_tags.array()
        quiz: -> 
            Docs.findOne 
                slug: FlowRouter.getParam('quiz_slug')
    
        add_quiz_question_button_class: -> if selected_quiz_question_tags.array().length > 0 then 'active' else ''
    
        quiz_questions: ->
            if Session.get 'editing_id'
                Docs.find Session.get('editing_id')
            else
                Docs.find {
                    type: 'quiz_question'
                    quiz_slug: FlowRouter.getParam('quiz_slug')
                }, sort: number: 1
        my_sessions: ->
            Docs.find
                type: 'quiz_session'
                author_id: Meteor.userId()
                quiz_slug: FlowRouter.getParam('quiz_slug')
    
    Template.quiz_page.events
        'click #new_session': ->
            new_session_id = 
                Docs.insert
                    type: 'quiz_session'
                    quiz_slug: @slug
                    ratings: []
            FlowRouter.go("/quiz/#{@slug}/session/#{new_session_id}")
    
        'click .select_tag': -> selected_quiz_question_tags.push @name
        'click .unselect_tag': -> selected_quiz_question_tags.remove @valueOf()
        'click #clear_tags': -> selected_quiz_question_tags.clear()
        'click #add_quiz_question': ->
            new_tags = selected_quiz_question_tags.array()
            questions_with_tag = Docs.find(tags: $in: new_tags).fetch()
            question_numbers = _.pluck questions_with_tag, 'number'
            # console.log question_numbers
            max = _.max question_numbers
        
            new_id = Docs.insert
                type: 'quiz_question'
                tags: new_tags
                quiz_slug: FlowRouter.getParam('quiz_slug')
                number: max + 1
            Session.set 'editing_id', new_id


    Template.session_card.helpers
        sorted_results: -> _.sortBy(@results, 'category_percent').reverse()
        session_card_class: -> if @published then 'green' else ''
        
        
    Template.session_card.onRendered -> 
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.session_card.helpers
        progress_class: ->
            # console.log @
            switch @category
                when 'green' then 'green' 
                when 'gold' then 'yellow' 
                when 'blue' then 'blue' 
                when 'orange' then 'orange' 
                else 'teal'

if Meteor.isServer
    Meteor.publish 'quiz_sessions', (quiz_slug)->
        Docs.find
            type: 'quiz_session'
            quiz_slug: quiz_slug
            author_id: @userId
            
            
    Meteor.publish 'quiz_by_slug', (quiz_slug)->
        Docs.find
            type: 'quiz'
            slug: quiz_slug
            
            
            
    Meteor.publish 'quiz_tags', (selected_tags, quiz_slug)->
        self = @
        match = {}
        
        match.type = 'quiz_question'
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.quiz_slug = quiz_slug        
        
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            # { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
                
