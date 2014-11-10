import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: page

    property bool error: locationsModel.status === XmlListModel.Error
    property bool loading: locationsModel.status === XmlListModel.Loading || loadingTimer.running

    Timer { id: loadingTimer; interval: 600 }
    LocationsModel {
        id: locationsModel
        onStatusChanged: if (status === XmlListModel.Loading) loadingTimer.restart()
    }
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
                focus: page.status == PageStatus.Active && locationListView.atYBeginning
                onFocusChanged: if (focus) forceActiveFocus()
                width: parent.width
                Binding {
                    target: locationsModel
                    property: "filter"
                    value: searchField.text.toLowerCase().trim()
                }
            }
        }
        BusyIndicator {
            running: loading && locationsModel.filter.length > 0 && locationsModel.count === 0
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
                } else if (locationsModel.filter.length > 0 && !loading && locationListView.count == 0) {
                    //% "Sorry, we couldn't find anything"
                    return qsTrId("weather-la-could_not_find_anything")
                } else if (locationsModel.filter.length === 0) {
                    //: Placeholder displayed when user hasn't yet typed a search string
                    //% "Search and select new location"
                    return qsTrId("weather-la-search_and_select_location")
                }
            }
            enabled: error || (locationListView.count == 0 && !loading) || locationsModel.filter.length < 1

            // TODO: add offset property to ViewPlaceholder
            y: locationListView.originY + Theme.itemSizeExtraSmall
               + (locationListView.headerItem ? locationListView.headerItem.height : 0)
            Button {
                //% "Try again"
                text: error ? qsTrId("weather-la-try_again")
                              //% "Save current"
                            : qsTrId("weather-bt-save_current")
                visible: error
                onClicked: locationsModel.reload()
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
                var location = {
                    "locationId": model.locationId,
                    "city": model.city,
                    "state": model.state,
                    "country": model.country
                }
                if (!savedWeathersModel.currentWeather
                        || savedWeathersModel.currentWeather.status === Weather.Error) {
                    savedWeathersModel.setCurrentWeather(location)
                } else {
                    savedWeathersModel.addLocation(location)
                }

                pageStack.pop()
            }
            ListView.onAdd: AddAnimation { target: searchResultItem; from: 0; to: 1 }
            ListView.onRemove: FadeAnimation { target: searchResultItem; from: 1; to: 0 }
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
                    text: Theme.highlightText((model.state && model.state.length > 0 ? model.state + ", " : "")
                                              + model.country, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
