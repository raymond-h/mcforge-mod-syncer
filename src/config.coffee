fs = require 'fs'
ini = require 'ini'
_ = require 'underscore'

configFile = './sync_config.ini'

defaults =
	client:
		host: 'localhost'
		port: 25568

		folders:
			mods: './mods'
			config: './config'

		exclude:
			mods: ['!*']
			config: ['!*']

	server:
		port: 25568

		folders:
			mods: './mods'
			clientMods: './client-mods'
			config: './config'

		exclude:
			mods: ['!*']
			config: ['!*']

try
	config = ini.parse fs.readFileSync configFile, encoding: 'utf-8'

catch e
	if e.code is 'ENOENT'
		console.log "Config file '#{configFile}' does not exist, creating..."

		fs.writeFileSync configFile, ini.stringify defaults
		process.exit 0

	else console.error e.stack

module.exports = _.defaults config, defaults