fs = require 'fs'
path = require 'path'
express = require 'express'
serveStatic = require 'serve-static'

{server, folders} = require './config'
{getChecksums} = require './common'

app = express()

app.use '/mods', serveStatic path.join process.cwd(), '/mods'
app.use '/config', serveStatic path.join process.cwd(), '/config'

app.get '/files-list.json', (req, res) ->
	console.log "New files list request from #{req.ip}"
	console.log 'Generating checksums for mods...'

	getChecksums folders.mods, (err, mods) ->
		console.log 'Generating checksums for configs...'

		getChecksums folders.config, (err, config) ->
			console.log 'Done'

			console.log { mods, config }

			res.json { mods, config }

app.listen server.port