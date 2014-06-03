fs = require 'fs'
path = require 'path'
md5 = require 'MD5'

exports.folders =
	mods: './mods'
	config: './config'

exports.getChecksums = (folder, callback) ->
	files = {}
	walker = (require 'walk').walk folder

	walker.on 'file', (root, fileStats, next) ->
		file = (path.join root, fileStats.name).replace /[\\]/g, '/'

		fs.readFile file, (err, buf) ->
			return (console.error err.stack; next()) if err?

			files[file] = md5 buf
			next()

	walker.on 'end', ->
		callback null, files