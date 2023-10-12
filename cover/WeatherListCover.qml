/****************************************************************************************
** Copyright (c) 2014 - 2023 Jolla Ltd.
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

Item {
    id: root

    property int visibleItemCount: 4
    property int maximumHeight: parent.height - Theme.itemSizeSmall/2
    property int itemHeight: Math.round(maximumHeight / visibleItemCount)

    PathView {
        id: view

        property int rollIndex
        property real rollOffset

        x: Theme.paddingLarge
        model: savedWeathersModel
        width: parent.width - 2*x
        pathItemCount: count > 4 ? 5 : Math.min(visibleItemCount, count)
        height: Math.min(visibleItemCount, count)/visibleItemCount*maximumHeight
        offset: rollIndex + rollOffset
        delegate: WeatherCoverItem {
            property bool aboutToSlideIn: view.rollOffset === 0 && model.index === (view.count - view.rollIndex) % view.count

            width: view.width
            visible: view.count <= 4 || !aboutToSlideIn
            topPadding: Theme.paddingLarge + Theme.paddingMedium
            text: (model.status === Weather.Error || model.status === Weather.Unauthorized) ? model.city : TemperatureConverter.format(model.temperature) + " " + model.city
            description: {
                if (model.status === Weather.Error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-loading_failed")
                } else if (model.status === Weather.Unauthorized) {
                    //% "Invalid authentication credentials"
                    return qsTrId("weather-la-unauthorized")
                }

                return model.description
            }
        }
        path: Path {
            startX: view.width/2; startY: view.count > 4 ? -itemHeight/2 : itemHeight/2
            PathLine { x: view.width/2; y: view.height + (view.count > 4 ? itemHeight/2 : itemHeight/2) }
        }
        Binding {
            when: view.count <= 4
            target: view
            property: "offset"
            value: 0
        }
        SequentialAnimation on rollOffset {
            id: rollAnimation
            running: cover.status === Cover.Active && view.visible && view.count > 4
            loops: Animation.Infinite
            NumberAnimation {
                from: 0
                to: 1
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    view.rollIndex = view.rollIndex + 1
                    view.rollOffset = 0
                    if (view.rollIndex >= view.count) {
                        view.rollIndex = 0
                    }
                }
            }
            PauseAnimation { duration: 3000 }
        }
    }
    OpacityRampEffect {
        enabled: view.count > 3
        sourceItem: root
        parent: root.parent
        direction: OpacityRamp.TopToBottom
        slope: 3
        offset: 1 - 1 / slope
    }
}

