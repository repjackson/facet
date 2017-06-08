FlowRouter.route '/course/sol/members', 
    name: 'course_members'
    action: (params) ->
        BlazeLayout.render 'view_course',
            course_content: 'course_members'
            
@selected_course_member_tags = new ReactiveArray []
            

Template.course_members.onCreated ->
    @autorun -> Meteor.subscribe 'sol_members', selected_course_member_tags.array()
    @autorun -> Meteor.subscribe 'course_member_tags', selected_course_member_tags.array()
    
Template.course_members.helpers
    course_member_tags: ->
        user_count = Meteor.users.find(_id: $ne:Meteor.userId()).count()
        if 0 < user_count < 3 then People_tags.find({ count: $lt: user_count }, {limit:20}) else People_tags.find({}, limit:20)
        # People_tags.find()

    selected_course_member_tags: -> selected_course_member_tags.array()

    cloud_tag_class: ->
        button_class = switch
            when @index <= 5 then 'big'
            when @index <= 10 then 'large'
            when @index <= 15 then ''
            when @index <= 20 then 'small'
            when @index <= 25 then 'tiny'
        return button_class


    course_members: ->
        Meteor.users.find
            roles: $in: ['sol', 'sol_demo']
            _id: $ne: Meteor.userId()
            username: $ne: 'admin'



Template.course_members.events
    'click .select_tag': -> selected_course_member_tags.push @name
    'click .unselect_tag': -> selected_course_member_tags.remove @valueOf()
    'click #clear_tags': -> selected_course_member_tags.clear()

Template.course_member.onRendered ->
    $('.profile.image').dimmer({
        on: 'hover'
      })



Template.course_member.events
    'click .user_tag': ->
        if @valueOf() in selected_course_member_tags.array() then selected_course_member_tags.remove @valueOf() else selected_course_member_tags.push @valueOf()

Template.course_member.helpers
    seven_tags: -> if @tags then @tags[..6]

    member_tag_class: -> if @valueOf() in selected_course_member_tags.array() then 'blue' else 'basic'