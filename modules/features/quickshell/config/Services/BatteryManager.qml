pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../Color.js" as Colors

Singleton {
  id: root

  property double batteryPercentage: root.mainBattery.percentage || 0
  property bool batteryPresent: root.mainBattery.ready || false
  property UPowerDevice mainBattery: UPower.displayDevice || undefined
  property bool hasLaptopBattery: root.mainBattery && root.mainBattery.isLaptopBattery



  function getBatteryColor() {
	let criticalLevel = 20;
	let batteryPercentage = getBatteryPercentage(mainBattery);

	if (mainBattery.state == UPowerDeviceState.FullyCharged) {
	  return Colors.sky;
	} else if (mainBattery.state == UPowerDeviceState.Charging) {
	  return Colors.mauve;
	} else if (mainBattery.state == UPowerDeviceState.PendingCharge || mainBattery.state
			   == UPowerDeviceState.PendingDischarge) {
	  return Colors.peach;
	} else if (batteryPercentage <= criticalLevel) {
	  return Colors.red;
	} else {
	  return Colors.green;
	}
  }

  function getBatteryIcon(battery) {
	if (battery.state == UPowerDeviceState.Charging) {
	  return "󰂄";
	} else if (battery.state == UPowerDeviceState.PendingCharge || battery.state
			   == UPowerDeviceState.PendingDischarge) {
	  return "󰚥";
	} else if (battery.state == UPowerDeviceState.Discharging || battery.state
			   == UPowerDeviceState.FullyCharged) {
	  let iconArr = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
	  let batteryCharge = battery.percentage;
	  let chargeIndex = Math.ceil(batteryCharge * iconArr.length) - 1;
	  return iconArr[chargeIndex];
	} else {
	  return "󰂎";
	}
  }

  function getBatteryName(battery) {
	let pathsplit = battery.nativePath.split("/");
	let batteryName = pathsplit[pathsplit.length - 1];
	return batteryName;
  }

  function getBatteryPercentage(battery) {
	return battery.percentage;
  }

  function getBatteryText() {
	let icon = getBatteryIcon(mainBattery);
	let percentage = getBatteryPercentage(mainBattery);
	return icon + " " + percentage + "%";
  }

  function getChargingRateFormat() {
	let rate = mainBattery.changeRate.toFixed(1);

	if (rate == 0) {
	  return "Battery Idle";
	} else if (rate <= 0 || mainBattery.state == UPowerDeviceState.Charging) {
	  return "Charging at " + rate + "W";
	} else {
	  return "Discharging at " + rate + "W";
	}
  }

  function getMainBatteryInfo() {
	let battery = UPower.devices.values[0];
	let batteryName = getBatteryName(battery);
	let time = getTimeFormat();
	return {
	  "name": batteryName,
	  "charge": battery.percentage,
	  "energy": battery.energy.toFixed(1),
	  "capacity": battery.energyCapacity.toFixed(1),
	  "health": battery.healthPercentage,
	  "time": time
	};
  }

  function getTimeFormat() {
	let state = mainBattery.state;
	let finalString = "";
	if (state == UPowerDeviceState.FullyCharged) {
	  finalString += "Battery Full";
	} else if (state == UPowerDeviceState.Charging) {
	  let time = mainBattery.timeToFull;
	  if (time == 0) {
		return "Getting Time...";
	  } else {
		let timeArr = secondsToTime(time);
		// If more than 1 hour
		if (timeArr.hours >= 1 || timeArr.hourNeedsIncrement == 1) {
		  finalString += timeArr.hours + " Hours ";
		  // If minutes not 0
		  if (timeArr.minutesRounded > 1) {
			finalString += timeArr.minutesRounded + " Minutes";
		  }
		} else {
		  finalString += timeArr.minutes + " Minutes ";
		  finalString += timeArr.seconds + " Seconds";
		}
	  }
	  finalString += " Until Full";
	} else if (state == UPowerDeviceState.Discharging) {
	  let time = mainBattery.timeToEmpty;
	  if (time == 0) {
		return "Getting Time...";
	  } else {
		let timeArr = secondsToTime(time);
		// If more than 1 hour
		if (timeArr.hours >= 1 || timeArr.hourNeedsIncrement == 1) {
		  finalString += timeArr.hours + " Hours ";
		  // If minutes not 0
		  if (timeArr.minutesRounded > 1) {
			finalString += timeArr.minutesRounded + " Minutes";
		  }
		} else {
		  finalString += timeArr.minutes + " Minutes ";
		  finalString += timeArr.seconds + " Seconds";
		}
	  }
	  finalString += " Remaining";
	} else {
	  finalString += "Getting Time...";
	}
	return finalString;
  }

  function secondsToTime(totalSeconds) {
	totalSeconds = Math.max(0, Number(totalSeconds));

	const hours = Math.floor(totalSeconds / 3600);
	const minutes = Math.floor((totalSeconds % 3600) / 60);
	const seconds = Math.floor(totalSeconds % 60);

	const roundedMinutes = minutes + (seconds >= 30 ? 1 : 0);
	const hourNeedsIncrement = roundedMinutes === 60;

	return {
	  hours,
	  minutes,
	  seconds,
	  minutesRounded: hourNeedsIncrement ? 0 : roundedMinutes,
	  hourNeedsIncrement
	};
  }
}
