fs = require 'fs'
path = require 'path'
request = require 'request'
{diff} = require 'deep-diff'
mkdirp = require 'mkdirp'

require 'colors' # extends Strings.prototype

{argv} = require 'yargs'

{client} = require './config'
{folders, exclude} = client

{getChecksums, minimatchMultiAny} = require './common'

hostAddress = "#{client.host}:#{client.port}"

handleDifferences = (differences) ->
	for d in differences
		do (d) ->
			sourcePath = "#{d.path[0]}/#{d.path[1]}"

			excludePatterns = exclude[d.path[0]] ? []
			return if minimatchMultiAny sourcePath, excludePatterns, matchBase: true, nocase: true

			if not argv.checkOnly?
				switch d.kind
					when 'D'
						fs.unlinkSync sourcePath
						console.log "Deleted #{sourcePath}"

					when 'N', 'E'
						targetPath = path.join folders[d.path[0]], d.path[1]

						mkdirp (path.dirname targetPath), (err) ->
							return console.error err.stack if err?

							console.log "Downloading #{sourcePath}..."
							request.get "http://#{hostAddress}/#{sourcePath}"
							.pipe fs.createWriteStream targetPath
							.on 'close', ->
								console.log "Downloaded #{sourcePath}"

			else
				switch d.kind
					when 'D'
						console.log "---\t#{sourcePath}".red

					when 'N'
						console.log "+++\t#{sourcePath}".green

					when 'E'
						console.log "~~~\t#{sourcePath}".yellow

console.log 'Fetching file checksums...'
request.get "http://#{hostAddress}/files-list.json",
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
				
				console.log 'Done\n'

				# console.log { mods, config }

				# console.log (diff({mods, config}, files) ? [])

				handleDifferences diff({mods, config}, files) ? []