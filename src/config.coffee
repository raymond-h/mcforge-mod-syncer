fs = require 'fs'
ini = require 'ini'
_ = require 'underscore'

configFile = './sync_config.ini'

defaults =
	folders:
		mods: './mods'
		config: './config'

	server:
		host: 'kayarrcraft.playat.ch'
		port: 25568

try
	config = ini.parse fs.readFileSync configFile, encoding: 'utf-8'

catch e
	if e.code is 'ENOENT'
		console.log "Config file '#{configFile}' does not exist, creating..."

		fs.writeFileSync configFile, ini.stringify defaults
		process.exit 0

	else console.error e.stack

module.exports = _.defaults config, defaults