Promise = require('bluebird')
m = require('mochainon')
PubNub = require('pubnub')
pubnub = require('../lib/pubnub')

pubnubKeys = require('./config')
{ randomChannel } = require('./helpers')

# needed for PubNub to work
global.Promise or= Promise

describe 'PubNub:', ->

	@timeout(5000)

	describe '.getInstance()', ->

		it 'should have been initialized with ssl', ->
			instance = pubnub.getInstance(pubnubKeys)
			m.chai.expect(instance._config.secure).to.be.true

		it 'should memoize the instance based on the subscribe key', ->
			instance1 = pubnub.getInstance(pubnubKeys)
			instance2 = pubnub.getInstance(pubnubKeys)
			m.chai.expect(instance1).to.be.equal(instance2)

			instance3 = pubnub.getInstance({
				publishKey: '1'
				subscribeKey: '2'
			})

			m.chai.expect(instance1).to.not.be.equal(instance3)

	describe '.history()', ->

		beforeEach ->
			@instance = pubnub.getInstance(pubnubKeys)
			@channel = randomChannel()

			return Promise.mapSeries([1..5], (i) =>
				@instance.publish({
					channel: @channel
					message: "Message #{i}"
				})
			).delay(1000)
			.catch (err) ->
				console.error('Error', err)
				throw err

		it 'should retrieve the history messages', ->
			promise = pubnub.history(@instance, @channel)
			m.chai.expect(promise).to.eventually.become([
				'Message 1', 'Message 2', 'Message 3', 'Message 4', 'Message 5'
			])

		it 'should retrieve the history messages and support extra options', ->
			promise = pubnub.history(@instance, @channel, count: 2)
			m.chai.expect(promise).to.eventually.become([
				'Message 4', 'Message 5'
			])
