pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  property MprisPlayer defaultPlayer: Mpris.players.values[0] || null

  function getPlaying() {
	if (!defaultPlayer) {
	  return false;
	} else {
	  return defaultPlayer.playbackState == MprisPlaybackState.Playing;
	}
  }

  function getTimeString() {
	let trackInfo = getTrackInfo();
	let position = trackInfo["position"];
	let length = trackInfo["length"];
	if (length.hours > 0) {
	  return position.hours + ":" + position.minutes + ":" + position.seconds + "/" + length.hours
		  + ":" + length.minutes + ":" + length.seconds;
	} else {
	  return position.minutes + ":" + position.seconds + "/" + length.minutes + ":" + length.seconds;
	}
  }

  function getTrackInfo() {
	let trackName = root.defaultPlayer.trackTitle;
	let trackArtist = root.defaultPlayer.trackArtist;
	let trackAlbum = root.defaultPlayer.trackAlbum;
	let trackPosition = root.defaultPlayer.position;
	let trackLength = root.defaultPlayer.length;
	let trackArt = root.defaultPlayer.trackArtUrl;
	return {
	  "name": trackName,
	  "artist": trackArtist,
	  "album": trackAlbum,
	  "position": msToArray(trackPosition),
	  "length": msToArray(trackLength),
	  "lengthRemaining": msToArray(trackLength - trackPosition),
	  "lengthPercent": trackPosition / trackLength,
	  "albumArt": trackArt
	};
  }

  function msToArray(time) {
	time = Math.max(0, Number(time));

	const inthours = Math.floor(time / 3600000);
	const intminutes = Math.floor((time % 3600000) / 60000);
	const intseconds = Math.floor((time % 60000) / 1000);

	const hours = String(inthours).padStart(2, "0");
	const minutes = String(intminutes).padStart(2, "0");
	const seconds = String(intseconds).padStart(2, "0");

	return {
	  hours,
	  minutes,
	  seconds
	};
  }

  function prev() {
	defaultPlayer.previous();
  }

  function skip() {
	defaultPlayer.next();
  }
}
