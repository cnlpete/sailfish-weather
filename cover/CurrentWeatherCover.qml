import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    WeatherImage {
        id: weatherImage

        y: -Theme.paddingLarge
        opacity: 0.4
        height: width
        width: parent.width
        sourceSize.width: width
        sourceSize.height: width
        weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Image {
        scale: 0.5
        opacity: 0.5
        anchors {
            bottom: temperatureLabel.top
            bottomMargin: -Theme.paddingMedium
            horizontalCenter: parent.horizontalCenter
        }
        source: "image://theme/graphic-foreca"
    }
    Label {
        id: temperatureLabel
        font.pixelSize: Theme.fontSizeHuge
        text: weather ? TemperatureConverter.format(weather.temperature) + "\u00B0" : ""
        anchors.centerIn: weatherImage
    }
    Label {
        text: weather ? weather.description : ""
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
        anchors {
            left: parent.left
            right: parent.right
            top: temperatureLabel.bottom
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            bottom: parent.bottom
            bottomMargin: Theme.itemSizeSmall
        }
    }
}
