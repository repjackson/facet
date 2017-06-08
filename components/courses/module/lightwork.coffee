if Meteor.isClient
    FlowRouter.route '/course/sol/module/:module_number/lightwork', 
        name: 'lightwork'
        action: (params) ->
            BlazeLayout.render 'view_module',
                module_content: 'lightwork'
    
    
    
    Template.lightwork.onRendered ->
        @autorun =>
            if @subscriptionsReady()
                Meteor.setTimeout ->
                    $('.ui.accordion').accordion()
                , 1000
    
    
                
    Template.lightwork.helpers
        module: -> 
            Docs.findOne 
                tags: $in: ['module']
                number: parseInt FlowRouter.getParam('module_number')
    
            
        lightwork_tags: ->
            "sol,module #{FlowRouter.getParam('module_number')},lightwork"
            
        lightwork_transcript_tags: ->
            "sol,module #{FlowRouter.getParam('module_number')},lightwork,transcript"
