import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
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
        ViewPlaceholder {
            id: placeHolder
            //: Placeholder displayed when user hasn't yet typed a search string
            //% "Search and select new location or save the current one"
            text: qsTrId("weather-la-search-or-select-location")
            enabled: locationListView.count == 0

            // TODO: add offset property to ViewPlaceholder
            y: locationListView.originY + Theme.paddingLarge
               + (locationListView.headerItem ? locationListView.headerItem.height : 0)
            Button {
                //% "Save current"
                text: qsTrId("weather-bt-save_current")
                enabled: false // Enable once GPS exists
                anchors {
                    top: parent.bottom
                    topMargin: -Theme.paddingMedium
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
        delegate: BackgroundItem {
            id: searchResultItem
            height: Theme.itemSizeMedium
            onClicked: {
                savedWeathersModel.save({
                                            "locationId": model.locationId,
                                            "city": model.city,
                                            "state": model.state,
                                            "country": model.country
                                        })
                if (savedWeathersModel.count == 1) {
                    savedWeathersModel.currentLocationId = model.locationId
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
                    text: Theme.highlightText(model.state + ", " + model.country, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                }
            }
        }
    }
}
