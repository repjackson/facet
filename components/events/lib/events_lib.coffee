# Events

FlowRouter.route '/events', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        # cloud: 'event_cloud'
        main: 'events'

FlowRouter.route '/event/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_event'

FlowRouter.route '/event/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        # main: 'event_page'
        main: 'event_page'

