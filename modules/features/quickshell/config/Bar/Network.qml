pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  required property HyprlandMonitor monitor
  property double networkDisplayHeight: 80

  animOffset: 250
  boxColor: Colors.red
  boxHeight: 25
  boxHeightOpened: root.networkDisplayHeight
  boxWidth: 33
  boxWidthOpened: 350
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: !NetworkManager.connectedWifi
  openedItem: networkDisplay

  Component {
	id: icon

	StyledText {
	  horizontalAlignment: Qt.AlignCenter
	  propo: true
	  text: NetworkManager.getNetworkDetails(NetworkManager.defaultAdapter)["icon"] || "󰤭"
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: networkDisplay

	Item {
	  id: networkDisplayRoot

	  property double innerMargin: 5
	  property double outerMargin: 6

	  Rectangle {
		id: networkDisplayBg

		anchors.fill: parent
		anchors.margins: networkDisplayRoot.outerMargin
		color: Colors.surface1
		radius: 8

		RowLayout {
		  anchors.fill: parent

		  Rectangle {
			id: iconBox

			property double iconBoxRadius: 5

			Layout.fillHeight: true
			Layout.margins: networkDisplayRoot.innerMargin
			color: Colors.red
			implicitWidth: root.networkDisplayHeight - (networkDisplayRoot.innerMargin * 2) - (
							 networkDisplayRoot.outerMargin * 2)
			radius: 5

			CenteredText {
			  fontSize: 23
			  propo: true
			  text: NetworkManager.getNetworkDetails(NetworkManager.defaultAdapter)["icon"]
			}
		  }

		  Column {
			id: networkColumn

			property var networkInfo: NetworkManager.getNetworkDetails(NetworkManager.defaultAdapter)

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true

			StyledText {
			  color: Colors.text
			  fontSize: 14
			  text: networkColumn.networkInfo["networkName"]
			}

			StyledText {
			  color: Colors.subtext1
			  fontSize: 12
			  fontWeight: 5
			  text: networkColumn.networkInfo["ipAddress"] + " on "
			  + networkColumn.networkInfo["adapterName"]
			}

			StyledText {
			  property var timeInfo: networkColumn.networkInfo["time"]

			  color: Colors.subtext1
			  fontSize: 12
			  fontWeight: 5
			  text: "Network Details " + (networkColumn.networkInfo["saved"] == true ? "Saved" : "Not Saved")
			}
		  }
		}
	  }
	}
  }
}
