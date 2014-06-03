fs = require 'fs'
path = require 'path'
request = require 'request'
{diff} = require 'deep-diff'
mkdirp = require 'mkdirp'

{server, folders} = require './config'
{getChecksums} = require './common'

handleDifferences = (differences) ->
	for d in differences
		do (d) ->
			sourcePath = "#{d.path[0]}/#{d.path[1]}"

			switch d.kind
				when 'D'
					fs.unlinkSync sourcePath
					console.log "Deleted #{sourcePath}"

				when 'N', 'E'
					targetPath = path.join folders[d.path[0]], d.path[1]
					console.log "Target folder is #{targetPath}"

					mkdirp (path.dirname targetPath), (err) ->
						return console.error err.stack if err?

						console.log "Downloading #{sourcePath}..."
						request.get "http://#{server.host}:#{server.port}/#{sourcePath}"
						.pipe fs.createWriteStream targetPath
						.on 'close', ->
							console.log "Downloaded #{sourcePath}"

console.log 'Fetching file checksums...'
request.get "http://#{server.host}:#{server.port}/files-list.json",
	(err, res, files) ->
		return console.error err.stack if err?

		files = JSON.parse files

		# console.log files
		console.log 'Generating checksums for local mods...'

		getChecksums folders.mods, (err, mods) ->
			return console.error err.stack if err?

			console.log 'Generating checksums for local configs...'

			getChecksums folders.config, (err, config) ->
				return console.error err.stack if err?
				
				console.log 'Done'

				console.log { mods, config }

				# console.log (diff({mods, config}, files) ? [])

				handleDifferences diff({mods, config}, files) ? []