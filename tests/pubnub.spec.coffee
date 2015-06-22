m = require('mochainon')
PubNub = require('pubnub')
pubnub = require('../lib/pubnub')

describe 'PubNub:', ->

	describe '.getInstance()', ->

		beforeEach ->
			@PubNubInitStub = m.sinon.stub(PubNub, 'init')

		afterEach ->
			@PubNubInitStub.restore()

		it 'should have been initialized PubNub with ssl', ->
			pubnub.getInstance
				subscribe_key: 'asdf'
				publish_key: 'asdf'

			m.chai.expect(@PubNubInitStub).to.have.been.calledOnce
			m.chai.expect(@PubNubInitStub.firstCall.args[0].ssl).to.be.true

	describe '.getHistory()', ->

		describe 'given a pubnub mock instance that returns valid history', ->

			beforeEach ->
				@instance =
					history: (options) ->
						setTimeout ->
							options.callback [
								[ 'Foo', 'Bar', 'Baz' ]
								13406746729185766
								13406746780720711
							]
						, 1

			it 'should resolve with the history messages', ->
				promise = pubnub.history(@instance, 'mychannel')
				m.chai.expect(promise).to.eventually.become([ 'Foo', 'Bar', 'Baz' ])

		describe 'given a pubnub mock instance that returns an error', ->

			beforeEach ->
				@instance =
					history: (options) ->
						setTimeout ->
							options.error(new Error('logs error'))
						, 1

			it 'should be rejected with the corresponding error message', ->
				promise = pubnub.history(@instance, 'mychannel')
				m.chai.expect(promise).to.be.rejectedWith('logs error')
