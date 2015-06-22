m = require('mochainon')
pubnub = require('../lib/pubnub')
logs = require('../lib/logs')

pubnubKeys =
	subscribe_key: 'sub-c-apqw93io-ioqwix2o3io2i-dsddskcdab7fe'
	publish_key: 'pub-c-kkldjfij3-askajcnd-i98323224-ae2b226'

describe 'Logs:', ->

	describe '.subscribe()', ->

		describe 'given an instance that connects and receives messages', ->

			beforeEach ->
				@pubnubGetInstanceStub = m.sinon.stub(pubnub, 'getInstance')
				@pubnubGetInstanceStub.returns
					subscribe: (options) ->
						setTimeout ->
							options.message('foo')

							setTimeout ->
								options.message('bar')

								setTimeout ->
									options.message('baz')
								, 1
							, 1
						, 1

			afterEach ->
				@pubnubGetInstanceStub.restore()

			it 'should send message events', (done) ->
				pubnubStream = logs.subscribe(pubnubKeys, 'asdf')
				lines = []
				pubnubStream.on 'line', (line) ->
					lines.push(line)

					if lines.length is 3
						m.chai.expect(lines).to.deep.equal([ 'foo', 'bar', 'baz' ])
						done()

		describe 'given an instance that connects and sends an error', ->

			beforeEach ->
				@pubnubGetInstanceStub = m.sinon.stub(pubnub, 'getInstance')
				@pubnubGetInstanceStub.returns
					subscribe: (options) ->
						setTimeout ->
							options.error(new Error('pubnub error'))
						, 1

			afterEach ->
				@pubnubGetInstanceStub.restore()

			it 'should receive the error', (done) ->
				pubnubStream = logs.subscribe(pubnubKeys, 'asdf')
				pubnubStream.on 'error', (error) ->
					m.chai.expect(error).to.be.an.instanceof(Error)
					m.chai.expect(error.message).to.equal('pubnub error')
					done()

	describe '.history()', ->

		describe 'given an error when getting the instance', ->

			beforeEach ->
				@pubnubGetInstanceStub = m.sinon.stub(pubnub, 'getInstance')
				@pubnubGetInstanceStub.throws(new Error('pubnub error'))

			afterEach ->
				@pubnubGetInstanceStub.restore()

			it 'should reject with that error', ->
				promise = logs.history(pubnubKeys, 'asdf')
				m.chai.expect(promise).to.be.rejectedWith('pubnub error')

		describe 'given an instance that reacts to a valid channel', ->

			beforeEach ->
				@pubnubGetInstanceStub = m.sinon.stub(pubnub, 'getInstance')
				@pubnubGetInstanceStub.returns
					history: (options) ->

						# This check has the double benefit that we implicitly
						# check that the correct channel name is passed internally.
						return if options.channel isnt 'device-asdf-logs'

						setTimeout ->
							options.callback [
								[ 'Foo', 'Bar', 'Baz' ]
								13406746729185766
								13406746780720711
							]
						, 1

			afterEach ->
				@pubnubGetInstanceStub.restore()

			describe 'given the correct uuid', ->

				it 'should eventually return the messages', ->
					promise = logs.history(pubnubKeys, 'asdf')
					m.chai.expect(promise).to.eventually.become([ 'Foo', 'Bar', 'Baz' ])

		describe 'given an instance that returns an error', ->

			beforeEach ->
				@pubnubGetInstanceStub = m.sinon.stub(pubnub, 'getInstance')
				@pubnubGetInstanceStub.returns
					history: (options) ->
						setTimeout ->
							options.error(new Error('logs error'))
						, 1

			afterEach ->
				@pubnubGetInstanceStub.restore()

			it 'should reject with the error', ->
				promise = logs.history(pubnubKeys, 'asdf')
				m.chai.expect(promise).to.be.rejectedWith('logs error')
