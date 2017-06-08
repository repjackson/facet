Template.featured_events.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'featured_events'


Template.featured_events.helpers
    featured_events: -> 
        Docs.find {
            featured: true
            published: true
            type: 'event'
        }, 
            sort: start_datetime: 1
            limit: 4
        
Template.featured_event.helpers
    day: -> moment(@start_datetime).format("dddd, MMMM Do")
    start_time: -> moment(@start_datetime).format("h:mm a")
    end_time: -> moment(@end_datetime).format("h:mm a")


Template.featured_events.events
    'click .featured_event_title': ->
        FlowRouter.go "/events/#{@_id}"

