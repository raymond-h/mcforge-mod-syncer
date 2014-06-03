{argv} = require 'yargs'

if argv.server then require './server'
else require './client'