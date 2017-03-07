exports.randomId = ->
	Math.random().toFixed(16).substring(2)

exports.randomChannel = (prefix = 'channel') ->
	"#{prefix}-#{exports.randomId()}"
