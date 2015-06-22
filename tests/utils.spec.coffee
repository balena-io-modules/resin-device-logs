m = require('mochainon')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.getChannel()', ->

		it 'should return the channel', ->
			m.chai.expect(utils.getChannel('asdf')).to.equal('device-asdf-logs')
