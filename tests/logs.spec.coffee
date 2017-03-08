Promise = require('bluebird')
m = require('mochainon')
pubnub = require('../lib/pubnub')
{ getChannels } = require('../lib/utils')
logs = require('../lib/logs')

pubnubKeys = require('./config')
{ randomId, randomChannel } = require('./helpers')

global.Promise ?= Promise

describe 'Logs:', ->

	@timeout(5000)

	beforeEach ->
		@instance = pubnub.getInstance(pubnubKeys)
		@device = {
			uuid: randomId()
			logs_channel: randomId()
		}
		@channel = getChannels(@device).channel

	describe '.subscribe()', ->

		it 'should send message events', (done) ->
			pubnubStream = logs.subscribe(pubnubKeys, @device)
			lines = []
			pubnubStream.on 'line', (line) ->
				lines.push(line)

				if lines.length is 3
					m.chai.expect(lines).to.deep.equal [
						{
							message: 'foo'
							isSystem: false
							timestamp: null
						}
						{
							message: 'bar'
							isSystem: false
							timestamp: null
						}
						{
							message: 'baz'
							isSystem: false
							timestamp: null
						}
					]
					done()

			Promise.mapSeries(['foo', 'bar', 'baz'], (m) =>
				@instance.publish({
					channel: @channel
					message: m
				})
			).catch (err) ->
				console.error('Error', err)
				throw err

			return

	describe '.history()', ->

		beforeEach ->
			return Promise.mapSeries(['Foo', 'Bar', 'Baz'], (m) =>
				@instance.publish({
					channel: @channel
					message: m
				})
			).delay(500)
			.catch (err) ->
				console.error('Error', err)
				throw err

		it 'should eventually return the messages', ->
			promise = logs.history(pubnubKeys, @device)
			m.chai.expect(promise).to.eventually.become [
				{
					message: 'Foo'
					isSystem: false
					timestamp: null
				}
				{
					message: 'Bar'
					isSystem: false
					timestamp: null
				}
				{
					message: 'Baz'
					isSystem: false
					timestamp: null
				}
			]

	describe '.clear() and historySinceLastClear()', ->

		@timeout(10000)

		beforeEach ->
			@instance = pubnub.getInstance(pubnubKeys)
			@device = {
				uuid: randomId()
				logs_channel: randomId()
			}
			@channel = getChannels(@device).channel

		it 'should set the lower timestamp bound', ->
			return Promise.mapSeries([1..3], (i) =>
				@instance.publish({
					channel: @channel
					message: "Message #{i}"
				})
			).delay(1000)
			.catch (err) ->
				console.error('Error', err)
				throw err
			.then =>
				logs.history(pubnubKeys, @device)
			.then (messages) ->
				# The original logs count
				m.chai.expect(messages.length).to.equal(3)
			.then =>
				logs.clear(pubnubKeys, @device)
				.delay(1000)
			.then =>
				logs.history(pubnubKeys, @device)
			.then (messages) ->
				# The original logs count should not change
				m.chai.expect(messages.length).to.equal(3)
			.then =>
				logs.historySinceLastClear(pubnubKeys, @device)
			.then (messages) ->
				# The clear should have effect here
				m.chai.expect(messages.length).to.equal(0)
			.then =>
				return Promise.mapSeries([4..5], (i) =>
					@instance.publish({
						channel: @channel
						message: "Message #{i}"
					})
				).delay(1000)
				.catch (err) ->
					console.error('Error', err)
					throw err
			.then =>
				logs.history(pubnubKeys, @device)
			.then (messages) ->
				# The original logs count should not change
				m.chai.expect(messages.length).to.equal(5)
			.then =>
				logs.historySinceLastClear(pubnubKeys, @device)
			.then (messages) ->
				# The clear should have effect here
				m.chai.expect(messages).to.deep.equal([
					{
						message: 'Message 4'
						isSystem: false
						timestamp: null
					}
					{
						message: 'Message 5'
						isSystem: false
						timestamp: null
					}
				])
