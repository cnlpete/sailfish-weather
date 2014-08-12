import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {    
    SilicaListView {
        id: weatherListView

        PullDownMenu {
            MenuItem {
                //% "New location"
                text: qsTrId("weather-me-new_location")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
            }
            MenuItem {
                //% "Update"
                text: qsTrId("weather-me-update")
                onClicked: reloadTimer.restart()
                Timer {
                    id: reloadTimer
                    interval: 500
                    onTriggered: weatherApplication.reloadAll()
                }
            }
        }
        anchors.fill: parent
        header: Column {
            width: parent.width
            spacing: Theme.paddingLarge
            WeatherItem {
                opacity: currentWeatherAvailable ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {}}
                weather: savedWeathersModel.currentWeather
                onClicked: {
                    pageStack.push("WeatherPage.qml", {"weather": weather, "weatherModel": weatherModels[weather.locationId] })
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }
        PlaceholderItem {
            parent: weatherListView.contentItem
            y: weatherListView.originY + Theme.itemSizeSmall + Theme.itemSizeLarge*2
            status: savedWeathersModel.currentWeather ? savedWeathersModel.currentWeather.status : Weather.Null
            text: !savedWeathersModel.currentWeather ?
                      //% "Add your location to see the weather"
                      qsTrId("weather-la-add_your_location_to_see_weather")
                    :
                      savedWeathersModel.currentWeather.status == Weather.Error ?
                          //% "Loading failed"
                          qsTrId("weather-la-loading_failed")
                        :
                      //% "Loading"
                      qsTrId("weather-la-loading")
            onReload: {
                if (savedWeathersModel.currentWeather) {
                    weatherApplication.reload(savedWeathersModel.currentWeather.locationId)
                }
            }
        }
        model: savedWeathersModel
        delegate: ListItem {
            menu: contextMenuComponent
            contentHeight: Theme.itemSizeMedium
            function remove() {
                remorseAction("Deleting", function() { savedWeathersModel.remove(locationId) })
            }
            ListView.onRemove: animateRemoval()
            onClicked: {
                if (model.status == Weather.Error) {
                    weatherApplication.reload(model.locationId)
                } else {
                    pageStack.push("WeatherPage.qml", {"weather": savedWeathersModel.get(model.locationId),
                                       "weatherModel": weatherModels[model.locationId] })
                }
            }

            Image {
                id: icon
                x: Theme.paddingLarge
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                sourceSize.width: width
                sourceSize.height: height
                visible: model.status !== Weather.Loading
                source: model.weatherType.length > 0 ? "image://theme/graphic-weather-" + model.weatherType
                                                        + (highlighted ? "?" + Theme.highlightColor : "")
                                                      : ""
            }
            BusyIndicator {
                running: model.status === Weather.Loading
                anchors.centerIn: icon
            }
            Column {
                anchors {
                    left: icon.right
                    right: temperatureLabel.left
                    margins: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.city
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.status === Weather.Error ?
                              //% "Loading failed. Tap to reload"
                              qsTrId("weather-la-loading_failed_tap_to_reload")
                            :
                              model.description
                    truncationMode: model.status === Weather.Error ? TruncationMode.None : TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            Label {
                id: temperatureLabel
                text: TemperatureConverter.format(model.temperature) + "\u00B0"
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeHuge
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                width: visible ? implicitWidth : 0
                visible: model.status == Weather.Ready
            }
            Component {
                id: contextMenuComponent
                ContextMenu {
                    MenuItem {
                        //% "Remove"
                        text: qsTrId("weather-me-remove")
                        onClicked: remove()
                    }
                    MenuItem {
                        //% "Set as current"
                        text: qsTrId("weather-me-set_as_current")
                        visible: model.status == Weather.Ready
                        onClicked: savedWeathersModel.currentLocationId = model.locationId
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
