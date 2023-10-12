/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Weather application package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
**    list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice,
**    this list of conditions and the following disclaimer in the documentation
**    and/or other materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its
**    contributors may be used to endorse or promote products derived from
**    this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: page

    property bool error: locationsModel.status === Weather.Error
    property bool unauthorized: locationsModel.status === Weather.Unauthorized
    property bool loading: locationsModel.status === Weather.Loading || loadingTimer.running
    objectName: "LocationSearchPage"

    Timer { id: loadingTimer; interval: 600 }

    LocationsModel {
        id: locationsModel
        onStatusChanged: if (status === Weather.Loading) loadingTimer.restart()
        onFilterChanged: delayedFilter.restart()
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
                onFocusChanged: if (focus) forceActiveFocus()
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                Binding {
                    target: locationsModel
                    property: "filter"
                    value: searchField.text.toLowerCase().trim()
                }
                Binding {
                    target: searchField
                    property: "focus"
                    value: true
                    when: page.status == PageStatus.Active && locationListView.atYBeginning
                }
            }
        }
        BusyIndicator {
            running: !error && loading && locationsModel.filter.length > 0 && locationsModel.count === 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: placeHolder.y + Math.round(height/2)
            parent: placeHolder.parent
            size: BusyIndicatorSize.Large
        }
        ViewPlaceholder {
            id: placeHolder
            text: {
                if (error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-loading_failed")
                } else if (unauthorized) {
                    //% "Invalid authentication credentials"
                    return qsTrId("weather-la-unauthorized")
                } else if (locationsModel.filter.length === 0) {
                    //: Placeholder displayed when user hasn't yet typed a search string
                    //% "Search and select new location"
                    return qsTrId("weather-la-search_and_select_location")
                } else if (!loading && !delayedFilter.running && locationListView.count == 0) {
                    if (locationsModel.filter.length < 3) {
                        //% "Could not find the location. Type at least three characters to perform a partial word search."
                        return qsTrId("weather-la-search_three_characters_required")
                    } else {
                        //% "Sorry, we couldn't find anything"
                        return qsTrId("weather-la-could_not_find_anything")
                    }
                }
                return ""
            }

            // Suppress error label flicker when filter has changed but model loading state hasn't yet had time to update
            Timer {
                id: delayedFilter
                interval: 1
            }

            enabled: error || (locationListView.count == 0 && !loading) || locationsModel.filter.length < 1

            y: locationListView.originY + Math.round(parent.height/14)
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
                    "locationId": model.id,
                    "city": model.name,
                    "state": "",
                    "country": model.country,
                    "adminArea": model.adminArea,
                    "adminArea2": model.adminArea2,
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
                    rightMargin: Theme.horizontalPageMargin - Theme.paddingMedium
                    leftMargin: Theme.itemSizeSmall + Theme.horizontalPageMargin - Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    textFormat: Text.StyledText
                    text: Theme.highlightText(model.name, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    // Order of location country string, "Country", "Admin Area", "Admin Area2"
                    // e.g. "United States, Nevada, Clark"
                    readonly property string countryString: model.country
                                                            + (model.adminArea ? (", " + model.adminArea) : "")
                                                            + (model.adminArea2 ? (", " + model.adminArea2) : "")
                    width: parent.width
                    textFormat: Text.StyledText
                    text: Theme.highlightText(countryString, locationsModel.filter, Theme.highlightColor)
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
