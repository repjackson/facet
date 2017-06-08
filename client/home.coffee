FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'docs'


