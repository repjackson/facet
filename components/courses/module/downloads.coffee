if Meteor.isClient
    FlowRouter.route '/course/sol/module/:module_number/downloads', 
        name: 'downloads'
        action: (params) ->
            BlazeLayout.render 'view_module',
                module_content: 'downloads'
    
    
    
    Template.downloads.onCreated ->
        @autorun -> Meteor.subscribe 'module_downloads', FlowRouter.getParam('module_number')
        @autorun -> Meteor.subscribe 'module', parseInt FlowRouter.getParam('module_number')
    
    
    Template.downloads.helpers
        module: -> 
            Docs.findOne
                tags: $in: ["module"]
                number: parseInt FlowRouter.getParam('module_number')
                
        module_files: ->
            module_number = FlowRouter.getParam('module_number')
            Docs.find
                tags: $all: ["sol", "module #{module_number}", "download"]
            
                

    Template.downloads.events
        'click #add_file': (e,t)->
            module_number = FlowRouter.getParam('module_number')
            new_id = Docs.insert
                tags: ["sol","download", "module #{module_number}"]
            Session.set 'editing_id', new_id

if Meteor.isServer
    Meteor.publish 'module_downloads', (module_number)->
        Docs.find
            tags: $all:["sol", "module #{module_number}", "download"]