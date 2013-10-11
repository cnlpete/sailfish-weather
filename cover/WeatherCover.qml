import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

CoverBackground {
    WeatherItem {
        cover: true
        weather: savedWeathersModel.currentWeather
        anchors.centerIn: parent
        visible: currentWeatherAvailable
    }
    CoverPlaceholder {
        //% "Add your location"
        text: qsTrId("weather-la-add_your_location")
        icon.source: "image://theme/icon-launcher-weather"
        visible: !currentWeatherAvailable
    }
}
