FlowRouter.route '/edit/:doc_id',
    action: (params) ->
        BlazeLayout.render 'layout',
            top: 'nav'
            main: 'edit'




Template.edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#datetimepicker').datetimepicker(
            onChangeDateTime: (dp,$input)->
                val = $input.val()

                # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
                minute = moment(val).minute()
                hour = moment(val).format('h')
                date = moment(val).format('Do')
                ampm = moment(val).format('a')
                weekdaynum = moment(val).isoWeekday()
                weekday = moment().isoWeekday(weekdaynum).format('dddd')

                month = moment(val).format('MMMM')
                year = moment(val).format('YYYY')

                datearray = [hour, minute, ampm, weekday, month, date, year]

                doc_id = FlowRouter.getParam 'doc_id'

                doc = Docs.findOne doc_id
                tagsWithoutDate = _.difference(doc.tags, doc.datearray)
                tagsWithNew = _.union(tagsWithoutDate, datearray)

                Docs.update doc_id,
                    $set:
                        tags: tagsWithNew
                        datearray: datearray
                        dateTime: val
            )), 2000

    @autorun ->
        if GoogleMaps.loaded()
            $('#place').geocomplete().bind 'geocode:result', (event, result) ->
                doc_id = Session.get 'editing'
                Meteor.call 'updatelocation', doc_id, result, ->

Template.edit.helpers
    doc: ->
        doc_id = FlowRouter.getParam('doc_id')
        Docs.findOne doc_id

    editorOptions: ->
        lineNumbers: true
        mode: 'markdown'
        lineWrapping: true

    # unpickedConcepts: ->
    #     diff = _.map @tags, (tag)->
    #         tag.toLowerCase() in @concept_array
    # unpickedKeywords: ->
    #     keywordNames = keyword.text for keyword in @keywords
    #     console.log keywordNames
    #     _.difference @tags, @keywords



    docKeywordClass: ->
        doc_id = FlowRouter.getParam('doc_id')
        doc = Docs.findOne doc_id
        if @text.toLowerCase() in doc.tags then 'disabled' else ''

Template.edit.events
    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('doc_id'),
                        $push: tags: tag
                    $('#addTag').val('')
                else
                    Docs.update FlowRouter.getParam('doc_id'),
                        $set: body: $('#body').val()

                    thisDocTags = @tags
                    FlowRouter.go '/'
                    selectedTags = thisDocTags

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')

    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: @valueOf()
        $('#addTag').val(tag)

    'click #analyzeBody': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: body: $('#body').val()
        Meteor.call 'analyze', FlowRouter.getParam('doc_id')

    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: body: $('#body').val()

        thisDocTags = @tags
        FlowRouter.go '/'
        selectedTags = thisDocTags

    'click #deleteDoc': ->
        if confirm 'Delete this doc?'
            Docs.remove @_id
            FlowRouter.go '/'


    'click .docKeyword': ->
        doc_id = FlowRouter.getParam('doc_id')
        doc = Docs.findOne doc_id
        loweredTag = @text.toLowerCase()
        if @text in doc.tags
            Docs.update FlowRouter.getParam('doc_id'), $pull: tags: loweredTag
        else
            Docs.update FlowRouter.getParam('doc_id'), $push: tags: loweredTag