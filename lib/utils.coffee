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

isString = require('lodash/isString')
isArray = require('lodash/isArray')
assign = require('lodash/assign')

getBaseChannel = (device) ->
	device.logs_channel or device.uuid

###*
# @summary Get logs channel name for the given device
# @function
# @protected
#
# @param {Object} device - device
# @returns {String} logs channel name
#
# @example
# channel = utils.getChannel('...')
###
exports.getChannel = (device, suffix = 'logs') ->
	return "device-#{getBaseChannel(device)}-#{suffix}"

###*
# @summary Get logs and clear logs channel names for the given device
# @function
# @protected
#
# @param {Object} device - device
# @returns {Object} { channel, clearChannel }
#
# @example
# channel = utils.getChannel('...')
###
exports.getChannels = (device) ->
	channel: exports.getChannel(device)
	clearChannel: exports.getChannel(device, 'clear-logs')

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
	if isString(message)
		return [
			isSystem: /\[system\]/.test(message)
			message: message
			timestamp: null
			serviceId: null
		]

	# Modern supervisor
	# An array of objects with munged keys
	else if isArray(message)
		return message.map ({ m, t, s, c }) ->
			message: m
			timestamp: t
			# Make sure it's bool (can be `1`)
			isSystem: Boolean(s)
			serviceId: c ? null

	# Legacy supervisor
	else
		return [ assign({
			isSystem: false
			timestamp: null
			serviceId: null
		}, message) ]
