if Meteor.isClient    
    # FlowRouter.route '/course/sol/module/:module_number', 
    #     name:'view_module'
    #     action: (params) ->
    #         BlazeLayout.render 'view_module',
    #             module_content: 'sections'
    
    FlowRouter.route '/course/sol/module/:module_number', 
        name: 'view_module'
        triggersEnter: [ (context, redirect) ->
            # console.log context
            if context.params.module_number is "1"
                redirect "/course/sol/module/#{context.params.module_number}/sections"
            else 
                redirect "/course/sol/module/#{context.params.module_number}/debrief"
        ]

    
    Template.view_module.onCreated ->
        # @autorun -> Meteor.subscribe 'module_by_course_slug', course_slug=FlowRouter.getParam('course_slug'), module_number=parseInt FlowRouter.getParam('module_number')
        @autorun -> Meteor.subscribe 'module_progress', parseInt FlowRouter.getParam('module_number')
        @autorun -> Meteor.subscribe 'module', parseInt FlowRouter.getParam('module_number')
        # @autorun -> Meteor.subscribe 'sol_modules'
        @autorun -> Meteor.subscribe 'module_downloads', FlowRouter.getParam('module_number')

    Template.view_module.onRendered ->
        self = @
        if @subscriptionsReady()
            @autorun =>
            # console.log Session.get 'section_number'
                Meteor.setTimeout ->
                    $('.ui.accordion').accordion()            
                    module_number = if Session.get('module_number') then Session.get('module_number') else parseInt FlowRouter.getParam('module_number')
                    # console.log module_number
                    module_progress_doc =  Docs.findOne(tags: $all: ["sol", "module progress","module #{module_number}"])
                    # console.log module_progress_doc
                    if module_progress_doc
                        $('#module_percent_complete_bar').progress(
                            percent: module_progress_doc.module_progress_percent
                            autoSuccess: false
                            );
                , 1000

    
    Template.view_module.helpers
        is_first_module: -> FlowRouter.getParam('module_number') is '1'
    
        module_number: -> FlowRouter.getParam('module_number')
    
        title_tags: ->
            "sol,module #{FlowRouter.getParam('module_number')},title"
    
        module: -> 
            Docs.findOne 
                tags: $in: ['module']
                number: parseInt FlowRouter.getParam('module_number')
            
        download_count: ->
            module_number = FlowRouter.getParam('module_number')
            Docs.find(tags: $all: ["sol", "module #{module_number}", "download"]).count()
            
        module_progress_doc: ->
            module_number = FlowRouter.getParam('module_number')
            module_progress_doc = Docs.findOne
                tags: ['sol', "module #{module_number}", 'module progress']
                author_id: Meteor.userId()
            # if module_progress_doc then alert 'hi' else alert 'no'
            # module_progress_doc
        previous_module: ->
            module_number = parseInt FlowRouter.getParam('module_number')

            previous_module_number = module_number - 1
            Docs.findOne
                tags: ['module']
                number: previous_module_number
                
        next_module: ->
            module_number = parseInt FlowRouter.getParam('module_number')
            next_module_number = module_number + 1
            Docs.findOne
                tags: $in: ['module']
                number: next_module_number
            



        # module_sections_complete: ->
        #     module_number = parseInt FlowRouter.getParam('module_number')
        #     module_progress_doc = 
        #         Docs.findOne
        #             tags: $all: ['sol', "module #{module_number}", 'module progress']
        #             author_id: Meteor.userId()
        #     if module_progress_doc 
        #         module_progress_doc.module_progress_percent is 100
        #     else
        #         Meteor.call 'calculate_module_progress', module_number
        
        next_module_number: -> parseInt(FlowRouter.getParam('module_number')) + 1
    
        next_module_exists: ->
            next_module_number = parseInt(FlowRouter.getParam('module_number')) + 1
            module_number = parseInt FlowRouter.getParam('module_number')

            next_module_doc = 
                Docs.findOne
                    tags: ['module']
                    number: next_module_number
                    module_number: module_number
            if next_module_doc then true else false
    
    
    
    Template.view_module.events
        'click .edit': ->
            module_number = FlowRouter.getParam('module_number')
            course_slug = FlowRouter.getParam('course_slug')
            FlowRouter.go "/course/#{course_slug}/module/#{@_id}/edit"
    
        'click #calculate_module_progress': ->
            Meteor.call 'calculate_module_progress', parseInt(FlowRouter.getParam('module_number')), (err,res)->
                # console.log res
                $('#module_percent_complete_bar').progress('set percent', res);
                # console.log $('#module_percent_complete_bar').progress('get percent');


    Template.user_module_progress_list.onRendered ->
        Meteor.setTimeout ->
            $('.progress').progress();
        , 1000

    Template.user_module_progress_list.onCreated ->
        @autorun -> Meteor.subscribe 'user_module_progress_docs', parseInt FlowRouter.getParam('module_number')

    Template.user_module_progress_list.helpers
        user_progress_docs: ->
            module_number = FlowRouter.getParam('module_number')
            Docs.find {
                tags: $all: ['sol', "module #{module_number}", "module progress"]
            },
            sort: module_progress_percent: 1
    
if Meteor.isServer
    Meteor.publish 'module', (module_number)->
        Docs.find
            tags: $in: ['module']
            number: module_number
            
    Meteor.publish 'module_progress', (module_number)->
        Docs.find
            tags: $all: ['sol', "module #{module_number}", "module progress"]
            author_id: @userId
            
            
    publishComposite 'user_module_progress_docs', (module_number)->
        {
            find: ->
                Docs.find
                    tags: $all: ['sol', "module #{module_number}", "module progress"]
            children: [
                { 
                    find: (progress_doc) ->
                        Meteor.users.find
                            _id: progress_doc.author_id
                }
            ]
        }    
        
            
    Meteor.methods
        'calculate_module_progress': (module_number)->
            module_progress_doc = 
                Docs.findOne
                    tags: ['sol', "module #{module_number}", 'module progress']
                    author_id: Meteor.userId()

            # console.log module_progress_doc


            module_section_count = 
                Docs.find( 
                    tags: $in: ['section']
                    module_number: module_number
                ).count()
        
            # console.log module_section_count
            
            # for module_number in module_section_count
            #     console.log module_number
            
            module_progress = 0
            
            module_doc = Docs.findOne
                tags: $in: ['module']
                number: module_number


            # 
            # debrief
            # 
                
            debrief_questions = 
                Docs.find(
                    tags: $all: ['debrief', 'question']
                    parent_id: module_doc._id
                ).fetch()
                
                
            debrief_question_count = 
                Docs.find(
                    tags: $all: ['debrief', 'question']
                    parent_id: module_doc._id
                ).count()
            # console.log debrief_question_count
            
            module_chunk_size = if debrief_question_count then 100/3 else 50

            
            debrief_answer_count = 0
            for debrief_question in debrief_questions
                # console.log debrief_question
                debrief_answer = Docs.findOne
                    tags: $in: ['answer']
                    parent_id: debrief_question._id
                    author_id: Meteor.userId()

                if debrief_answer then debrief_answer_count++
                
            # console.log debrief_answer_count
            if debrief_answer_count is debrief_question_count
                module_debrief_complete = true
            else
                module_debrief_complete = false
            if debrief_question_count
                debrief_answered_fraction = debrief_answer_count/debrief_question_count
                debrief_adding_amount = debrief_answered_fraction * module_chunk_size
                module_progress += debrief_adding_amount
            
            # console.log 'module_progress', module_progress
            # console.log 'debrief_adding_amount', debrief_adding_amount
            
            

            # 
            # lightwork
            # 
                
            lightwork_questions = 
                Docs.find(
                    tags: $all: ['lightwork', 'question']
                    parent_id: module_doc._id
                ).fetch()
                
                
            lightwork_question_count = 
                Docs.find(
                    tags: $all: ['lightwork', 'question']
                    parent_id: module_doc._id
                ).count()
            # console.log lightwork_question_count
            
            lightwork_answer_count = 0
            for lightwork_question in lightwork_questions
                # console.log lightwork_question
                lightwork_answer = Docs.findOne
                    tags: $in: ['answer']
                    parent_id: lightwork_question._id
                    author_id: Meteor.userId()
                if lightwork_answer then lightwork_answer_count++
                
            console.log lightwork_answer_count
            if lightwork_answer_count is lightwork_question_count
                module_lightwork_complete = true
            else
                module_lightwork_complete = false
            
            lightwork_answered_fraction = lightwork_answer_count/lightwork_question_count
            # console.log 'lightwork_answered_fraction', lightwork_answered_fraction
            lightwork_adding_amount = lightwork_answered_fraction * module_chunk_size
            # console.log 'lightwork_adding_amount', lightwork_adding_amount
            
            module_progress += lightwork_adding_amount
            
            # console.log 'module_progress', module_progress
            # console.log 'lightwork_adding_amount', lightwork_adding_amount
            
            
            # 
            # sections
            # 
            
            module_section_progress_increment = module_chunk_size/module_section_count
            # console.log module_section_progress_increment
            section_complete_count = 0
            for section_number in [1..module_section_count]
                section_progress_doc = 
                    Docs.findOne
                        tags: ['sol', "module #{module_number}", "section #{section_number}", 'section progress']
                        author_id: Meteor.userId()
                if section_progress_doc then section_complete_count++
                if section_progress_doc
                    adding_amount = section_progress_doc.percent_complete*.01*module_section_progress_increment
                module_progress += adding_amount
                
                
                
            if section_complete_count is module_section_count
                module_sections_complete = true
            else
                module_sections_complete = false
                
                
            if module_sections_complete and module_lightwork_complete and module_debrief_complete
                # console.log 'hi'
                module_progress = 100
                
            # console.log module_sections_complete
            # Docs.update module_progress_doc._id, 
            #     module_progress_percent: module_progress
                
            update_result = Docs.update { 
                tags: ['sol', "module #{module_number}", 'module progress']
                author_id: Meteor.userId() 
            },
            { $set: 
                module_progress_percent: module_progress
                module_section_count: module_section_count
                section_complete_count: section_complete_count
                module_sections_complete: module_sections_complete
                debrief_question_count: debrief_question_count
                debrief_answer_count: debrief_answer_count
                module_debrief_complete: module_debrief_complete
                lightwork_question_count: lightwork_question_count
                lightwork_answer_count: lightwork_answer_count
                module_lightwork_complete: module_lightwork_complete
                
                },
            { upsert: true }
    
            # console.log module_progress
    
            return module_progress