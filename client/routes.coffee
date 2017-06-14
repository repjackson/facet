FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'

FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'docs'


