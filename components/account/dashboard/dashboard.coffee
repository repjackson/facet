if Meteor.isClient
    FlowRouter.route '/dashboard', action: (params) ->
        BlazeLayout.render 'layout',
            sub_nav: 'account_nav'
            main: 'dashboard'
    
    
    Template.dashboard.events
        'click #lightbank': ->
            Session.set 'lighbank_view_mode', 'resonates'
            FlowRouter.go '/lightbank'
            
        'click #courses': ->
            Session.set 'view_mode', 'mine'
            FlowRouter.go '/courses'
            
        'click #lightbank': ->
            Session.set 'lighbank_view_mode', 'resonates'
            FlowRouter.go '/lightbank'
            
        'click #lightbank': ->
            Session.set 'lighbank_view_mode', 'resonates'
            FlowRouter.go '/lightbank'
            
            
        