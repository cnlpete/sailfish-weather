import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import QtQuick.XmlListModel 2.0

Page {
    property bool error: locationsModel.status === XmlListModel.Error
    property bool loading: locationsModel.status === XmlListModel.Loading
    LocationsModel { id: locationsModel }
    SilicaListView {
        id: locationListView
        currentIndex: -1
        anchors.fill: parent
        model: locationsModel
        header: Column {
            width: parent.width
            PageHeader {
                //% "New location"
                title: qsTrId("weather-la-new_location")
            }
            SearchField {
                id: searchField
                //% "Search locations"
                placeholderText: qsTrId("weather-la-search_locations")
                focus: locationListView.atYBeginning
                width: parent.width
                Binding {
                    target: locationsModel
                    property: "filter"
                    value: searchField.text.toLowerCase().trim()
                }
                Component.onCompleted: searchField.forceActiveFocus()
            }
        }
        BusyIndicator {
            running: locationsModel.status === XmlListModel.Loading && locationsModel.filter.length > 2
            anchors.centerIn: placeHolder
            parent: placeHolder.parent
            size: BusyIndicatorSize.Large
        }

        ViewPlaceholder {
            id: placeHolder
            text: {
                if (error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-loading_failed")
                } else if (locationsModel.filter.length >= 3 && !loading) {
                     if (!loading) {
                        //% "Sorry, we couldn't find anything"
                        return qsTrId("weather-la-could_not_find_anything")
                    }
                } else if (currentLocationReady && savedWeathersModel.currentWeather) {
                    //: Placeholder displayed when user hasn't yet typed a search string
                    //% "Search and select new location or save the current one"
                    return qsTrId("weather-la-search_or_save_location")
                } else {
                    //: Placeholder displayed when user hasn't yet typed a search string
                    //% "Search and select new location"
                    return qsTrId("weather-la-search_and_select_location")
                }
            }
            enabled: error || (locationListView.count == 0 && !loading) || locationsModel.filter.length < 3

            // TODO: add offset property to ViewPlaceholder
            y: locationListView.originY + Theme.paddingLarge
               + (locationListView.headerItem ? locationListView.headerItem.height : 0)
            Button {
                //% "Try again"
                text: error ? qsTrId("weather-la-try_again")
                              //% "Save current"
                            : qsTrId("weather-bt-save_current")
                visible: error || (currentLocationReady && savedWeathersModel.currentWeather)
                onClicked: {
                    if (error) {
                        locationsModel.reload()
                    } else {
                        var weather = savedWeathersModel.currentWeather
                        savedWeathersModel.addLocation({
                                                           "locationId": weather.locationId,
                                                           "city": weather.city,
                                                           "state": weather.state,
                                                           "country": weather.country
                                                       })
                        pageStack.pop()
                    }
                }
                anchors {
                    top: parent.bottom
                    topMargin: Theme.paddingMedium
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
        delegate: BackgroundItem {
            id: searchResultItem
            height: Theme.itemSizeMedium
            onClicked: {
                savedWeathersModel.addLocation({
                                                   "locationId": model.locationId,
                                                   "city": model.city,
                                                   "state": model.state,
                                                   "country": model.country
                                               })

                if (!savedWeathersModel.currentWeather) {
                    savedWeathersModel.setCurrentWeather({
                                                              "locationId": model.locationId,
                                                              "city": model.city,
                                                              "state": model.state,
                                                              "country": model.country
                                                          })
                }

                pageStack.pop()
            }
            ListView.onAdd: AddAnimation { target: searchResultItem }
            ListView.onRemove: RemoveAnimation { target: searchResultItem }
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.itemSizeSmall + Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    textFormat: Text.StyledText
                    text: Theme.highlightText(model.city, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    width: parent.width
                    textFormat: Text.StyledText
                    text: Theme.highlightText((model.state && model.state.length > 0 ? model.state + ", " : "") + model.country, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
