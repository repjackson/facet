if Meteor.isClient
    FlowRouter.route '/course/sol/module/:module_number/debrief', 
        name: 'debrief'
        action: (params) ->
            BlazeLayout.render 'view_module',
                module_content: 'debrief'
        
    
    Template.debrief.onCreated ->
        # @autorun -> Meteor.subscribe 'debrief_questions', FlowRouter.getParam('module_number')
        @autorun -> Meteor.subscribe 'module', parseInt FlowRouter.getParam('module_number')

    # Template.debrief_answers.onCreated ->
    #     @autorun => Meteor.subscribe 'answers', @data._id
    
    

    
    
    Template.debrief.helpers
        # debrief_questions: -> 
        #     Docs.find
        #         tags: ["sol","module #{FlowRouter.getParam('module_number')}", "debrief","question"]
                
        # debrief_questions_tags: ->
        #     "sol,module #{FlowRouter.getParam('module_number')},debrief,question"
    
    
        # has_answered_previous: ->
        #     # console.log @number
        #     # console.log @body
        #     if Roles.userIsInRole Meteor.userId(), 'admin' then true
        #     else
        #         mod_num = FlowRouter.getParam('module_number')
        #         sec_num = FlowRouter.getParam('section_number')
        #         if @number is 1 then true
        #         else
        #             previous_number = @number - 1
                    
        #             previous_question = Docs.findOne
        #                 tags: ["sol","module #{mod_num}","section #{sec_num}","reflective question"]
        #                 number: previous_number
                    
        #             if previous_question
        #                 previous_question_answer = 
        #                     Docs.findOne
        #                         tags: $in: ['answer']
        #                         parent_id: previous_question._id
        #                         author_id: Meteor.userId()
        #                 if previous_question_answer 
        #                     if Session.get('editing_id') isnt previous_question_answer._id
        #                         # console.log 'has answered question', previous_question.number
        #                         return true
        #                 else
        #                     # console.log 'has NOT answered question', previous_question.number
        #                     return false    
                        
                            
    
        module: -> 
            Docs.findOne 
                tags: $in: ['module']
                number: parseInt FlowRouter.getParam('module_number')
    
    
#         has_answered_question: ->
#             Docs.findOne
#                 tags: $in: ['answer']
#                 parent_id: @_id
#                 author_id: Meteor.userId()

    
#     Template.debrief_answers.helpers
#         all_answers: ->
#             Docs.find
#                 parent_id: @_id
#                 tags: $in: ["answer"]
#                 published: true
                
#         all_private_answers: ->
#             Docs.find
#                 parent_id: @_id
#                 tags: $in: ["answer"]
#                 published: false
                
#         my_answer: ->
#             Docs.findOne
#                 parent_id: @_id
#                 tags: $in: ["answer"]
#                 author_id: Meteor.userId()
                
#         is_editing_my_answer: ->
#             my_answer =             
#                 Docs.findOne
#                     parent_id: @_id
#                     tags: $in: ["answer"]
#                     author_id: Meteor.userId()
#             Session.equals 'editing_id', my_answer._id

#     Template.debrief_answers.events
#         'blur #body': (e,t)->
#             body = $(e.currentTarget).closest('#body').val()
#             Docs.update @_id,
#                 $set: body: body
            
#     Template.debrief_answers.onRendered ->
#         @autorun =>
#             if @subscriptionsReady()
#                 Meteor.setTimeout ->
#                     $('.ui.accordion').accordion()
#                 , 500
#                 # console.log 'subs ready'

    

    
    
#     Template.debrief.events
#         'click #add_debrief_question': ->
#             Docs.insert
#                 tags: ["sol","module #{FlowRouter.getParam('module_number')}", "debrief","question"]

#         'blur #body': (e,t)->
#             body = $(e.currentTarget).closest('#body').val()
#             Docs.update @_id,
#                 $set: body: body
            
    


#         'click .add_debrief_answer': ->
#             answer_tags = @tags
#             answer_tags.push 'answer'
#             # console.log 'answer tags', answer_tags
#             new_id = Docs.insert
#                 tags: answer_tags
#                 parent_id: @_id
#             Session.set 'editing_id', new_id

# if Meteor.isServer
#     publishComposite 'debrief_questions', (module_number)->
#         {
#             find: ->
#                 Docs.find 
#                     tags: ["sol","module #{module_number}", "debrief","question"]
#             children: [
#                 { 
#                     find: (question) ->
#                         Docs.find
#                             tags: $in: ["answer"]
#                             parent_id: question._id
#                     children: [
#                         find: (answer) ->
#                             Meteor.users.find
#                                 _id: answer.author_id
#                         ]
#                 }
#             ]
#         }    
    
    # Meteor.publish 'answers', (parent_id)->
    #     # console.log parent_id
    #     Docs.find 
