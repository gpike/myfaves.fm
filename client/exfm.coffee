Session.setDefault('exfm_username', null)
Session.setDefault('exfm_start', 0)
Session.setDefault('exfm_results', 21)
Session.set('exfm_collection', 1)
Session.set('exfm_results_total', null)
Session.set('exfm_tracks', [])
Session.set('exfm_status', null)

class @ExfmTrackParser
  constructor: (source, track_data, date_loved) ->
    @source = source
    @track  = track_data
    @artist = @track.artist
    @title  = @track.title
    @setDate(date_loved)

  setDate: (date_loved) ->
    if date_loved
      @date_loved = date_loved
    else
      @date_loved = moment.utc(@track.user_love.created_on).format()

  url: ->
    if @track.url.search("soundcloud") isnt -1
      soundcloudURL = @track.url + '?client_id=' + soundcloud_id
      @track.url = soundcloudURL
    else
      @track.url

  data: ->
    collection: Session.get("#{@source}_collection")
    source: @source
    artist: @artist
    title:  @title
    url:    @url()
    date_loved: @date_loved

class @ExfmJSONFetcher
  constructor: ->
    @username    = Session.getNonReactive('exfm_username')
    @num_start   = Session.get('exfm_start') ## Reactive for fetchingMore
    @num_results = Session.getNonReactive('exfm_results')
    @getResults()

  getResults: ->
    url = "http://ex.fm/api/v3/user/#{@username}/loved?start=#{@num_start}&results=#{@num_results}"
    Meteor.http.get url, (error, results) =>
      if error
        # flash.error 'exfm', "exfm couldn't be reached. The service might be down."
        Session.set('exfm_status', 'ready')

      else if results.statusCode is 200
        @insertNewTracks(results.data)

      else if results.statusCode is 404
        console.log results.data.status_text
        $('#exfm_username').addClass('error')
        flash.error 'exfm', "Exfm: User doesn't exist"

      else
        console.log "Something went wrong with exfm"
        Session.set('exfm_status', 'ready')

  insertNewTracks: (json_data) ->
    if json_data.results is 0
      flash.info 'exfm', "Exfm: #{@username} has 0 favorite tracks"

    tracks_data = json_data.songs
    Session.set('exfm_results_total', json_data.total)
    tracks = []
    for track in tracks_data
      parsed_track = new ExfmTrackParser("exfm", track)
      tracks.push(parsed_track.data())
    Session.set('exfm_tracks', tracks)
    Session.set('exfm_status', 'ready')

@ResetSessionVars = ->
  Session.set('exfm_start', 0)
  Session.set('exfm_results_total', null)

@FetchMoreExfm = ->
  if Session.getNonReactive('exfm_username')
    num_start      = Session.getNonReactive('exfm_start')
    num_results    = Session.getNonReactive('exfm_results')
    total_results  = Session.getNonReactive("exfm_results_total")
    collection_num = Session.getNonReactive('exfm_collection')
    if num_start <= total_results
      Session.set("exfm_status", 'Fetching...')
      Session.set('exfm_start', num_start + num_results)
      Session.set('exfm_collection', collection_num + 1)
