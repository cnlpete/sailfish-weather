import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

WeatherModel {
    id: model

    property bool loading
    onStatusChanged: {
        if (status == Weather.Loading) {
            loading = true
            loadingReferenceCount = loadingReferenceCount + 1
        } else if (loading) {
            loadingReferenceCount = loadingReferenceCount - 1
        }
    }

    active: Qt.application.active
    property Connections reloadOnUsersRequest: Connections {
        target: weatherApplication
        onReload: {
            if (locationId === model.locationId) {
                model.reload()
            }
        }
        onReloadAll: model.reload()
    }
}
