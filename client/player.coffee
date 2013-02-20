@endSong = () ->
  $currentSong = $('.playing-track audio').get(0)
  endTime = $currentSong.duration - 5
  $currentSong.currentTime = endTime

$(window).load ->
  $("#tracks").on "click", "li.track", ->
    event.preventDefault()
    playtrack(@)

  playtrack = (newTrack) ->
    $clickedTrack = $(newTrack)
    audio = $clickedTrack.find("audio").get(0)

    # remove class from all currently playing tracks
    $('.playing-track').removeClass("playing-track").addClass("not-playing")

    # add playing-track to clicked track
    $clickedTrack.removeClass("not-playing").addClass("playing-track")

    $(audio).on("play", ->
      $(@).addClass "playing"
      $clickedTrack.removeClass "paused"
    ).on("pause", ->
      $(@).removeClass "playing"
      $clickedTrack.addClass "paused"
    ).on "ended", ->
      $(@).removeClass "playing"
      $clickedTrack.removeClass("playing-track").addClass("not-playing")
      playNextTrack($clickedTrack)

    playOrPause(audio)
    showBuffer($clickedTrack)
    showTrackProgress($clickedTrack, audio)
    pauseAllOtherTracks()

  playOrPause = (audio) ->
    if audio.paused
      audio.play()
    else
      audio.pause()

  playNextTrack = (previousTrack) ->
    nextTrack = previousTrack.next()
    playtrack(nextTrack)

  pauseAllOtherTracks = () ->
    $('.not-playing audio').each ->
      @pause()
      @currentTime = 0 if @currentTime > 0

  # Show loading Indicator
  showBuffer = (track) ->
    audio = track.find('audio').get(0)
    loadingIndicator  = track.find('.buffer')
    if (audio.buffered isnt 'undefined')
      $(audio).on "progress", ->
        loaded = parseInt(((audio.buffered.end(0) / audio.duration) * 100), 10)
        loadingIndicator.css width: loaded + "%"

  showTrackProgress = (track, audio) ->
    progressIndicator = track.find('.progress')
    $(audio).bind "timeupdate", ->
      pos = (audio.currentTime / audio.duration) * 100
      progressIndicator.css width: pos + "%"
      unless loaded
        loaded = true

