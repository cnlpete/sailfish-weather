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

CoverBackground {
    id: cover

    property QtObject weather: savedWeathersModel.currentWeather

    property bool current: true
    property bool ready: loaded && !error  && !unauthorized
    property bool loaded: weather
    property bool error: loaded && savedWeathersModel.currentWeather.status == Weather.Error
    property bool unauthorized: loaded && savedWeathersModel.currentWeather.status == Weather.Unauthorized

    function reload() {
        if (current) {
            if (savedWeathersModel.currentWeather && currentWeatherModel.updateAllowed()) {
                currentWeatherModel.reload()
            }
        } else if (savedWeathersModel.count > 1) {
            weatherApplication.reloadAllIfAllowed()
        }
    }

    onStatusChanged: if (status == Cover.Active) reload()
    onCurrentChanged: reload()

    CoverPlaceholder {
        visible: !ready
        icon.source: "image://theme/graphic-foreca-large"
        text: {
            if (!loaded) {
                //% "Select location to check weather"
                return qsTrId("weather-la-select_location_to_check_weather")
            } else if (error) {
                //% "Unable to connect, try again"
                return qsTrId("weather-la-unable_to_connect_try_again")
            } else if (unauthorized) {
                //% "Invalid authentication credentials"
                return qsTrId("weather-la-unauthorized")
            }

            return ""
        }
    }
    Loader {
        active: ready
        opacity: ready && current ? 1.0 : 0.0
        source: "CurrentWeatherCover.qml"
        Behavior on opacity { FadeAnimation {} }
        anchors.fill: parent
    }
    Loader {
        active: ready && savedWeathersModel.count > 0
        opacity: ready && !current ? 1.0 : 0.0
        source: "WeatherListCover.qml"
        Behavior on opacity { FadeAnimation {} }
        anchors.fill: parent
    }

    CoverActionList {
        enabled: !loaded
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                var alreadyOpen = pageStack.currentPage && pageStack.currentPage.objectName === "LocationSearchPage"
                if (!alreadyOpen) {
                    pageStack.push(Qt.resolvedUrl("../pages/LocationSearchPage.qml"), undefined, PageStackAction.Immediate)
                }
                weatherApplication.activate()
            }
        }
    }
    CoverActionList {
        enabled: error
        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                weatherApplication.reloadAll()
            }
        }
    }
    CoverActionList {
        enabled: ready && savedWeathersModel.count > 0
        CoverAction {
            iconSource: current ? "image://theme/icon-cover-previous"
                                : "image://theme/icon-cover-next"
            onTriggered: {
                current = !current
            }
        }
    }
    Connections {
        target: savedWeathersModel
        onCountChanged: if (savedWeathersModel.count === 0) current = true
    }
}
