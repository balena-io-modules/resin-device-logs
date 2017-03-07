Promise = require('bluebird')
m = require('mochainon')
pubnub = require('../lib/pubnub')
{ getChannels } = require('../lib/utils')
logs = require('../lib/logs')

pubnubKeys = require('./config')
{ randomId, randomChannel } = require('./helpers')

global.Promise ?= Promise

describe 'Logs:', ->

	beforeEach ->
		@instance = pubnub.getInstance(pubnubKeys)
		@device = {
			uuid: randomId()
			logs_channel: randomId()
		}
		@channel = getChannels(@device).channel

	describe '.subscribe()', ->

		describe 'given an instance that connects and receives messages', ->

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
				)

				return

	describe '.history()', ->

		describe 'given an instance that reacts to a valid channel', ->

			beforeEach ->
				return Promise.mapSeries(['Foo', 'Bar', 'Baz'], (m) =>
					@instance.publish({
						channel: @channel
						message: m
					})
				).delay(500)

			describe 'given the correct uuid', ->

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
