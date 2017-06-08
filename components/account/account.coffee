FlowRouter.route '/account', action: (params) ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        main: 'account'