pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./Bar"
import "./Services/"
import "Color.js" as Colors

Scope {
  Variants {
	id: panelDelegate

	delegate: panelWindow
	model: Quickshell.screens
  }

  Component {
	id: panelWindow

	PanelWindow {
	  id: win

	  property double barExclusionZone: 15
	  property double barMaxHeight: modelData.height
	  required property var modelData
	  property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

	  WlrLayershell.keyboardFocus: monitor.focused == true ? IpcManager.focusState :
															 WlrKeyboardFocus.None
	  color: "transparent"
	  exclusionMode: ExclusionMode.Normal
	  exclusiveZone: barExclusionZone
	  implicitHeight: barMaxHeight
	  mask: maskRegion
	  screen: modelData

	  Rectangle {
		id: blurOverlay

		color: Colors.base
		implicitHeight: win.modelData.height
		implicitWidth: win.modelData.width
		opacity: IpcManager.logoutMenuOpen == true ? 0.8 : 0

		Behavior on opacity {
		  NumberAnimation {
			duration: 200
		  }
		}
	  }

	  Region {
		id: maskRegion

		Region {
		  item: left
		}

		Region {
		  item: center
		}

		Region {
		  item: right
		}
	  }

	  anchors {
		left: true
		right: true
		top: true
	  }

	  MultiEffect {
		anchors.fill: rowContainer
		shadowBlur: 1.5
		shadowColor: Colors.mantle
		shadowEnabled: true
		shadowHorizontalOffset: 5
		shadowOpacity: 1
		shadowVerticalOffset: 3
		source: rowContainer
	  }

	  Item {
		id: rowContainer

		anchors {
		  fill: parent
		  topMargin: 3
		}

		anchors {
		  left: parent.left
		  leftMargin: 3
		  right: parent.right
		  rightMargin: 3
		  top: parent.top
		}

		Row {
		  id: left

		  anchors {
			left: parent.left
			top: parent.top
		  }

		  WorkspaceSelector {
			monitor: win.monitor
		  }
		}

		Row {
		  id: center

		  anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
		  }

		  Time {
			monitor: win.monitor
		  }
		}

		Row {
		  id: right

		  Layout.alignment: Qt.AlignTop
		  spacing: 5

		  anchors {
			right: parent.right
			top: parent.top
		  }

		  Network {
			monitor: win.monitor
		  }

		  Bluetooth {
			monitor: win.monitor
		  }

		  Battery {
			monitor: win.monitor
		  }
		}
	  }
	}
  }
}
