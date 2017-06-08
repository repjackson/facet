if Meteor.isClient
    FlowRouter.route '/course/sol/module/:module_number/sections', 
        name: 'sections'
        action: (params) ->
            BlazeLayout.render 'view_module',
                module_content: 'sections'
    
    Template.sections.onCreated ->
        @autorun -> Meteor.subscribe 'sections', parseInt FlowRouter.getParam('module_number')


    Template.section.onRendered ->
        self = @
        
        @autorun =>
            Meteor.setTimeout ->
                section_progress_doc =  Docs.findOne(tags: $in: ["section progress"])
                # console.log section_progress_doc
                $('.section_percent_complete_bar').progress(
                    autoSuccess: false
                    );
            , 1000








    Template.section.onCreated ->
        @editing = new ReactiveVar(false)

    Template.section.helpers
        editing: -> Template.instance().editing.get()

        user_progress: ->
            section_progress_doc = 
                Docs.findOne(tags: $all: ["section #{@number}", "section progress"])
            if section_progress_doc
                section_progress_doc.percent_complete
            else
                0
        section_progress_doc: -> 
            progress_doc = Docs.findOne(tags: $all: ["section #{@number}", "section progress"])
            # console.log progress_doc
            progress_doc
            
        section_is_available: ->
            if Roles.userIsInRole(Meteor.userId(), 'admin') then true
            else if @number is 1 then true
            else
                previous_section_number = @number - 1
                previous_section_progress_doc = 
                    Docs.findOne(tags: $all: ["section #{previous_section_number}", "section progress"])
                if previous_section_progress_doc and previous_section_progress_doc.percent_complete is 100 then true else false

    Template.sections.helpers
        sections: ->
            Docs.find {
                tags: $all: ['section'] },
                sort: number: 1
                
    Template.sections.events
        'click #add_section': ->
            module_number = parseInt FlowRouter.getParam('module_number')
            Docs.insert
                tags: ['section']
                module_number: module_number
                
    Template.section.events
        'click .edit_this': (e,t)-> 
            # console.log t.editing
            t.editing.set true
        'click .save_doc': (e,t)-> 
            # console.log t.editing
            t.editing.set false
        
        # 'mouseover .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse')

                
        # 'mouseover .header': (e,t)->
        #     $(e.currentTarget).closest('.header').transition('tada')

                
                
                
                
if Meteor.isServer
    publishComposite 'sections', (module_number)->
        {
            find: ->
                Docs.find
                    tags: ['section']
                    module_number: module_number
            children: [
                { find: (section) ->
                    Docs.find 
                        tags: $all: ['sol', "module #{module_number}","section progress"]
                        author_id: @userId
                    }
                ]    
        }
            
            
