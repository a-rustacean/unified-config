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

  property double devicePlaqueHeight: 60
  property double devicePlaqueSpacing: 4
  required property HyprlandMonitor monitor

  animOffset: 200
  boxColor: Colors.peach
  boxHeight: 25
  boxHeightOpened: (root.devicePlaqueHeight * BluetoothManager.getConnectedDevicesList().length) + (
					 root.devicePlaqueSpacing * (BluetoothManager.getConnectedDevicesList().length + 1)) + 2
  boxWidth: 33
  boxWidthOpened: 350
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: !BluetoothManager.anyConnected
  openedItem: deviceList

  Component {
	id: icon

	StyledText {
	  property string component: "icon"

	  horizontalAlignment: Qt.AlignCenter
	  propo: true
	  text: "󰂱"
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: deviceList

	Column {
	  id: deviceListRoot

	  property string component: "deviceList"
	  property double plaqueHeight: root.devicePlaqueHeight
	  property double plaqueSpacing: root.devicePlaqueSpacing

	  spacing: plaqueSpacing

	  Item {
		implicitHeight: 1
		implicitWidth: 10
	  }

	  Repeater {
		delegate: devicePlaque
		model: BluetoothManager.getConnectedDevicesList()
	  }

	  Component {
		id: devicePlaque

		Rectangle {
		  id: devicePlaqueRoot

		  readonly property variant deviceText: BluetoothManager.getDeviceText(modelData)
		  readonly property double margin: 5
		  required property var modelData

		  color: Colors.surface1
		  implicitHeight: deviceListRoot.plaqueHeight
		  radius: 10

		  anchors {
			left: parent.left
			leftMargin: devicePlaqueRoot.margin
			right: parent.right
			rightMargin: devicePlaqueRoot.margin
		  }

		  RowLayout {
			id: deviceInfoRow

			property double margin: 7

			spacing: margin * 2

			anchors {
			  fill: parent
			  leftMargin: margin
			}

			Rectangle {
			  id: iconContainer

			  property double boxRadius: 4

			  color: Colors.text
			  implicitHeight: deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2)
			  implicitWidth: deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2)
			  radius: boxRadius

			  Rectangle {
				id: batteryIndicator

				color: Colors.green
				implicitHeight: (deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2))
								* devicePlaqueRoot.deviceText["batteryRaw"]
				radius: iconContainer.boxRadius

				anchors {
				  bottom: parent.bottom
				  left: parent.left
				  right: parent.right
				}
			  }

			  HoverHandler {
				id: batteryHoverHandler

				onHoveredChanged: {
				  if (batteryHoverHandler.hovered == true) {
					batteryText.text = devicePlaqueRoot.deviceText["battery"];
				  } else {
					batteryText.text = devicePlaqueRoot.deviceText["icon"];
				  }
				}
			  }

			  CenteredText {
				id: batteryText

				fontSize: 17
				text: devicePlaqueRoot.deviceText["icon"]
			  }
			}

			Column {
			  Layout.alignment: Qt.AlignVCenter
			  Layout.fillWidth: true

			  StyledText {
				color: Colors.text
				fontSize: 14
				text: devicePlaqueRoot.deviceText["name"]
			  }

			  StyledText {
				color: Colors.subtext1
				fontSize: 10
				text: devicePlaqueRoot.deviceText["mac"]
			  }
			}
		  }
		}
	  }
	}
  }
}
