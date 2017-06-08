if Meteor.isClient
    
    @selected_people_tags = new ReactiveArray []
    
    Template.people_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'people_tags', selected_people_tags.array()
    
    Template.people_cloud.helpers
        all_people_tags: ->
            user_count = Meteor.users.find(_id: $ne:Meteor.userId()).count()
            if 0 < user_count < 3 then People_tags.find({ count: $lt: user_count }, {limit:20}) else People_tags.find({}, limit:20)
            # People_tags.find()
    
        selected_people_tags: -> selected_people_tags.array()
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'big'
                when @index <= 10 then 'large'
                when @index <= 15 then ''
                when @index <= 20 then 'small'
                when @index <= 25 then 'tiny'
            return button_class
    
    
    Template.people_cloud.events
        'click .select_tag': -> selected_people_tags.push @name
        'click .unselect_tag': -> selected_people_tags.remove @valueOf()
        'click #clear_tags': -> selected_people_tags.clear()
