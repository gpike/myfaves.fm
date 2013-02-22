Songs = new Meteor.Collection(null)
soundcloud_id = "dcfa20cb4e60440dbf3e8bb3c54b68a8"

class TrackParser
  constructor: (track_data) ->
    @track = track_data
    @artist = @track.artist
    @title = @track.title

  url: ->
    if @track.url.search("soundcloud") isnt -1
      soundcloudURL = @track.url + '?client_id=' + soundcloud_id
      @track.url = soundcloudURL
    else
      @track.url

  data: ->
    artist: @artist
    title: @title
    url: @url()

if Meteor.isClient
  url = "http://ex.fm/api/v3/user/plapier/loved?" + "results=20"
  Meteor.http.get url, (error, results) ->
    tracks_data = JSON.parse(results.content)
    for track_data in tracks_data.songs
      parsed_track = new TrackParser(track_data)
      Songs.insert parsed_track.data()

  Template.Songs.Tracks = ->
    Songs.find({})

  # Template.Songs.events "click input": ->
    # # template data, if any, is available in 'this'
    # console.log "You pressed the button"  if typeof console isnt "undefined"

if Meteor.isServer
  Meteor.startup ->
# code to run on server at startup

