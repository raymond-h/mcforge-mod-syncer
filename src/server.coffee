fs = require 'fs'
path = require 'path'
express = require 'express'
serveStatic = require 'serve-static'
_ = require 'underscore'

{server} = require './config'
{folders} = server

{getChecksums} = require './common'

app = express()

app.use '/mods', serveStatic path.join process.cwd(), folders.clientMods
app.use '/mods', serveStatic path.join process.cwd(), folders.mods
app.use '/config', serveStatic path.join process.cwd(), folders.config

app.get '/files-list.json', (req, res) ->
	console.log "New files list request from #{req.ip}"
	console.log 'Generating checksums for mods...'

	getChecksums folders.mods, (err, mods) ->
		getChecksums folders.clientMods, (err, clientMods) ->
			_.extend mods, clientMods

			console.log 'Generating checksums for configs...'

			getChecksums folders.config, (err, config) ->
				console.log 'Done'

				console.log { mods, config }

				res.json { mods, config }

app.listen server.port