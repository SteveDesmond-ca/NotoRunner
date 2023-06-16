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
        return [ new RoboFace() ];
    }

    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

}

function getApp() as App {
    return Application.getApp();
}