# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->
  robot.router.post '/hubot/admins', (req, res) ->
    botToken = process.env.HUBOT_BOT_TOKEN
    apiToken = process.env.HUBOT_API_TOKEN
    payload = req.body

    if (payload.token != botToken)
      console.log 'Bad request'
      res.writeHead 400
      res.end 'Invalid token'
      return


    userQuery = "https://slack.com/api/users.list?token=#{apiToken}&presence=1&pretty=1"
    # Query for users
    robot.http(userQuery)
    .get() (err, queryRes, body) ->
      if err
        console.log "Encountered error #{err}"
        res.writeHead 400
        res.end 'Encountered error'
        return

      # Leave as a list of items to be post-processed because we may want to do
      # more with it someday than simply format it.
      admins = (mem for mem in (JSON.parse body).members when mem.is_admin).map (data) ->
        [data.name, data.real_name, (data.presence == 'active')]

      # response_info = ''
      msgConcat = (admin) ->
        "#{admin[0]}: #{admin[1]} is " + (if admin[2] then '' else 'not ') + "online\n"

      res.send (msgConcat(admin) for admin in admins).toString()
