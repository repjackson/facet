FlowRouter.route '/support', action: ->
    BlazeLayout.render 'layout',
        main: 'support'

Template.support.onCreated ->
    @autorun -> Meteor.subscribe('my_tickets')

Template.support.helpers
    my_tickets: -> 
        Docs.find {
            type: 'support_ticket'
            author_id: Meteor.userId()
            },
            sort:
                timestamp: -1
            
            
Template.support.events
    'click #submit_ticket': ->
        body = $('#ticket_body').val()
        Docs.insert
            body: body
            type: 'support_ticket'
            , =>
                swal {
                    title: "Thank you, #{Meteor.user().username}."
                    text: "We'll be in touch soon."
                    type: 'success'
                    animation: true
                    timer: 2000
                    # confirmButtonColor: '#DD6B55'
                }
                $('#ticket_body').val('')
    
Template.ticket.helpers

Template.ticket.events

