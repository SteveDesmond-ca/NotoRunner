class NotoFace extends ViewBase {
	function initialize() {
		_font = {
			"S" => WatchUi.loadResource(Rez.Fonts.NotoSansSmall),
			"M" => WatchUi.loadResource(Rez.Fonts.NotoSansMedium),
			"L" => WatchUi.loadResource(Rez.Fonts.NotoSansLarge)
		};
		_middleOffset = -8;
		
		ViewBase.initialize();
	}

	function onLayout(dc) {
		ViewBase.onLayout(dc);
	}

	function onUpdate(dc) {
		ViewBase.onUpdate(dc);
	}
}