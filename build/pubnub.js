
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
var Promise, PubNub, _;

_ = require('lodash');

Promise = require('bluebird');

PubNub = require('pubnub');


/**
 * @summary Get a PubNub instance
 * @function
 * @protected
 *
 * @param {Object} options - PubNub options
 * @param {String} options.subscribe_key - subscribe key
 * @param {String} options.publish_key - publish key
 *
 * @returns {Object} PubNub instance
 */

exports.getInstance = function(options) {
  options.ssl = true;
  return PubNub.init(options);
};


/**
 * @summary Get logs history from an instance
 * @function
 * @protected
 *
 * @description
 * **BE CAREFUL!** This function reacts poorly to non valid channels.
 * It just returns an empty array as if it didn't have any history messages.
 *
 * @param {Object} instance - PubNub instance
 * @param {String} channel - channel
 *
 * @returns {Promise<String[]>} history messages
 */

exports.history = function(instance, channel) {
  return Promise.fromNode(function(callback) {
    return instance.history({
      channel: channel,
      callback: function(history) {
        return callback(null, _.first(history));
      },
      error: callback
    });
  });
};
