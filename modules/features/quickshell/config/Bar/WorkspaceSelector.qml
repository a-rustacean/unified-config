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

  property double barHeight: 25
  required property HyprlandMonitor monitor
  property double rowLeftMargin: 5
  property double workspaceButtonSpacing: 4
  property double workspaceCount: WorkspaceManager.getNumberOfWorkspaces(monitor)
  property double workspaceWidth: 17

  boxHeight: barHeight
  boxRadius: 8
  boxWidth: (2 * rowLeftMargin) + (workspaceCount * workspaceWidth) + ((workspaceCount - 1)
																	   * workspaceButtonSpacing)
  defaultItem: placeholder
  exclusiveMonitor: monitor

  Component {
	id: placeholder

	Item {}
  }

  RowLayout {
	spacing: root.workspaceButtonSpacing

	anchors {
	  bottom: parent.bottom
	  left: parent.left
	  leftMargin: root.rowLeftMargin
	  top: parent.top
	}

	Repeater {
	  delegate: workspaceButton
	  delegateModelAccess: DelegateModel.ReadOnly
	  model: WorkspaceManager.getWorkspacesForMonitor(root.exclusiveMonitor)
	}

	Component {
	  id: workspaceButton

	  Item {
		id: buttonRoot

		required property var modelData
		property double stateInt: WorkspaceManager.getWorkspaceStateIndex(modelData)
		property variant workspaceColors: [Colors.lavender, Colors.overlay2, Colors.surface2]
		property string workspaceId: modelData.id

		Layout.alignment: Qt.AlignLeft
		implicitHeight: root.barHeight - 7
		implicitWidth: root.workspaceWidth

		Behavior on implicitHeight {
		  SpringAnimation {
			damping: 0.3
			spring: 4
		  }
		}
		Behavior on implicitWidth {
		  SpringAnimation {
			damping: 0.3
			spring: 4
		  }
		}

		TapHandler {
		  id: tapHandler

		  onTapped: WorkspaceManager.activateWorkspaceById(buttonRoot.modelData.id)
		}

		Rectangle {
		  anchors.fill: parent
		  color: buttonRoot.workspaceColors[buttonRoot.stateInt]
		  radius: 4

		  CenteredText {
			text: buttonRoot.modelData.id
		  }
		}
	  }
	}
  }
}
