fs = require 'fs'
path = require 'path'
md5 = require 'MD5'
minimatch = require 'minimatch'

exports.minimatchMultiAny = (file, patterns, options) ->
	for pattern in patterns
		return true if minimatch file, pattern, options

	false

exports.minimatchMulti = (file, patterns, options) ->
	for pattern in patterns
		return false if not minimatch file, pattern, options

	true

exports.getChecksums = (folder, excludePatterns, callback) ->
	unless callback?
		callback = excludePatterns
		excludePatterns = []

	files = {}
	walker = (require 'walk').walk folder

	walker.on 'file', (root, fileStats, next) ->
		file = path.join root, fileStats.name

		if excludePatterns.length > 0 and
			(exports.minimatchMulti file, excludePatterns, matchBase: true)
				return next()

		fs.readFile file, (err, buf) ->
			return (console.error err.stack; next()) if err?

			key = (path.relative folder, file).replace /[\\]/g, '/'
			files[key] = md5 buf
			next()

	walker.on 'end', ->
		callback null, files