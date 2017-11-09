m = require('mochainon')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.getChannel()', ->

		describe 'given a logs_channel property', ->

			it 'should use it to build the logs channel', ->
				device =
					uuid: 'asdf'
					logs_channel: 'qwer'
				m.chai.expect(utils.getChannel(device)).to.equal('device-qwer-logs')

		describe 'given no logs_channel property', ->

			it 'should use the uuid', ->
				device =
					uuid: 'asdf'

				m.chai.expect(utils.getChannel(device)).to.equal('device-asdf-logs')

	describe '.getChannels()', ->

		describe 'given a logs_channel property', ->

			it 'should use it to build the logs channels', ->
				device =
					uuid: 'asdf'
					logs_channel: 'qwer'
				m.chai.expect(utils.getChannels(device)).to.deep.equal({
					channel: 'device-qwer-logs'
					clearChannel: 'device-qwer-clear-logs'
				})

		describe 'given no logs_channel property', ->

			it 'should use the uuid', ->
				device =
					uuid: 'asdf'

				m.chai.expect(utils.getChannels(device)).to.deep.equal({
					channel: 'device-asdf-logs'
					clearChannel: 'device-asdf-clear-logs'
				})

	describe '.extractMessages()', ->

		it 'should extract a string message', ->
			result = utils.extractMessages('foo bar')
			m.chai.expect(result).to.deep.equal [
				isSystem: false
				message: 'foo bar'
				timestamp: null
				serviceId: null
			]

		it 'should extract a string system message', ->
			result = utils.extractMessages('[system] foo bar')
			m.chai.expect(result).to.deep.equal [
				isSystem: true
				message: '[system] foo bar'
				timestamp: null
				serviceId: null
			]

		it 'should extract an array message', ->
			result = utils.extractMessages([
					m: 'Foo'
					s: 0
					t: 12345
				,
					m: 'Bar'
					s: 0
					t: 12345
				,
					m: 'Multicontainer'
					s: 0
					t: 54321
					c: 123
			])
			m.chai.expect(result).to.deep.equal [
					isSystem: false
					message: 'Foo'
					timestamp: 12345
					serviceId: null
				,
					isSystem: false
					message: 'Bar'
					timestamp: 12345
					serviceId: null
				,
					isSystem: false
					message: 'Multicontainer'
					timestamp: 54321
					serviceId: 123
			]

		it 'should extract an array system message', ->
			result = utils.extractMessages([
					m: 'Foo'
					s: 1
					t: 12345
				,
					m: 'Bar'
					s: 1
					t: 12345
			])
			m.chai.expect(result).to.deep.equal [
					isSystem: true
					message: 'Foo'
					timestamp: 12345
					serviceId: null
				,
					isSystem: true
					message: 'Bar'
					timestamp: 12345
					serviceId: null
			]

		it 'should extract an object message', ->
			result = utils.extractMessages(message: 'foo bar')
			m.chai.expect(result).to.deep.equal [
				isSystem: false
				message: 'foo bar'
				timestamp: null
				serviceId: null
			]
