m = require('mochainon')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.getChannel()', ->

		describe 'given a logs_channel property', ->

			it 'should return the property', ->
				device =
					uuid: 'asdf'
					logs_channel: 'qwer'
				m.chai.expect(utils.getChannel(device)).to.equal('device-qwer-logs')

		describe 'given no logs_channel property', ->

			it 'should use the uuid', ->
				device =
					uuid: 'asdf'

				m.chai.expect(utils.getChannel(device)).to.equal('device-asdf-logs')
