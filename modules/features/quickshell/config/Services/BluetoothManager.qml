pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
  id: root

  property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter || null
  property string defaultAdapterName: defaultAdapter ? defaultAdapter.adapterId : ""

  property bool anyConnected: root.defaultAdapter != null
    && root.defaultAdapter.devices.values.some(device => device.connected)

  function getConnected() {
	return root.anyConnected;
  }

  function getConnectedDevicesList() {
	let devicesList = getDevicesList();
	if (!devicesList) {
	  return [];
	}
	let connectedList = [];
	for (let device of devicesList) {
	  if (device.connected == true) {
		connectedList.push(device);
	  }
	}
	return connectedList;
  }

  function getDeviceText(device) {
	if (!device) {
	  return undefined;
	}
	let deviceName = device.deviceName;
	let deviceIcon = getIcon(device.icon);
	let deviceMac = device.address;
	let hasBattery = device.batteryAvailable;
	let deviceBattery = deviceIcon;
	let deviceBatteryRaw = 0;
	if (hasBattery) {
	  deviceBattery = device.battery * 100;
	  deviceBatteryRaw = device.battery;
	}

	return {
	  "icon": deviceIcon,
	  "name": deviceName,
	  "mac": deviceMac,
	  "hasBattery": hasBattery,
	  "battery": deviceBattery,
	  "batteryRaw": deviceBatteryRaw
	};
  }

  function getDevicesList() {
	if (!root.defaultAdapter) {
	  return [];
	}
	return root.defaultAdapter.devices.values;
  }

  function getIcon(name) {
	const icons = {
	  "audio-card": "󰓃",
	  "audio-input-microphone": "",
	  "audio-headphones": "󰋋",
	  "audio-headset": "󰋋",
	  "battery": "󰂀",
	  "camera-photo": "󰻛",
	  "computer": "",
	  "input-keyboard": "󰌌",
	  "input-mouse": "󰍽",
	  "input-gaming": "󰊴",
	  "phone": "󰏲"
	};

	return icons[name] || "󰾰";
  }
}
