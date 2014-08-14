import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

WeatherModel {
    id: model

    property date lastUpdate: new Date()
    property QtObject application

    property Connections reloadOnOpen: Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                var now = new Date()
                // only update automatically if more than 10 minutes has
                // passed since the last update (10*60*1000)
                if (now - 600000 > lastUpdate) {
                    model.reload()
                    lastUpdate = now
                }
            }
        }
    }

    property Connections reloadOnUsersRequest: Connections {
        target: application
        onReload: {
            if (locationId === model.locationId) {
                model.reload()
                lastUpdate = new Date()
            }
        }
        onReloadAll: {
            model.reload()
            lastUpdate = new Date()
        }
    }
}
