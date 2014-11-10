import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

CoverBackground {
    id: cover

    property var weather: savedWeathersModel.currentWeather

    property bool current: true
    property bool ready: loaded && !error
    property bool loaded: savedWeathersModel.currentWeather
    property bool error: loaded && savedWeathersModel.currentWeather.status == Weather.Error

    CoverPlaceholder {
        visible: !ready
        icon.source: "image://theme/graphic-foreca"
        text: !loaded ? //% "Select location to check weather"
                        qsTrId("weather-la-select_location_to_check_weather")
                      : error ? //% "Unable to connect, try again"
                                qsTrId("weather-la-unable_to_connect_try_again")
                              : ""
    }
    Loader {
        active: ready
        opacity: ready && current ? 1.0 : 0.0
        source: "CurrentWeatherCover.qml"
        Behavior on opacity { FadeAnimation {} }
        anchors.fill: parent
    }
    Loader {
        active: ready && savedWeathersModel.count > 1
        opacity: ready && !current ? 1.0 : 0.0
        source: "WeatherListCover.qml"
        Behavior on opacity { FadeAnimation {} }
        anchors.fill: parent
    }

    onStatusChanged: {
        if (status == Cover.Active) {
            if (current) {
                if (savedWeathersModel.currentWeather && currentWeatherModel.updateAllowed()) {
                    currentWeatherModel.reload()
                }
            } else if (savedWeathersModel.count > 1) {
                weatherApplication.reloadAllIfAllowed()
            }
        }
    }

    CoverActionList {
        enabled: !loaded
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                weatherApplication.activate()
                pageStack.push(Qt.resolvedUrl("../pages/LocationSearchPage.qml"), undefined, PageStackAction.Immediate)
            }
        }
    }
    CoverActionList {
        enabled: error
        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                weatherApplication.reloadAll()
            }
        }
    }
    CoverActionList {
        enabled: ready && savedWeathersModel.count > 1
        CoverAction {
            iconSource: current ? "image://theme/icon-cover-previous"
                                    : "image://theme/icon-cover-next"
            onTriggered: {
                current = !current
            }
        }
    }
    Connections {
        target: savedWeathersModel
        onCountChanged: if (savedWeathersModel.count <= 1) current = true
    }
}
