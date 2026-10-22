pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root

  function activateNextFreeWorkspace() {
	let nextFree = getNextFreeWorkspace();
	activateWorkspaceById(nextFree);
  }

  function activateWorkspaceById(id) {
	Hyprland.dispatch(`hl.dsp.focus({workspace = ${id}})`);
  }

  function getAllNumberedWorkspaces() {
	let allWorkspaces = Hyprland.workspaces.values;
	let filteredWorkspaces = [];
	for (let workspace in allWorkspaces) {
	  let currentWorkspace = allWorkspaces[workspace];
	  if (!currentWorkspace.name.includes("special")) {
		if (currentWorkspace) {
		  filteredWorkspaces.push(currentWorkspace);
		}
	  }
	}
	return filteredWorkspaces;
  }

  function getNextFreeWorkspace() {
	let workspaceList = getAllNumberedWorkspaces();

	if (workspaceList[workspaceList.length - 1].id == workspaceList.length) {
	  return workspaceList.length + 1;
	} else {
	  let prevWorkspace = 0;
	  for (let workspace in workspaceList) {
		let currentWorkspace = workspaceList[workspace];
		if (currentWorkspace.id != (prevWorkspace + 1)) {
		  return currentWorkspace.id - 1;
		} else {
		  prevWorkspace = currentWorkspace.id;
		}
	  }
	}
  }

  function getNumberOfWorkspaces(monitor) {
	let workspaceList = getWorkspacesForMonitor(monitor);
	return workspaceList.length;
  }

  function getWorkspaceState(workspace) {
	if (workspace.focused == true) {
	  return "focused";
	} else if (workspace.active == true) {
	  return "active";
	} else {
	  return "inactive";
	}
  }

  function getWorkspaceStateIndex(workspace) {
	let state = getWorkspaceState(workspace);
	if (state == "focused") {
	  return 0;
	} else if (state == "active") {
	  return 1;
	} else if (state == "inactive") {
	  return 2;
	}
  }

  function getWorkspacesForMonitor(monitor) {
	let allWorkspaces = getAllNumberedWorkspaces();
	let monitorWorkspaces = [];

	for (let workspace in allWorkspaces) {
	  let currentWorkspace = allWorkspaces[workspace];
	  if (currentWorkspace.monitor == monitor) {
		if (currentWorkspace) {
		  monitorWorkspaces.push(currentWorkspace);
		}
	  }
	}
	return monitorWorkspaces;
  }
}
