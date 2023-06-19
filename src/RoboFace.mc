class RoboFace extends ViewBase {
	function initialize() {
		_font = {
			"S" => WatchUi.loadResource(Rez.Fonts.RobotoSmall),
			"M" => WatchUi.loadResource(Rez.Fonts.RobotoMedium),
			"L" => WatchUi.loadResource(Rez.Fonts.RobotoLarge)
		};
		_bottomOffset = 2;
		
		ViewBase.initialize();
	}

	function onLayout(dc) {
		ViewBase.onLayout(dc);
	}

	function onUpdate(dc) {
		ViewBase.onUpdate(dc);
	}
}