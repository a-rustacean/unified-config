pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
  id: root

  property bool connectedWifi: root.defaultAdapter != null && root.defaultAdapter.connected
							   && root.defaultAdapter.type == DeviceType.Wifi
  property NetworkDevice defaultAdapter: Networking.devices.values[0] || null
  property string ipAddress: "0.0.0.0"

  function getConnectedNetworks(networksArr) {
	let connectedNetworks = [];

	for (let network of networksArr) {
	  if (network.state == ConnectionState.Connected) {
		connectedNetworks.push(network);
	  }
	}
	return connectedNetworks;
  }

  function getNetworkDetails(adapter) {
	if (!adapter) {
	  return {
		"adapterName": "",
		"adapterConnected": false,
		"adapterIsWifi": false,
		"networkName": "",
		"networkStrength": 0,
		"icon": "󰤭"
	  };
	}

	let networksArr = adapter.networks.values;
	let connectedNetworks = getConnectedNetworks(networksArr);
	let deviceWifi = isDeviceWifi(adapter);

	let primaryNetwork = connectedNetworks[0];
	if (!primaryNetwork) {
	  return {
		"adapterName": adapter.name,
		"adapterConnected": adapter.connected,
		"adapterIsWifi": deviceWifi,
		"networkName": "No Network",
		"networkStrength": 0,
		"icon": "󰤭"
	  };
	}

	let networkName = primaryNetwork.name;
	let networkStrength = primaryNetwork.signalStrength;

	let networkIcon = getWifiIcon(networkStrength);

	let outputDict = {
	  "adapterName": adapter.name,
	  "adapterConnected": adapter.connected,
	  "adapterIsWifi": deviceWifi,
	  "networkName": networkName,
	  "networkStrength": networkStrength,
	  "icon": networkIcon,
	  "saved": primaryNetwork.known,
	  "ipAddress": root.ipAddress
	};
	return outputDict;
  }

  function getWifiIcon(strength) {
	let iconArr = ["󰤟", "󰤢", "󰤥", "󰤨"];
	let strengthIndex = Math.ceil(strength * iconArr.length);
	return iconArr[strengthIndex - 1];
  }

  function getWifiText() {
	let info = getNetworkDetails(defaultAdapter);

	let adapter = info["adapterName"];
	let name = info["networkName"];

	let finalString = adapter + " - " + name;
	return finalString;
  }

  function isConnectedAndWifi() {
	return root.connectedWifi;
  }

  function isDeviceWifi(adapter) {
	if (adapter.type == DeviceType.Wifi) {
	  return true;
	} else if (adapter.type == DeviceType.Wired) {
	  return false;
	} else {
	  return false;
	}
  }

  function refreshIpAddress() {
	ipProcess.running = true;
  }

  onDefaultAdapterChanged: {
	refreshIpAddress();
  }

  Process {
	id: ipProcess

	command: ["sh", "-c", "ip -4 -o addr show dev " + root.defaultAdapter.name
	  + " scope global | awk '{sub(\"/.*\", \"\", $4); printf $4}'"]
	running: true

	stdout: StdioCollector {
	  onStreamFinished: root.ipAddress = this.text
	}
  }
}
