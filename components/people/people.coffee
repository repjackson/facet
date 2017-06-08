FlowRouter.route '/people', action: (params) ->
    BlazeLayout.render 'layout',
        # sub_nav: 'account_nav'
        main: 'people'


if Meteor.isClient
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('people', selected_people_tags.array())
    Template.person.onCreated ->
        @autorun -> Meteor.subscribe('person', @_id)
    
    
    Template.people.helpers
        people: -> 
            Meteor.users.find { _id: $ne: Meteor.userId() }, 
            # Meteor.users.find { }, 
                sort:
                    tag_count: 1
                limit: 10
    
    
    Template.person.events
        'click .user_tag': ->
            if @valueOf() in selected_people_tags.array() then selected_people_tags.remove @valueOf() else selected_people_tags.push @valueOf()
    
    Template.person.helpers
        ten_tags: -> if @tags then @tags[..6]
    
        person_tag_class: -> if @valueOf() in selected_people_tags.array() then 'teal' else 'basic'
