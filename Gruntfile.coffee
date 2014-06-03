module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'

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
					'bin/node.exe': 'http://nodejs.org/dist/v0.10.28/node.exe'

		copy:
			node_bin:
				files:
					'dist/bin/node.exe': 'bin/node.exe'

			node_modules:
				expand: true
				cwd: 'node_modules'
				src: ['**']
				dest: 'dist/node_modules'
				filter: (filepath) ->
					pkg = grunt.config 'pkg'
					(filepath.split /[\\/]/)[1] in Object.keys pkg.dependencies

			lib:
				expand: true
				cwd: 'lib'
				src: ['**/*']
				dest: 'dist/lib'

		compress:
			dist:
				options:
					archive: '<%= pkg.name %>-<%= pkg.version %>.zip'

				files: [
					{
						expand: true
						cwd: 'dist'
						src: ['**/*', '!run_sync.bat']
						dest: '<%= pkg.name %>'
					}
					{
						expand: true
						cwd: 'dist'
						src: ['run_sync.bat']
						dest: ''
					}
				]

	grunt.registerTask 'download_node_bin', ->
		if not grunt.file.exists 'bin/node.exe'
			grunt.log.writeln 'Downloading Node binary...'
			grunt.task.run 'curl:node_bin'

		else grunt.log.writeln 'Node binary already downloaded!'

	grunt.registerTask 'write_run_bat', ->
		pkg = grunt.config 'pkg'

		contents = """
			@ECHO off
			"./#{pkg.name}/bin/node.exe" "./#{pkg.name}/#{pkg.main}" %*
		"""

		grunt.file.write 'dist/run_sync.bat', contents, encoding: 'utf-8'

	grunt.registerTask 'default', ['build']

	grunt.registerTask 'build', ['coffee:build']
	grunt.registerTask 'lint', ['coffeelint:build']
	grunt.registerTask 'test', ['mochaTest:test']

	grunt.registerTask 'dev', ['lint', 'test']
	grunt.registerTask 'watch-dev', ['watch:dev']

	grunt.registerTask 'standalone', [
		'build' # build entire code into /lib
		'download_node_bin' # download node binary to /bin
		'copy:node_bin'
		'copy:node_modules'
		'copy:lib' # copy all stuff needed (/lib, /node_modules) to /dist
		'write_run_bat' # write a start.bat file to /dist
		'compress:dist' # zip up /dist
	]