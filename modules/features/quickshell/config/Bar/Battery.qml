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

  property double batteryDisplayHeight: 100
  required property HyprlandMonitor monitor
  property bool opened: false
  property double radius: 9

  animOffset: 150
  boxColor: Colors.green
  boxHeight: 25
  boxHeightOpened: root.batteryDisplayHeight
  boxRadius: radius
  boxWidth: 60
  boxWidthOpened: 410
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: !BatteryManager.hasLaptopBattery
  openedItem: batteryDisplay

  Component {
	id: icon

	Item {
	  BatteryGradient {}

	  CenteredText {
		property string component: "icon"

		propo: true
		text: BatteryManager.getBatteryText()
	  }
	}
  }

  Component {
	id: batteryDisplay

	Item {
	  id: batteryDisplayRoot

	  property double innerMargin: 5
	  property double outerMargin: 6

	  BatteryGradient {}

	  Rectangle {
		id: batteryBackground

		anchors.fill: parent
		anchors.margins: batteryDisplayRoot.outerMargin
		color: Colors.surface1
		radius: 8

		RowLayout {
		  anchors.fill: parent

		  Rectangle {
			id: percentBox

			property double percentBoxRadius: 5

			Layout.fillHeight: true
			Layout.margins: batteryDisplayRoot.innerMargin
			color: Colors.text
			implicitWidth: root.batteryDisplayHeight - (batteryDisplayRoot.innerMargin * 2) - (
							 batteryDisplayRoot.outerMargin * 2)
			radius: 5

			Rectangle {
			  color: Colors.green
			  implicitHeight: (root.batteryDisplayHeight - (batteryDisplayRoot.innerMargin * 2) - (
								 batteryDisplayRoot.outerMargin * 2)) * BatteryManager.mainBattery.percentage
			  radius: percentBox.percentBoxRadius

			  anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			  }
			}

			CenteredText {
			  fontSize: 15
			  text: BatteryManager.getBatteryPercentage(BatteryManager.mainBattery) + "%"
			}
		  }

		  Column {
			id: batColumn

			property var batInfo: BatteryManager.getMainBatteryInfo()

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true

			StyledText {
			  color: Colors.text
			  fontSize: 14
			  text: "Battery - " + batColumn.batInfo["name"]
			}

			StyledText {
			  color: Colors.subtext1
			  fontSize: 12
			  fontWeight: 5
			  text: batColumn.batInfo["energy"] + "/" + batColumn.batInfo["capacity"] + "Wh - "
			  + BatteryManager.getChargingRateFormat()
			}

			StyledText {
			  property var timeInfo: batColumn.batInfo["time"]

			  color: Colors.subtext1
			  fontSize: 12
			  fontWeight: 5
			  text: BatteryManager.getTimeFormat()
			}
		  }
		}
	  }
	}
  }

  component BatteryGradient: MidpointGradient {
	anchors.fill: parent
	angle: -45
	blur: 0.6
	color: BatteryManager.getBatteryColor()
	midpoint: 0.55
	radius: radius
  }
}
