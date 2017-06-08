FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'
