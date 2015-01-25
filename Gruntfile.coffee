module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		nodeVersion: '0.10.28'

		coffee:
			build:
				expand: yes
				cwd: 'src/'
				src: '**/*.coffee'
				dest: 'lib/'
				ext: '.js'

		coffeelint:
			build:
				files: src: ['src/**/*.coffee', 'test/**/*.coffee']
			options:
				no_tabs: level: 'ignore' # this is tab land, boy
				indentation: value: 1 # single tabs

		mochaTest:
			test:
				options:
					reporter: 'spec'
					require: ['coffee-script/register']

				src: ['test/**/*.test.(js|coffee)']

		watch:
			dev:
				files: ['src/**/*.(js|coffee)', 'test/**/*.(js|coffee)']
				tasks: ['dev']

			test:
				files: ['src/**/*.(js|coffee)', 'test/**/*.(js|coffee)']
				tasks: ['test']

			lint:
				files: ['src/**/*.(js|coffee)', 'test/**/*.(js|coffee)']
				tasks: ['lint']

		curl:
			node_bin:
				files:
					'download_bin/node.v<%= nodeVersion %>.exe':
						'http://nodejs.org/dist/v<%= nodeVersion %>/node.exe'

		browserify:
			main:
				options:
					transform: ['coffeeify']

					browserifyOptions:
						builtins: no
						commondir: no
						detectGlobals: no
						insertGlobalVars: '__filename,__dirname'
						extensions: ['.coffee', '.js', '.json']

				files:
					'tmp/main.js': ['./index.coffee']

		copy:
			node_bin:
				files:
					'tmp/node.exe': 'download_bin/node.v<%= nodeVersion %>.exe'

		compress:
			dist:
				options:
					archive: '<%= pkg.name %>-<%= pkg.version %>.zip'

				files: [
					{
						expand: true
						cwd: 'tmp'
						src: ['**/*']
						dest: ''
					}
				]

	grunt.registerTask 'download_node_bin', ->
		nodeVersion = grunt.config.get 'nodeVersion'

		if not grunt.file.exists "download_bin/node.v#{nodeVersion}.exe"
			grunt.log.writeln "Downloading Node v#{nodeVersion} binary..."
			grunt.task.run 'curl:node_bin'

		else grunt.log.writeln "Node v#{nodeVersion} binary already downloaded!"

	grunt.registerTask 'write_run_bat', ->
		pkg = grunt.config 'pkg'

		contents = """
			@ECHO off
			"./#{pkg.name}/bin/node.exe" "./main.js" %*
		"""

		grunt.file.write 'tmp/run_sync.bat', contents, encoding: 'utf-8'

	grunt.registerTask 'default', ['build']

	grunt.registerTask 'build', ['coffee:build']
	grunt.registerTask 'lint', ['coffeelint:build']
	grunt.registerTask 'test', ['mochaTest:test']

	grunt.registerTask 'dev', ['lint', 'test']
	grunt.registerTask 'watch-dev', ['watch:dev']

	grunt.registerTask 'standalone', [
		'browserify:main' # build main script file
		'download_node_bin' # download node binary to /bin
		'copy:node_bin'
		'write_run_bat' # write a start.bat file to /tmp
		'compress:dist' # zip up /tmp
	]