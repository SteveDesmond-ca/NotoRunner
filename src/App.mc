import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) {
    }

    function onStop(state as Dictionary?) {
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [
			initialView()
		];
    }

	function initialView() as ViewBase {
		switch (WatchUi.loadResource(Rez.Strings.AppName)) {
			case "NotoRunner":
				return new NotoFace();
			case "RoboRunner":
				return new RoboFace();
		}
		throw new Exception("Invalid mode/AppName");
	}

    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

}

function getApp() as App {
    return Application.getApp();
}