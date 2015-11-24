
/*
The MIT License

Copyright (c) 2015 Resin.io, Inc. https://resin.io.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */

/**
 * @module logs
 */
var EventEmitter, Promise, pubnub, utils, _;

_ = require('lodash');

Promise = require('bluebird');

EventEmitter = require('events').EventEmitter;

pubnub = require('./pubnub');

utils = require('./utils');


/**
 * @summary Subscribe to device logs
 * @function
 * @public
 *
 * @description This function emits various events:
 *
 * - `line`: When a log line arrives, passing a string as an argument.
 * - `error`: When an error occurs, passing an error instance as an argument.
 *
 * The object returned by this function also contains the following functions:
 *
 * - `.unsubscribe()`: Unsubscribe from the device channel.
 *
 * @param {Object} pubnubKeys - PubNub keys
 * @param {String} pubnubKeys.subscribe_key - subscribe key
 * @param {String} pubnubKeys.publish_key - publish key
 * @param {Object} device - device
 *
 * @returns {EventEmitter} logs
 *
 * @example
 * deviceLogs = logs.subscribe
 * 	subscribe_key: '...'
 * 	publish_key: '...'
 * ,
 *		uuid: '...'
 *
 * deviceLogs.on 'line', (line) ->
 *		console.log(line)
 *
 * deviceLogs.on 'error', (error) ->
 *		throw error
 */

exports.subscribe = function(pubnubKeys, device) {
  var channel, emitter, instance;
  channel = utils.getChannel(device);
  instance = pubnub.getInstance(pubnubKeys);
  emitter = new EventEmitter();
  instance.subscribe({
    channel: channel,
    restore: true,
    message: function(message) {
      return emitter.emit('line', message);
    },
    error: function(error) {
      return emitter.emit('error', error);
    }
  });
  emitter.unsubscribe = function() {
    return instance.unsubscribe({
      channel: channel
    });
  };
  return emitter;
};


/**
 * @summary Get device logs history
 * @function
 * @public
 *
 * @param {Object} pubnubKeys - PubNub keys
 * @param {String} pubnubKeys.subscribe_key - subscribe key
 * @param {String} pubnubKeys.publish_key - publish key
 * @param {Object} device - device
 *
 * @returns {Promise<String[]>} device logs history
 *
 * @example
 * logs.history
 * 	subscribe_key: '...'
 * 	publish_key: '...'
 * ,
 *		uuid: '...'
 * .then (messages) ->
 * 	for message in messages
 * 		console.log(message)
 */

exports.history = function(pubnubKeys, device) {
  return Promise["try"](function() {
    var channel, instance;
    instance = pubnub.getInstance(pubnubKeys);
    channel = utils.getChannel(device);
    return pubnub.history(instance, channel);
  });
};
