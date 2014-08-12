import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    WeatherImage {
        id: weatherImage

        y: -width/4
        opacity: 0.4
        height: width
        width: parent.width
        sourceSize.width: width
        sourceSize.height: width
        weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Label {
        font.pixelSize: Theme.fontSizeHuge
        text: weather ? TemperatureConverter.format(weather.temperature) + "\u00B0" : ""
        anchors.centerIn: weatherImage
    }
    Label {
        text: weather.description
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
        anchors {
            left: parent.left
            right: parent.right
            top: weatherImage.bottom
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
    }
}
