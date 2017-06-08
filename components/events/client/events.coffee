
    
Template.events.events
    'keydown #import_eventbrite': (e,t)->
        e.preventDefault
        if e.which is 13
            event_id = t.find('#import_eventbrite').value.trim()
            if event_id.length > 0
                # console.log 'attemping to add event with id ', event_id
                Meteor.call 'import_eventbrite', event_id, (err,res)->
                    t.find('#import_eventbrite').value = ''
                    console.log res

    'click #add_event': ->
        id = Docs.insert 
            type: 'event'
        FlowRouter.go "/event/edit/#{id}"




Template.events.onCreated -> @autorun -> Meteor.subscribe('selected_events', selected_tags.array())
# Template.admin_events.onCreated -> @autorun -> Meteor.subscribe('all_events')
# Template.upcoming_events.onCreated -> @autorun -> Meteor.subscribe('upcoming_events', selected_tags.array())
# Template.past_events.onCreated -> @autorun -> Meteor.subscribe('past_events', selected_tags.array())

Template.upcoming_events.helpers
    upcoming_events: -> 
        today = new Date()
        today.setDate today.getDate() - 1
        # Docs.find {start_date: $gte: today.toISOString()}, sort: start_date: 1
        Docs.find { 
            type:'event'
            reoccurring: $ne: true
            published: $ne: false
            start_datetime: $gte: today.toISOString()
            }, 
            sort: start_datetime: 1

Template.admin_events.helpers
    admin_events: -> 
        Docs.find { 
            published: false
            }
            
Template.past_events.helpers
    past_events: -> 
        today = new Date()
        today.setDate today.getDate() - 1
        # Docs.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
        Docs.find { 
            type:'event'
            reoccurring: $ne: true
            published: $ne: false
            start_datetime: $lte: today.toISOString()
            }, 
            sort: start_datetime: 1
            
Template.reoccurring_events.helpers
    reoccurring_events: -> 
        today = new Date()
        # Docs.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
        Docs.find { 
            type:'event'
            reoccurring: true
            published: $ne: false
            # start_datetime: $gte: today.toISOString()
            }, 
            sort: start_datetime: 1
            

Template.events.helpers
    options: ->
        # defaultView: 'basicWeek'
        defaultView: 'month'



Template.event_card.helpers
    event_tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'

    day: -> moment(@start_datetime).format("dddd, MMMM Do");
    start_time: -> moment(@start_datetime).format("h:mm a")
    end_time: -> moment(@end_datetime).format("h:mm a")


Template.event_card.events
    # 'click .event_tag': ->
    #     if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()