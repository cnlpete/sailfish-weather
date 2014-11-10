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
                enabled: savedWeathersModel.currentWeather || savedWeathersModel.count > 0
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
            WeatherHeader {
                opacity: currentWeatherAvailable ? 1.0 : 0.0
                weather: savedWeathersModel.currentWeather
                onClicked: {
                    pageStack.push("WeatherPage.qml", {"weather": weather, "weatherModel": currentWeatherModel, "current": true })
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }
        PlaceholderItem {
            flickable: weatherListView
            parent: weatherListView.contentItem
            y: weatherListView.originY + Theme.itemSizeSmall + (currentWeatherAvailable ? weatherListView.headerItem.height : 2*Theme.itemSizeLarge)
            enabled: !currentWeatherAvailable || savedWeathersModel.count === 0
            error: savedWeathersModel.currentWeather && savedWeathersModel.currentWeather.status === Weather.Error
            empty: !savedWeathersModel.currentWeather || savedWeathersModel.count == 0
            text: {
                if (empty) {
                    if (currentWeatherAvailable) {
                        //% "Pull down to add another weather location"
                        return qsTrId("weather-la-pull_down_to_add_another_location")
                    } else {
                        //% "Pull down to select your location"
                        return qsTrId("weather-la-pull_down_to_select_your_location")
                    }
                } else if (error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-loading_failed")
                } else {
                    //% "Loading"
                    return qsTrId("weather-la-loading")
                }
            }
            onReload: weatherApplication.reload(savedWeathersModel.currentWeather.locationId)
        }
        model: savedWeathersModel
        delegate: ListItem {
            id: savedWeatherItem

            function remove() {
                remorseAction("Deleting", function() { savedWeathersModel.remove(locationId) })
            }
            ListView.onAdd: AddAnimation { target: savedWeatherItem }
            ListView.onRemove: animateRemoval()
            menu: contextMenuComponent
            contentHeight: Theme.itemSizeMedium
            onClicked: {
                if (!model.populated && model.status == Weather.Error) {
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
                    text: !model.populated && model.status === Weather.Error ?
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
                text: TemperatureConverter.format(model.temperature)
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeHuge
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                width: visible ? implicitWidth : 0
                visible: model.populated
            }
            Component {
                id: contextMenuComponent
                ContextMenu {
                    property bool moveItemsWhenClosed
                    property bool setCurrentWhenClosed
                    property bool menuOpen: height > 0

                    onMenuOpenChanged: {
                        if (!menuOpen) {
                            if (moveItemsWhenClosed) {
                            savedWeathersModel.moveToTop(model.index)
                            moveItemsWhenClosed = false
                            }
                            if (setCurrentWhenClosed) {
                                var current = savedWeathersModel.currentWeather
                                if (!current || current.locationId !== model.locationId) {
                                    var weather = {
                                        "locationId": model.locationId,
                                        "city": model.city,
                                        "state": model.state,
                                        "country": model.country,
                                        "temperature": model.temperature,
                                        "temperatureFeel": model.temperatureFeel,
                                        "weatherType": model.weatherType,
                                        "description": model.description,
                                        "timestamp": model.timestamp
                                    }
                                    savedWeathersModel.setCurrentWeather(weather)

                                }
                                setCurrentWhenClosed = false
                            }
                        }
                    }

                    MenuItem {
                        //% "Remove"
                        text: qsTrId("weather-me-remove")
                        onClicked: remove()
                    }
                    MenuItem {
                        //% "Set as current"
                        text: qsTrId("weather-me-set_as_current")
                        visible: model.status !== Weather.Error
                        onClicked: setCurrentWhenClosed = true
                    }
                    MenuItem {
                        //% "Move to top"
                        text: qsTrId("weather-me-move_to_top")
                        visible: model.index !== 0
                        onClicked: moveItemsWhenClosed = true
                    }
                }
            }
        }
        footer: Item {
            width: parent.width
            height: disclaimer.height
            ProviderDisclaimer {
                id: disclaimer
                y: Math.max(0, Screen.height - weatherListView.contentHeight)
                weather: savedWeathersModel.currentWeather
            }
        }
        VerticalScrollDecorator {}
    }
}
