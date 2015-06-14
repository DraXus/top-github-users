#!/usr/bin/env coffee

city=process.argv[2]
fs = require 'fs'

# Reducer.
minimum = (min, current) ->
  if current < min
    current
  else
    min

top = (stats, field, type) ->
  get = (stat) ->
    value = stat[field]
    if type is 'list' then value.length else value

  format = (stat) ->
    value = get stat
    switch type
      when 'thousands' then "#{(value / 1000)}k"
      else value

  stats
    .slice()
    .sort (a, b) ->
      get(b) - get(a)
    .slice(0, 15)
    .map (stat) ->
      login = stat.login
      "[#{login}](https://github.com/#{login}) (#{format stat})"
    .join ', '

stats2markdown = (datafile, mdfile, title) ->
  stats = require(datafile)
  minFollowers = stats.map((_) -> _.followers).reduce(minimum, 1000)
  maxNumber = 256

  today = new Date()
  from = new Date()
  from.setYear today.getFullYear() - 1

  out = """
  # Top GitHub Users

  This ranking only takes into account the contributions to public repositories (issues, pull requests and commits) of GitHub.com from  **#{from.toGMTString()}** to **#{today.toGMTString()}**.

  Get the script [here](https://github.com/DraXus/top-github-users)). Original code by @paulmillr, @lifesinger and @JJ.

  <table cellspacing="0"><thead>
  <th scope="col">#</th>
  <th scope="col">User</th>
  <th scope="col">Contribs</th>
  <th scope="col">Language</th>
  <th scope="col">Location</th>
  <th scope="col" width="30"></th>
  </thead><tbody>\n
  """

  rows = stats.slice(0, maxNumber).map (stat, index) ->
    """
    <tr>
      <th scope="row">##{index + 1}</th>
      <td><a href="https://github.com/#{stat.login}">#{stat.login}</a>#{if stat.name then ' (' + stat.name + ')' else ''}</td>
      <td>#{stat.contributions}</td>
      <td>#{stat.language}</td>
      <td>#{stat.location}</td>
      <td><img width="30" height="30" src="#{stat.gravatar.replace('?s=400', '?s=30')}"></td>
    </tr>
    """.replace(/\n/g, '')

  out += "#{rows.join('\n')}\n</tbody></table>\n\n"

  out += """## Top 10 users from this list by other metrics:

* **Followers:** #{top stats, 'followers', 'thousands'}
* **Current contributions streak:** #{top stats, 'contributionsCurrentStreak'}
* **Organisations:** #{top stats, 'organizations', 'list'}
  """

  fs.writeFileSync mdfile, out
  console.log 'Saved to', mdfile

stats2markdown './raw/github-users-stats-'+city+'.json', './formatted/active-'+city+'.md'
