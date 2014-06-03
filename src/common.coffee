fs = require 'fs'
path = require 'path'
md5 = require 'MD5'
minimatch = require 'minimatch'

minimatchMulti = (file, patterns, options) ->
	for pattern in patterns
		return false if not minimatch file, pattern, options

	true

exports.getChecksums = (folder, filterPatterns, callback) ->
	unless callback?
		callback = filterPatterns
		filterPatterns = []

	files = {}
	walker = (require 'walk').walk folder

	walker.on 'file', (root, fileStats, next) ->
		file = path.join root, fileStats.name

		return next() unless (minimatchMulti file, filterPatterns, matchBase: true)

		fs.readFile file, (err, buf) ->
			return (console.error err.stack; next()) if err?

			key = (path.relative folder, file).replace /[\\]/g, '/'
			files[key] = md5 buf
			next()

	walker.on 'end', ->
		callback null, files