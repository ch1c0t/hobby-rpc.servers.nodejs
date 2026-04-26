require '@ch1c0t/ext'

{ CreateTestEnvironment } = require './run_specs/CreateTestEnvironment.coffee'

run = ->
  global.TE = await CreateTestEnvironment()
  p "Created a test environment directory at"
  p TE.dir

  TE.jasmine.execute()
    .then (info) ->
      if info.overallStatus is 'failed'
        process.exit 3
    .catch (error) ->
      console.error error
      process.exit 3
    .finally ->
      for task in TE.tasks
        { pid } = task
        try
          process.kill pid
        catch error
          # ESRCH: The task PID does tot exist.
          unless error.code is 'ESRCH'
            console.error error
          continue

run()
