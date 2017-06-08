if Meteor.isClient
    FlowRouter.route '/colors', action: (params) ->
        BlazeLayout.render 'layout',
            sub_nav: 'account_nav'
            main: 'colors'
    
    
    
    Template.colors.onCreated -> 
        @autorun -> Meteor.subscribe('personality_colors')

    Template.colors.helpers
        color_icon_class: ->
            icon_class = switch @title
                when 'Gold' then 'yellow' 
                when 'Blue' then 'blue' 
                when 'Green' then 'green' 
                when 'Orange' then 'orange'
            icon_class

        can_increase: ->
            if Meteor.user()
                colors =  Meteor.user().profile.colors
                index = colors.indexOf @valueOf() 
                index > 0
        
        can_decrease: ->
            if Meteor.user()
                colors =  Meteor.user().profile.colors
                index = colors.indexOf @valueOf() 
                index < 3

    Template.colors.events
        'click #add_color': ->
            id = Docs.insert type: 'personality_color'
            FlowRouter.go "/edit/#{id}"

        'click .increase_index': (e,t)->
            if Meteor.user().profile.colors
                colors = Meteor.user().profile.colors
                current_index = colors.indexOf @valueOf() 
                new_index = current_index - 1
        	    colors.splice(new_index, 0, colors.splice(current_index, 1)[0] )
        	    Meteor.users.update Meteor.userId(),
        	        $set: "profile.colors": colors
                $(e.currentTarget).closest('.ui.card').transition('shake')

            
        'click .decrease_index': (e,t)->
            if Meteor.user().profile.colors
                colors = Meteor.user().profile.colors
                current_index = colors.indexOf @valueOf() 
                new_index = current_index + 1
        	    colors.splice(new_index, 0, colors.splice(current_index, 1)[0] )
        	    Meteor.users.update Meteor.userId(),
        	        $set: "profile.colors": colors
                $(e.currentTarget).closest('.ui.card').transition('shake')

            
        'click #generate_colors': ->
            Meteor.users.update Meteor.userId(),
                $set:
                    "profile.colors": ['gold', 'green', 'blue', 'orange']


    Template.color_dots.onRendered ->
        @autorun =>
            if @subscriptionsReady()
                Meteor.setTimeout ->
                    $('.icon').popup()
                , 500
                # console.log 'subs ready'
    
    Template.tiny_color_dots.onRendered ->
        @autorun =>
            if @subscriptionsReady()
                Meteor.setTimeout ->
                    $('.icon').popup()
                , 500
                # console.log 'subs ready'

    Template.colors.onRendered ->
        @autorun =>
            if @subscriptionsReady()
                Meteor.setTimeout ->
                    $('.ui.accordion').accordion()
                , 500
                # console.log 'subs ready'



    Template.tiny_color_dots.helpers
        user: ->
            console.log @profile.colors
    
        color_icon_class: ->
            # console.log Template.currentData()
            icon_class = switch @valueOf()
                when 'gold' then 'yellow' 
                when 'blue' then 'blue' 
                when 'green' then 'green' 
                when 'orange' then 'orange'
            icon_class

        color_data_title: ->
            title = switch @valueOf()
                when 'gold' then 'Gold' 
                when 'blue' then 'Blue' 
                when 'green' then 'Green' 
                when 'orange' then 'Orange'
            title

            
        color_data_content: ->
            content = switch @valueOf()
                when 'gold' 
                    "Loyal, Dependable, Prepared <br>
                    Thorough, Sensible, Punctual <br>"
                    # Faithful, Stable, Organized <br>
                    # Caring, Concerned, Concrete" 
                when 'blue'
                    "Enthusiastic, Sympathetic, Personal <br>
                    Warm, Communicative, Compassionate <br>"
                    # Idealistic, Spiritual, Sincere <br>
                    # Peaceful, Flexible, Imaginative"
                when 'green'
                    "Analytical, Global, Conceptual <br>
                     Cool, Calm, Collected <br>"
                    #  Inventive, Logical, Perfectionist <br>
                    #  Abstract, Hypothetical, Investigative"
                when 'orange'
                    "Witty, Charming, Spontaneous <br>
                    Impulsive, Generous, Impactful <br>"
                    # Optimistic, Eager, Bold <br>
                    # Physical, Immediate, Fraternal"
            content
            

    Template.color_dots.helpers
        user: ->
            console.log @profile.colors
    
        color_icon_class: ->
            # console.log Template.currentData()
            icon_class = switch @valueOf()
                when 'gold' then 'yellow' 
                when 'blue' then 'blue' 
                when 'green' then 'green' 
                when 'orange' then 'orange'
            icon_class

        color_data_title: ->
            title = switch @valueOf()
                when 'gold' then 'Gold' 
                when 'blue' then 'Blue' 
                when 'green' then 'Green' 
                when 'orange' then 'Orange'
            title

            
        color_data_content: ->
            content = switch @valueOf()
                when 'gold' 
                    "Loyal, Dependable, Prepared <br>
                    Thorough, Sensible, Punctual <br>"
                    # Faithful, Stable, Organized <br>
                    # Caring, Concerned, Concrete" 
                when 'blue'
                    "Enthusiastic, Sympathetic, Personal <br>
                    Warm, Communicative, Compassionate <br>"
                    # Idealistic, Spiritual, Sincere <br>
                    # Peaceful, Flexible, Imaginative"
                when 'green'
                    "Analytical, Global, Conceptual <br>
                     Cool, Calm, Collected <br>"
                    #  Inventive, Logical, Perfectionist <br>
                    #  Abstract, Hypothetical, Investigative"
                when 'orange'
                    "Witty, Charming, Spontaneous <br>
                    Impulsive, Generous, Impactful <br>"
                    # Optimistic, Eager, Bold <br>
                    # Physical, Immediate, Fraternal"
            content
            

    Template.colors.helpers
        colors: -> Docs.find type: 'personality_color'
        color_segment_class: ->
            segment_class = switch @valueOf()
                when 'gold' then 'yellow' 
                when 'blue' then 'blue' 
                when 'green' then 'green' 
                when 'orange' then 'orange'
            segment_class
        
        me: -> Meteor.user()
    
if Meteor.isServer
    publishComposite 'personality_colors', ->
        {
            find: ->
                Docs.find
                    type: 'personality_color'
            children: [
                { find: (personality_color) ->
                    Docs.find 
                        parent_id: personality_color._id
                        author_id: @userId
                        type: 'rank'
                    }
                ]    
        }
