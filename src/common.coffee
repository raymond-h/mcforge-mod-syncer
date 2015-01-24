fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
minimatch = require 'minimatch'

exports.minimatchMultiAny = (file, patterns, options) ->
	for pattern in patterns
		return true if minimatch file, pattern, options

	false

exports.minimatchMulti = (file, patterns, options) ->
	for pattern in patterns
		return false if not minimatch file, pattern, options

	true

exports.hashOfFile = (file, cb) ->
	s = fs.createReadStream file
	hash = crypto.createHash 'md5'

	s
	.on 'data', (data) ->
		hash.update data

	.on 'end', ->
		hashStr = hash.digest 'hex'

		cb null, hashStr

	.on 'error', cb

exports.getChecksums = (folder, excludePatterns, callback) ->
	unless callback?
		callback = excludePatterns
		excludePatterns = []

	files = {}
	walker = (require 'walk').walk folder

	walker.on 'file', (root, fileStats, next) ->
		file = path.join root, fileStats.name

		if excludePatterns.length > 0 and
			(exports.minimatchMulti file, excludePatterns, matchBase: true, nocase: true)
				return next()

		key = (path.relative folder, file).replace /[\\]/g, '/'

		exports.hashOfFile file, (err, hash) ->
			return (console.error err.stack; next()) if err?

			files[key] = hash
			next()

	walker.on 'end', ->
		callback null, files