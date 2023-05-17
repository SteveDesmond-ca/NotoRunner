import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class View extends WatchUi.WatchFace {
	
	private var _width as Number = 0;
	private var _height as Number = 0;
	private var _center as Number = 0;
	private var _top as Number = 0;
	private var _middle as Number = 0;
	private var _bottom as Number = 0;

	private var _font as Dictionary<Number, FontResource> = {};
	
	function initialize() {
		_font = {
			160 => WatchUi.loadResource(Rez.Fonts.NotoSans_Light_160),
			48 => WatchUi.loadResource(Rez.Fonts.NotoSans_Light_48),
			32 => WatchUi.loadResource(Rez.Fonts.NotoSans_Light_32)
		};
		
		WatchFace.initialize();
	}

	function onLayout(dc as Dc) {
		Clear(dc, null);
		dc.setAntiAlias(true);
		
		_width = dc.getWidth();
		_height = dc.getHeight();
		_center = _width / 2;
		_top = _height * 1/6;
		_middle = _height / 2;
		_bottom = _height * 5/6;
	}

	private var _lastMinute as Number? = null;
	private var _lastTime as Gregorian.Info? = null;
	private var _lastStats as Stats? = null;

	function onUpdate(dc as Dc) {
		var now = Time.now();
		var clock = Gregorian.info(now, Time.FORMAT_SHORT);
		var stats = System.getSystemStats();

		var updateDate = _lastTime == null
			|| clock.day != _lastTime.day;
		
		var updateTime = _lastTime == null
			|| clock.hour != _lastTime.hour
			|| clock.min != _lastTime.min;
		
		var updateBattery = _lastStats == null
			|| stats.battery != _lastStats.battery
			|| stats.battery < _lowBattery
			|| stats.charging != _lastStats.charging;
			
		if (!updateDate && !updateTime && !updateBattery) {
			return;
		}

		if (updateDate) {
			DrawDate(dc, clock);
		}

		if (updateTime) {
			DrawTime(dc, clock);
		}

		if (updateBattery) {
			DrawBattery(dc, clock, stats);
		}
		
		_lastTime = clock;
		_lastStats = stats;
	}

	function Clear(dc as Dc, area as Array<Number>?) {
		if (area == null) {
			dc.clearClip();
		} else {
			dc.setClip(area[0], area[1], area[2], area[3]);
		}

		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
		dc.clear();
	}

	function DrawDate(dc as Dc, clock as Gregorian.Info) {
		Clear(dc, [_width*1/4, 0, _width/2, _height/4]);

		var dateString = Lang.format("$1$ / $2$", [clock.month, clock.day]);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(_center, _top-24, _font[32], DayOfWeek(clock.day_of_week), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(_center, _top+4, _font[48], dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function DrawTime(dc as Dc, clock as Gregorian.Info) {
		Clear(dc, [0, _height*1/4, _width, _height/2]);

		var hour = clock.hour % 12 == 0 ? 12 : clock.hour % 12;
		var timeString = Lang.format("$1$:$2$", [hour, clock.min.format("%02d")]);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(_center, _middle-8, _font[160], timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
		Clear(dc, [_width*1/4, _height*3/4, _width/2, _height/4]);

		var outline = BatteryOutlineColor(stats, clock.sec);
		dc.setColor(outline, Graphics.COLOR_TRANSPARENT);
		dc.drawRectangle(_center-BatteryIconWidth-4, _bottom-2, BatteryIconWidth, BatteryIconWidth/2);
		dc.drawRectangle(_center-2, _bottom+2, 1, 4);

		var batteryString = Lang.format("$1$%", [stats.battery.format("%1d")]);
		dc.drawText(_center+2, _bottom, _font[32], batteryString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

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