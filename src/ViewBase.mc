import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class ViewBase extends WatchUi.WatchFace {
	
	private var _width as Number = 0;
	private var _height as Number = 0;
	private var _center as Number = 0;
	private var _top as Number = 0;
	private var _middle as Number = 0;
	private var _bottom as Number = 0;

	private var _font as Dictionary<String, FontResource> = {};
	
	function initialize() {
		_font = {
			"L" => WatchUi.loadResource(Rez.Fonts.RobotoLarge),
			"M" => WatchUi.loadResource(Rez.Fonts.RobotoMedium),
			"S" => WatchUi.loadResource(Rez.Fonts.RobotoSmall)
		};
		
		WatchFace.initialize();
	}

	function onLayout(dc as Dc) {
		dc.setAntiAlias(true);
		
		_width = dc.getWidth();
		_height = dc.getHeight();
		_center = _width / 2;
		_top = _height * 1/6;
		_middle = _height / 2;
		_bottom = _height * 5/6;
	}

	function onUpdate(dc as Dc) {
		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
		dc.clear();

		var now = Time.now();
		var clock = Gregorian.info(now, Time.FORMAT_SHORT);
		var stats = System.getSystemStats();

		DrawDate(dc, clock);
		DrawTime(dc, clock);
		DrawBattery(dc, clock, stats);
	}

	function DrawDate(dc as Dc, clock as Gregorian.Info) {
		var dateString = Lang.format("$1$ / $2$", [clock.month, clock.day]);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(_center, _top-24, _font["S"], DayOfWeek(clock.day_of_week), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(_center, _top+4, _font["M"], dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function DrawTime(dc as Dc, clock as Gregorian.Info) {
		var hour = clock.hour % 12 == 0 ? 12 : clock.hour % 12;
		var timeString = Lang.format("$1$:$2$", [hour, clock.min.format("%02d")]);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(_center, _middle, _font["L"], timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function DayOfWeek(num as Number) as String {
		switch(num) {
			case 1: return "Sun";
			case 2: return "Mon";
			case 3: return "Tue";
			case 4: return "Wed";
			case 5: return "Thu";
			case 6: return "Fri";
			case 7: return "Sat";
		}
		return "";
	}

	private var BatteryIconWidth = 24;
	function DrawBattery(dc as Dc, clock as Gregorian.Info, stats as Stats) {
		var outline = BatteryOutlineColor(stats, clock.sec);
		dc.setColor(outline, Graphics.COLOR_TRANSPARENT);
		dc.drawRectangle(_center-BatteryIconWidth-4, _bottom-2, BatteryIconWidth, BatteryIconWidth/2);
		dc.drawRectangle(_center-2, _bottom+2, 1, 4);

		var batteryString = Lang.format("$1$%", [stats.battery.format("%1d")]);
		dc.drawText(_center+2, _bottom+2, _font["S"], batteryString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		var color = BatteryFillColor(stats.battery);
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(_center-BatteryIconWidth-2, _bottom, stats.battery/5.0, BatteryIconWidth/2 - 4);

		if (stats.charging) {
			DrawChargingIcon(dc);
		}
	}

	private var _lowBattery as Number = 10;
	function BatteryOutlineColor(stats as Stats, sec as Number) as Number {
		return stats.charging ? Graphics.COLOR_WHITE
			: sec % 2 == 0 ? Graphics.COLOR_WHITE
			: stats.battery >= _lowBattery ? Graphics.COLOR_WHITE
			: stats.battery >= _lowBattery/2 ? Graphics.COLOR_LT_GRAY
			: Graphics.COLOR_DK_GRAY;
	}

	function BatteryFillColor(level as Float) as Number {
		return level >= 75 ? Graphics.COLOR_DK_GREEN
			: level >= 50 ? Graphics.COLOR_GREEN
			: level >= 30 ? Graphics.COLOR_YELLOW
			: level >= 20 ? Graphics.COLOR_ORANGE
			: level >= 10 ? Graphics.COLOR_RED
			: Graphics.COLOR_DK_RED;
	}

	function DrawChargingIcon(dc as Dc) {
		var centerX = _center-BatteryIconWidth/2-4;
		var centerY = _bottom+4;
		
		var outline = [
			[ centerX+3, centerY-BatteryIconWidth/3-2 ],
			[ centerX-4, centerY+2 ],
			[ centerX-2, centerY+2 ],
			[ centerX-3, centerY+BatteryIconWidth/3+2 ],
			[ centerX+4, centerY-2 ],
			[ centerX+2, centerY-2 ],
		];
		
		var fill = [
			[ centerX+2, centerY-BatteryIconWidth/3+1 ],
			[ centerX-3, centerY+1 ],
			[ centerX-1, centerY+1 ],
			[ centerX-2, centerY+BatteryIconWidth/3-1 ],
			[ centerX+3, centerY-1 ],
			[ centerX+1, centerY-1 ],
		];

		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(outline);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(fill);
	}
}