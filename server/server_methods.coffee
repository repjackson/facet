Meteor.methods
    analyze: (id)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(doc.body)

        # result = HTTP.call 'POST', 'https://gateway.watsonplatform.net/natural-language-understanding/api', { params:
        HTTP.call 'POST', 'https://gateway.watsonplatform.net/natural-language-understanding/api', { params:
            username: "9576c892-fd4b-4585-9ae0-71e53e97a2c9",
            password: "WVvC6rHQqCIb"
            # text: encoded
            html: doc.body
            outputMode: 'json'
            # extract: 'entity,keyword,title,author,taxonomy,concept,relation,pub-date,doc-sentiment' }
            extract: 'keyword,taxonomy,concept,doc-sentiment' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    concept_array = _.pluck(result.data.concepts, 'text')

                    Docs.update id,
                        $set:
                            docSentiment: result.data.docSentiment
                            language: result.data.language
                            keywords: result.data.keywords
                            concepts: result.data.concepts
                            entities: result.data.entities
                            taxonomy: result.data.taxonomy
                            keyword_array: keyword_array
                            concept_array: concept_array
