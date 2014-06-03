fs = require 'fs'
path = require 'path'
request = require 'request'
{diff} = require 'deep-diff'
mkdirp = require 'mkdirp'

{folders, getChecksums} = require './common'

{server} = require './config'

handleDifferences = (differences) ->
	for d in differences
		do (d) ->
			p = d.path[1]

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
						.on 'close', ->
							console.log "Downloaded #{p}"

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

				# console.log { mods, config }

				# console.log (diff({mods, config}, files) ? [])

				handleDifferences diff({mods, config}, files) ? []