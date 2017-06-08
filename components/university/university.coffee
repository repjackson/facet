FlowRouter.route '/university', action: ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        sub_sub_nav: 'inspire_u_nav'
        main: 'university'

FlowRouter.route '/iu/decks', action: ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        sub_sub_nav: 'inspire_u_nav'
        main: 'decks'

FlowRouter.route '/iu/excercises', action: ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        sub_sub_nav: 'inspire_u_nav'
        main: 'excercises'


# FlowRouter.route '/iu/courses', action: ->
#     BlazeLayout.render 'layout',
#         sub_nav: 'account_nav'
#         sub_sub_nav: 'inspire_u_nav'
#         main: 'courses'
