import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors

Item {
  id: root

  property bool _fullyHidden: false
  property bool _widthCollapsed: false
  property double animOffset: 0
  property color boxColor: Colors.surface0
  property double boxHeight: 28
  property double boxHeightOpened: 150
  property bool boxOpened: false
  property double boxRadius: 9
  property double boxRadiusOpened: 12
  property double boxWidth: 100
  property double boxWidthOpened: 200
  readonly property double calculatedTopMargin: {
	if (!root.exclusiveToScreen) {
	  return visibleTopMargin;
	}

	if (Hyprland.focusedMonitor == root.exclusiveMonitor) {
	  if (!root.forceHidden) {
		return visibleTopMargin;
	  } else if (root.hoverableWhenHidden) {
		return 7 - root.boxHeight - 5;
	  }
	}

	return -4 - root.boxHeight - 5;
  }
  property Component defaultItem
  required property HyprlandMonitor exclusiveMonitor
  property bool exclusiveToScreen: false
  property bool forceHidden: false
  property alias hover: hoverHandler
  property bool hoverableWhenHidden: false
  property bool hovered: false
  property Component openedItem
  property bool overriden: false
  property alias rect: container
  property alias stack: containerContent
  property alias tap: tapHandler
  property double visibleTopMargin: 0

  implicitHeight: boxHeight
  implicitWidth: root._widthCollapsed ? 0 : root.boxWidth
  visible: !root._fullyHidden

  Behavior on anchors.topMargin {
	animation: defaultCurve
  }
  Behavior on boxRadius {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }
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
  states: [
	State {
	  name: "closed"
	  when: root.hovered == false && root.boxOpened == false && root.overriden == false

	  PropertyChanges {
		container.radius: root.boxRadius
		root.implicitHeight: root.boxHeight
		root.implicitWidth: root.boxWidth
	  }

	  StateChangeScript {
		script: {
		  stack.replace(root.defaultItem);
		}
	  }
	},
	State {
	  name: "hovered"
	  when: root.hovered == true && root.boxOpened == false && root.overriden == false

	  PropertyChanges {
		container.radius: root.boxRadius + 3
		root.implicitHeight: root.boxHeight + 2
		root.implicitWidth: root.boxWidth + 2
	  }

	  StateChangeScript {
		script: {
		  stack.replace(root.defaultItem);
		}
	  }
	},
	State {
	  name: "opened"
	  when: root.boxOpened == true && root.hovered == true && root.overriden == false

	  PropertyChanges {
		container.radius: root.boxRadiusOpened
		root.implicitHeight: root.boxHeightOpened
		root.implicitWidth: root.boxWidthOpened
	  }

	  StateChangeScript {
		script: {
		  stack.replace(root.openedItem);
		}
	  }
	}
  ]

  onForceHiddenChanged: {
	if (root.forceHidden == true) {
	  hideTimer.restart();
	} else {
	  hideTimer.stop();
	  subHideTimer.stop();
	  root._fullyHidden = false;
	  root._widthCollapsed = false;
	}
  }

  Timer {
	id: hideTimer

	interval: 250
	repeat: false
	running: false

	onTriggered: {
	  root._widthCollapsed = true;
	  subHideTimer.restart();
	}
  }

  Timer {
	id: subHideTimer

	interval: 200
	repeat: false
	running: false

	onTriggered: {
	  root._fullyHidden = true;
	}
  }

  anchors {
	top: parent.top
	topMargin: calculatedTopMargin
  }

  NumberAnimation {
	id: defaultCurve

	duration: 200 + root.animOffset
	easing: Easing.InOutBack
  }

  HoverHandler {
	id: hoverHandler

	onHoveredChanged: {
	  if (hoverHandler.hovered == true) {
		root.hovered = true;
	  } else {
		root.hovered = false;
		root.boxOpened = false;
		if (root.state == "closed") {
		  root.stack.replace(root.defaultItem);
		}
	  }
	}
  }

  TapHandler {
	id: tapHandler

	onTapped: {
	  if (root.openedItem) {
		root.boxOpened = true;
	  }
	}
  }

  Rectangle {
	id: container

	anchors.fill: parent
	clip: true
	color: root.boxColor
	radius: root.boxRadius

	Behavior on radius {
	  NumberAnimation {
		duration: 300
	  }
	}

	StackView {
	  id: containerContent

	  anchors.fill: parent

	  replaceEnter: Transition {
		PropertyAnimation {
		  duration: 100
		  from: 0
		  property: "opacity"
		  to: 1
		}

		PropertyAnimation {
		  duration: 100
		  from: -5
		  property: "anchors.topMargin"
		  to: 0
		}
	  }
	  replaceExit: Transition {
		PropertyAnimation {
		  duration: 100
		  from: 1
		  property: "opacity"
		  to: 0
		}
	  }

	  Component.onCompleted: containerContent.push(root.defaultItem)
	  onCurrentItemChanged: {
		if (currentItem) {
		  // Dynamically center the incoming child to the StackView
		  currentItem.anchors.horizontalCenter = containerContent.horizontalCenter;
		  currentItem.anchors.verticalCenter = containerContent.verticalCenter;
		}
	  }
	}
  }
}
