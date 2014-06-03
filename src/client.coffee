fs = require 'fs'
path = require 'path'
request = require 'request'
{diff} = require 'deep-diff'
md5 = require 'MD5'
mkdirp = require 'mkdirp'

server =
	host: 'localhost'
	port: 25568

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

handleDifferences = (differences) ->
	for d in differences
		do (d) ->
			p = d.path[1].replace '\\', '/'

			switch d.kind
				when 'D'
					fs.unlinkSync p
					console.log "Deleted #{p}"

				when 'N', 'E'
					mkdirp (path.dirname p), (err) ->
						return console.error err.stack if err?

						console.log "Downloading #{p}..."
						request.get "http://#{server.host}:#{server.port}/#{p}"
						.pipe fs.createWriteStream p
						.on 'end', ->
							console.log "Downloaded #{p}"

console.log 'Fetching file checksums...'
request.get "http://#{server.host}:#{server.port}/files-list.json",
	(err, res, files) ->
		files = JSON.parse files
		console.log 'Generating checksums for local mods...'

		getChecksums folders.mods, (err, mods) ->
			console.log 'Generating checksums for local configs...'

			getChecksums folders.config, (err, config) ->
				console.log 'Done'

				# console.log { mods, config }

				handleDifferences diff({mods, config}, files) ? []