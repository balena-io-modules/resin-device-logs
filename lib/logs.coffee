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

###*
# @module logs
###

flatten = require('lodash/flatten')
assign = require('lodash/assign')
Promise = require('bluebird')
{ EventEmitter } = require('events')

pubnub = require('./pubnub')
{ extractMessages, getChannels } = require('./utils')

# https://www.pubnub.com/docs/nodejs-javascript/api-reference#listeners-categories
SUBSCRIBE_ERROR_CATEGORY = 'PNNetworkIssuesCategory'

###*
# @summary Subscribe to device logs
# @function
# @public
#
# @description This function emits various events:
#
# - `line`: When a log line arrives, passing an object as an argument.
# - `clear`: When the `clear` request is published (see the `clear` method)
# - `error`: When an error occurs, passing an error code as an argument.
#
# The object returned by this function also contains the following functions:
#
# - `.unsubscribe()`: Unsubscribe from the device channel.
#
# @param {Object} pubnubKeys - PubNub keys
# @param {Object} device - device
#
# @returns {EventEmitter} logs
#
# @example
# deviceLogs = logs.subscribe
# 	subscribe_key: '...'
# 	publish_key: '...'
# ,
# 	device
#
# deviceLogs.on 'line', (line) ->
# 	console.log(line.message)
# 	console.log(line.isSystem)
# 	console.log(line.timestamp)
#
# deviceLogs.on 'error', (error) ->
# 	throw error
#
# deviceLogs.on 'clear', ->
# 	console.clear()
###
exports.subscribe = (pubnubKeys, device) ->
	{ channel, clearChannel } = getChannels(device)
	instance = pubnub.getInstance(pubnubKeys)
	emitter = new EventEmitter()

	emit = (event, data) ->
		emitter.emit(event, data)

	onMessage = (message) ->
		if message.channel is clearChannel
			return emit('clear')

		if message.channel is channel
			extractMessages(message.message).forEach (payload) ->
				emit('line', payload)

	pubnubListener =
		message: onMessage
		status: ({ category }) ->
			if category is SUBSCRIBE_ERROR_CATEGORY
				emit('error', SUBSCRIBE_ERROR_CATEGORY)

	instance.addListener(pubnubListener)

	instance.subscribe
		channels: [ channel, clearChannel ]

	emitter.unsubscribe = ->
		instance.removeListener(pubnubListener)
		instance.unsubscribe
			channels: [ channel, clearChannel ]

	return emitter

###*
# @summary Get device logs history
# @function
# @public
#
# @param {Object} pubnubKeys - PubNub keys
# @param {Object} device - device
# @param {Object} [options] - other options supported by
# https://www.pubnub.com/docs/nodejs-javascript/api-reference#history
#
# @returns {Promise<Object[]>} device logs history
#
# @example
# logs.history
# 	subscribe_key: '...'
# 	publish_key: '...'
# ,
# 	device
# .then (lines) ->
# 	for line in lines
# 		console.log(line.message)
# 		console.log(line.isSystem)
# 		console.log(line.timestamp)
###
exports.history = (pubnubKeys, device, options) ->
	return Promise.try ->
		instance = pubnub.getInstance(pubnubKeys)
		{ channel } = getChannels(device)
		return pubnub.history(instance, channel, options)
	.map(extractMessages)
	.then(flatten)

###*
# @summary Get device logs history after the most recent clear
# @function
# @public
#
# @param {Object} pubnubKeys - PubNub keys
# @param {Object} device - device
# @param {Object} [options] - other options supported by
# https://www.pubnub.com/docs/nodejs-javascript/api-reference#history
#
# @returns {Promise<Object[]>} device logs history
#
# @example
# logs.historySinceLastClear
# 	subscribe_key: '...'
# 	publish_key: '...'
# ,
# 	device
# .then (lines) ->
# 	for line in lines
# 		console.log(line.message)
# 		console.log(line.isSystem)
# 		console.log(line.timestamp)
###
exports.historySinceLastClear = (pubnubKeys, device, options) ->
	return exports.getLastClearTime(pubnubKeys, device)
	.then (endTime) ->
		options = assign({ count: 200 }, options, {
			end: endTime
		})
		return exports.history(pubnubKeys, device, options)

###*
# @summary Clear device logs history
# @function
# @public
#
# @param {Object} pubnubKeys - PubNub keys
# @param {Object} device - device
#
# @returns {Promise} - resolved witht he PubNub publish response
###
exports.clear = (pubnubKeys, device) ->
	return Promise.try ->
		instance = pubnub.getInstance(pubnubKeys)
		{ clearChannel } = getChannels(device)
		return instance.time()
		.then ({ timetoken }) ->
			return instance.publish
				channel: clearChannel
				message: timetoken

###*
# @summary Get the most recent device logs history clear time
# @function
# @public
#
# @param {Object} pubnubKeys - PubNub keys
# @param {Object} device - device
#
# @returns {Promise<number>} timetoken
###
exports.getLastClearTime = (pubnubKeys, device) ->
	return Promise.try ->
		instance = pubnub.getInstance(pubnubKeys)
		{ clearChannel } = getChannels(device)
		return pubnub.history(instance, clearChannel, {
			count: 1
		}).then (messages) ->
			messages?[0] or 0
