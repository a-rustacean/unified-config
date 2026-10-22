pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

import Quickshell.Wayland

Singleton {
  id: root

  property var focusState: WlrKeyboardFocus.None
  property bool logoutMenuOpen: false

  signal closeLogoutMenu
  signal logoutMenu

  onCloseLogoutMenu: {
	root.focusState = WlrKeyboardFocus.None;
	root.logoutMenuOpen = false;
  }

  IpcHandler {
	function openLogoutMenu(): void {
	  root.logoutMenu();
	  root.focusState = WlrKeyboardFocus.Exclusive;
	  root.logoutMenuOpen = true;
	}

	target: "root"
  }
}
