// Time.qml

// with this line our type becomes a Singleton
pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io

// your singletons should always have Singleton as the type
Singleton {
  id: root

  property string date
  property string time

  Process {
	id: timeProc

	command: ["date", "+%T"]
	running: true

	stdout: StdioCollector {
	  onStreamFinished: root.time = this.text
	}
  }

  Process {
	id: dateProc

	command: ["date", "+%A %B %d %Y"]
	running: true

	stdout: StdioCollector {
	  onStreamFinished: root.date = this.text
	}
  }

  Timer {
	interval: 1000
	repeat: true
	running: true

	onTriggered: {
	  timeProc.running = true;
	  dateProc.running = true;
	}
  }
}
