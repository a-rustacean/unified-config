pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  property Notification latestNotif
  property bool logout: false
  property double logoutHeight: 100
  property double logoutMargin: 7
  property double logoutSpacing: 5
  required property HyprlandMonitor monitor
  property bool mpris: false
  property double mprisHeight: 60
  property double mprisWidth: 350
  property double notificationHeight: 100
  property double notificationWidth: 350
  property bool notified: false

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true

  states: [
	State {
	  name: "notified"
	  when: root.notified == true

	  PropertyChanges {
		root.boxHeight: root.notificationHeight
		root.boxRadius: 12
		root.boxWidth: root.notificationWidth
		root.visibleTopMargin: 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(notification);
		  notificationTimer.restart();
		}
	  }
	},
	State {
	  name: "mpris"
	  when: root.mpris == true

	  PropertyChanges {
		root.boxHeight: root.mprisHeight
		root.boxRadius: 12
		root.boxWidth: root.mprisWidth
		root.visibleTopMargin: root.hovered == true ? 0 : 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(mprisToast);
		  if (root.hovered != true) {
			mprisTimer.restart();
		  }
		}
	  }
	},
	State {
	  name: "logout"
	  when: root.logout == true

	  PropertyChanges {
		root.boxHeight: root.logoutHeight
		root.boxRadius: 13
		root.boxWidth: ((root.logoutHeight - (root.logoutMargin * 2)) * 5) + (root.logoutMargin * 2) + (
						 root.logoutSpacing * 4)
		root.visibleTopMargin: 10
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(logoutMenu);
		}
	  }
	}
  ]

  onHoveredChanged: {
	if (root.hovered == true) {
	  if (root.logout == false) {
		if (MprisManager.getPlaying() == true) {
		  root.overriden = true;
		  root.mpris = true;
		}
	  }
	} else { // Hovered == false
	  if (root.logout == true) {
		IpcManager.closeLogoutMenu();
	  } else {
		root.overriden = false;
		root.mpris = false;
	  }
	}
  }

  Connections {
	function onCloseLogoutMenu() {
	  root.overriden = false;
	  root.logout = false;
	}

	function onLogoutMenu() {
	  root.overriden = false;
	  root.mpris = false;
	  mprisTimer.stop();
	  root.notified = false;
	  notificationTimer.stop();
	  if (root.monitor.focused == true) {
		root.overriden = true;
		root.logout = true;
	  }
	}

	target: IpcManager
  }

  Connections {
	function onNewNotification() {
	  notification => {
		if (notification.lastGeneration == false) {
		  root.latestNotif = notification;
		  root.overriden = true;
		  root.notified = true;
		}
	  };
	}

	target: NotificationManager
  }

  Connections {
	function onTrackChanged() {
	  if (root.overriden != true && root.hovered != true) {
		root.overriden = true;
		root.mpris = true;
	  }
	}

	target: MprisManager.defaultPlayer
  }

  Timer {
	id: notificationTimer

	interval: 5000
	repeat: false
	running: false

	onTriggered: {
	  root.notified = false;
	  root.overriden = false;
	}
  }

  Timer {
	id: mprisTimer

	interval: 3000
	repeat: false
	running: false

	onTriggered: {
	  root.mpris = false;
	  root.overriden = false;
	}
  }

  Component {
	id: logoutMenu

	Item {
	  id: logoutMenuRoot

	  property var logoutModel: [
		{
		  color: Colors.red,
		  text: "",
		  key: Qt.Key_S,
		  command: ["systemctl", "poweroff"]
		},
		{
		  color: Colors.peach,
		  text: "󰗽",
		  key: Qt.Key_E,
		  command: ["hyprctl", "dispatch", "exit"]
		},
		{
		  color: Colors.yellow,
		  text: "󰑓",
		  key: Qt.Key_R,
		  command: ["systemctl", "reboot"]
		},
		{
		  color: Colors.green,
		  text: "󰌾",
		  key: Qt.Key_L,
		  command: ["hyprlock"]
		},
		{
		  color: Colors.sky,
		  text: "󰤄",
		  key: Qt.Key_U,
		  command: ["systemctl", "suspend"]
		},
	  ]

	  Component.onCompleted: {
		forceActiveFocus();
	  }
	  Keys.onPressed: event => {
		if (event.key == Qt.Key_Escape) {
		  IpcManager.closeLogoutMenu();
		} else {
		  for (let button of logoutMenuRoot.logoutModel) {
			if (button.key == event.key) {
			  IpcManager.closeLogoutMenu();
			  event.accepted = true;
			  Quickshell.execDetached(button.command);
			}
		  }
		}
	  }

	  RowLayout {
		spacing: root.logoutSpacing

		anchors {
		  fill: parent
		  margins: root.logoutMargin
		}

		Repeater {
		  delegate: logoutButton
		  model: logoutMenuRoot.logoutModel
		}

		Component {
		  id: logoutButton

		  Item {
			id: logoutButtonRoot

			required property var modelData

			Layout.fillHeight: true
			Layout.fillWidth: true

			HoverHandler {
			  id: logoutHoverHandler

			  onHoveredChanged: {
				if (logoutHoverHandler.hovered == true) {
				  buttonBackground.color = Colors.surface1;
				  logoutButtonText.color = logoutButtonRoot.modelData.color;
				} else {
				  buttonBackground.color = logoutButtonRoot.modelData.color;
				  logoutButtonText.color = Colors.base;
				}
			  }
			}

			TapHandler {
			  onTapped: {
				Quickshell.execDetached(logoutButtonRoot.modelData.command);
			  }
			}

			Rectangle {
			  id: buttonBackground

			  anchors.fill: parent
			  color: logoutButtonRoot.modelData.color
			  radius: 7

			  Behavior on color {
				ColorAnimation {
				  duration: 100
				}
			  }

			  StyledText {
				id: logoutButtonText

				anchors.fill: parent
				fontSize: 25
				horizontalAlignment: Qt.AlignHCenter
				propo: true
				text: logoutButtonRoot.modelData.text
				verticalAlignment: Qt.AlignVCenter

				Behavior on color {
				  ColorAnimation {
					duration: 100
				  }
				}
			  }
			}
		  }
		}
	  }
	}
  }

  Component {
	id: time

	StyledText {
	  property string component: "time"

	  horizontalAlignment: Qt.AlignCenter
	  text: TimeManager.time
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: notification

	Item {
	  id: notificationRoot

	  property double innerMargin: 5
	  property double outerMargin: 6

	  function getInnerHeight() {
		let fullHeight = root.notificationHeight;
		let fullMargin = notificationRoot.innerMargin + notificationRoot.outerMargin;

		return fullHeight - (fullMargin * 2);
	  }

	  Rectangle {
		color: Colors.surface1
		radius: 9

		anchors {
		  fill: parent
		  margins: notificationRoot.outerMargin
		}

		RowLayout {
		  Rectangle {
			Layout.margins: notificationRoot.innerMargin
			color: Colors.mauve
			implicitHeight: notificationRoot.getInnerHeight()
			implicitWidth: notificationRoot.getInnerHeight()
			radius: 5

			IconImage {
			  anchors.fill: parent
			  anchors.margins: 10
			  source: root.latestNotif.image
			}
		  }

		  ColumnLayout {
			property double textMargin: 4

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			Layout.leftMargin: 0
			Layout.margins: notificationRoot.innerMargin + textMargin

			StyledText {
			  color: Colors.text
			  fontSize: 14
			  text: root.latestNotif.summary
			}

			StyledText {
			  Layout.fillHeight: true
			  Layout.maximumWidth: root.notificationWidth - ((notificationRoot.outerMargin * 2) + (
															   notificationRoot.innerMargin * 3) + notificationRoot.getInnerHeight())
			  color: Colors.subtext0
			  elide: Qt.ElideRight
			  fontWeight: 5
			  maximumLineCount: 2
			  text: root.latestNotif.body
			  wrapMode: Text.WordWrap
			}
		  }
		}
	  }
	}
  }

  Component {
	id: mprisToast

	Item {
	  id: mprisToastRoot

	  property double innerMargin: 4
	  property double outerMargin: 4
	  property var trackInfo: MprisManager.getTrackInfo()

	  function getInnerHeight() {
		let fullHeight = root.mprisHeight;
		let fullMargin = mprisToastRoot.innerMargin + mprisToastRoot.outerMargin;

		return fullHeight - (fullMargin * 2);
	  }

	  TapHandler {
		acceptedButtons: Qt.RightButton

		onTapped: MprisManager.skip()
	  }

	  TapHandler {
		acceptedButtons: Qt.LeftButton

		onTapped: MprisManager.prev()
	  }

	  Rectangle {
		color: Colors.surface1
		radius: 9

		anchors {
		  fill: parent
		  margins: mprisToastRoot.outerMargin
		}

		RowLayout {
		  Rectangle {
			Layout.margins: mprisToastRoot.innerMargin
			color: Colors.mauve
			implicitHeight: mprisToastRoot.getInnerHeight()
			implicitWidth: mprisToastRoot.getInnerHeight()
			radius: 5

			Image {
			  anchors.centerIn: parent

			  // Non-blocking load for local or remote track art
			  asynchronous: true

			  // Optional: clips the overflowing parts of the cropped image to the 1:1 box
			  clip: true

			  // Zoom and crop from the center to fill the square completely
			  fillMode: Image.PreserveAspectCrop
			  height: width
			  source: mprisToastRoot.trackInfo["albumArt"] ?? ""

			  // Force a 1:1 square target area based on the parent container
			  width: Math.min(parent.width, parent.height)
			}
		  }

		  ColumnLayout {
			property double textMargin: 1

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			Layout.leftMargin: 0
			Layout.margins: mprisToastRoot.innerMargin + textMargin

			StyledText {
			  Layout.maximumWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())
			  color: Colors.text
			  fontSize: 14
			  text: mprisToastRoot.trackInfo["name"] + " - " + mprisToastRoot.trackInfo["artist"]
			}

			Item {
			  Layout.fillHeight: true
			  Layout.fillWidth: true
			  Layout.maximumWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())
			  Layout.preferredWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														  mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())

			  Rectangle {
				anchors.fill: parent
				color: Colors.overlay0
				radius: 100

				Rectangle {
				  color: Colors.mauve
				  implicitWidth: parent.width * mprisToastRoot.trackInfo["lengthPercent"]
				  radius: 100

				  anchors {
					bottom: parent.bottom
					left: parent.left
					top: parent.top
				  }
				}

				StyledText {
				  text: MprisManager.getTimeString()

				  anchors {
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
				  }
				}
			  }
			}
		  }
		}
	  }
	}
  }
}
