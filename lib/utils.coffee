###
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

_ = require('lodash')

###*
# @summary Get logs channel name from a uuid
# @function
# @protected
#
# @param {Object} device - device
# @returns {String} logs channel
#
# @example
# channel = utils.getChannel('...')
###
exports.getChannel = (device) ->
	return "device-#{device.logs_channel or device.uuid}-logs"

###*
# @summary Extract messages from PubNub payload
# @function
# @public
#
# @param {*} message - message
# @returns {Object[]} log messages
#
# @example
# messages = utils.extractMessages('foo bar')
###
exports.extractMessages = (message) ->

	# Coming from ancient supervisor
	if _.isString(message)
		return [
			isSystem: /\[system\]/.test(message)
			message: message
			timestamp: null
		]

	# Modern supervisor
	# An array of objects with munged keys
	else if _.isArray(message)
		return _.map message, ({ m, t, s }) ->
			message: m
			timestamp: t

			# Make sure it's bool (can be `1`)
			isSystem: Boolean(s)

	# Legacy supervisor
	else
		return [ message ]
