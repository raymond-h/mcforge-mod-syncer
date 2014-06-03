fs = require 'fs'
path = require 'path'
express = require 'express'
serveStatic = require 'serve-static'
md5 = require 'MD5'

folders =
	mods: './mods'
	config: './config'

getChecksums = (folder, callback) ->
	files = {}
	walker = (require 'walk').walk folder

	walker.on 'file', (root, fileStats, next) ->
		file = path.join root, fileStats.name

		fs.readFile file, (err, buf) ->
			return (console.error err.stack; next()) if err?

			files[file] = md5 buf
			next()

	walker.on 'end', ->
		callback null, files

app = express()

app.use '/mods', serveStatic path.join process.cwd(), '/mods'
app.use '/config', serveStatic path.join process.cwd(), '/config'

app.get '/files-list.json', (req, res) ->
	console.log 'Generating checksums for mods...'

	getChecksums folders.mods, (err, mods) ->
		console.log 'Generating checksums for configs...'

		getChecksums folders.config, (err, config) ->
			console.log 'Done'

			# console.log { mods, config }

			res.json { mods, config }

app.listen 25568