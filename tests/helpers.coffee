Promise = require('bluebird')

exports.randomId = ->
	Math.random().toFixed(16).substring(2)

exports.randomChannel = (prefix = 'channel') ->
	"test-#{prefix}-#{exports.randomId()}"

exports.getMessages = (stream, expectedCount) ->
	new Promise (resolve) ->
		messages = []
		stream.on 'line', (line) ->
			messages.push(line)

			if messages.length is expectedCount
				resolve(messages)
			if messages.length > expectedCount
				throw new Error('Received more messages than expected! ' + JSON.stringify(messages, null, 2))
