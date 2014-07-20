import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

CoverBackground {
    property var weather: savedWeathersModel.currentWeather

    Column {
        width: parent.width
        visible: currentWeatherAvailable
        y: Theme.paddingLarge
        WeatherImage {
            width: Screen.width/3
            height: Screen.width/3
            sourceSize.width: Screen.width/3
            sourceSize.height: Screen.width/3
            weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TemperatureLabel {
            text: weather ? weather.temperature : ""
            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: horizontalOffset
            }
        }
    }
    CoverPlaceholder {
        //% "Add your location"
        text: qsTrId("weather-la-add_your_location")
        icon.source: "image://theme/icon-launcher-weather"
        visible: !currentWeatherAvailable
    }
}
