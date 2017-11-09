Promise = require('bluebird')
m = require('mochainon')
pubnub = require('../lib/pubnub')
{ getChannels } = require('../lib/utils')
logs = require('../lib/logs')

pubnubKeys = require('./config')
{ randomId, randomChannel, getMessages } = require('./helpers')

global.Promise ?= Promise

describe 'Logs:', ->

	@timeout(6000)

	beforeEach ->
		@instance = pubnub.getInstance(pubnubKeys)
		@device = {
			uuid: randomId()
			logs_channel: randomId()
		}
		@channel = getChannels(@device).channel

	describe '.subscribe()', ->

		it 'should send message events', ->
			pubnubStream = logs.subscribe(pubnubKeys, @device)

			Promise.mapSeries ['foo', 'bar', 'baz'], (m) =>
				@instance.publish
					channel: @channel
					message: m
			.thenReturn(getMessages(pubnubStream, 3))
			.then (messages) ->
				m.chai.expect(messages).to.deep.equal [
					message: 'foo'
					isSystem: false
					timestamp: null
				,
					message: 'bar'
					isSystem: false
					timestamp: null
				,
					message: 'baz'
					isSystem: false
					timestamp: null
				]

	describe '.history()', ->

		it 'should eventually return the messages', ->
			Promise.mapSeries ['Foo', 'Bar', 'Baz'], (m) =>
				@instance.publish
					channel: @channel
					message: m
			.delay(500)
			.then => logs.history(pubnubKeys, @device)
			.then (messages) ->
				m.chai.expect(messages).to.deep.equal [
					message: 'Foo'
					isSystem: false
					timestamp: null
				,
					message: 'Bar'
					isSystem: false
					timestamp: null
				,
					message: 'Baz'
					isSystem: false
					timestamp: null
				]

		it 'should ignore .clear', ->
			Promise.mapSeries [1..3], (i) =>
				@instance.publish
					channel: @channel
					message: "Message #{i}"
			.delay(1000)
			.then => logs.clear(pubnubKeys, @device)
			.delay(1000)
			.then => logs.history(pubnubKeys, @device)
			.then (messages) ->
				m.chai.expect(messages.length).to.equal(3)

	describe 'historySinceLastClear()', ->

		it 'should show all messages, if .clear has never been called', ->
			Promise.mapSeries [1..3], (i) =>
				@instance.publish
					channel: @channel
					message: "Message #{i}"
			.delay(500)
			.then => logs.historySinceLastClear(pubnubKeys, @device)
			.then (messages) ->
				m.chai.expect(messages).to.deep.equal [
					message: 'Message 1'
					isSystem: false
					timestamp: null
				,
					message: 'Message 2'
					isSystem: false
					timestamp: null
				,
					message: 'Message 3'
					isSystem: false
					timestamp: null
				]

		it 'should only show messages since the .clear(), if it has been called', ->
			Promise.mapSeries [1..3], (i) =>
				@instance.publish
					channel: @channel
					message: "Message #{i}"
			.delay(500)
			.then => logs.clear(pubnubKeys, @device)
			.delay(500)
			.then =>
				Promise.mapSeries [4..5], (i) =>
					@instance.publish
						channel: @channel
						message: "Message #{i}"
			.delay(500)
			.then => logs.historySinceLastClear(pubnubKeys, @device)
			.then (messages) ->
				m.chai.expect(messages).to.deep.equal [
					message: 'Message 4'
					isSystem: false
					timestamp: null
				,
					message: 'Message 5'
					isSystem: false
					timestamp: null
				]
