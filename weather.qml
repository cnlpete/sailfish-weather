import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import com.jolla.settings.system 1.0
import MeeGo.Connman 0.2
import "cover"
import "model"
import "pages"

ApplicationWindow {
    id: weatherApplication

    property var weatherModels
    property bool positioningAllowed: locationSettings.locationEnabled && gpsTechModel.powered
    property bool currentLocationReady: currentLocationModel && currentLocationModel.ready
    property QtObject currentLocationModel
    property bool currentWeatherAvailable: savedWeathersModel.currentWeather
                                        && savedWeathersModel.currentWeather.status == Weather.Ready

    onCurrentLocationReadyChanged: {
        if (currentLocationReady) {
            savedWeathersModel.setCurrentWeather({
                                                      "locationId": currentLocationModel.locationId,
                                                      "city": currentLocationModel.city,
                                                      "state": "",
                                                      "country": ""
                                                  })
        }
    }
    onPositioningAllowedChanged: handleLocationSetting()
    Component.onCompleted: handleLocationSetting()

    function handleLocationSetting() {
        if (positioningAllowed) {
            if (!currentLocationModel) {
                var currentLocationModelComponent = Qt.createComponent("model/CurrentLocationModel.qml")
                if (currentLocationModelComponent.status === Component.Ready) {
                    currentLocationModel = currentLocationModelComponent.createObject(weatherApplication)
                    currentLocationModel.active = Qt.binding(function() {
                        return weatherApplication.positioningAllowed && Qt.application.active
                    })
                } else {
                    console.log(currentLocationModelComponent.errorString())
                }
            }
        }
    }

    initialPage: Component { MainPage {} }
    cover: Component { WeatherCover {} }

    signal reload(int locationId)
    signal reloadAll()

    LocationSettings {
        id: locationSettings
    }
    TechnologyModel {
        id: gpsTechModel
        name: "gps"
    }
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (!Qt.application.active) {
                savedWeathersModel.save()
            }
        }
    }
    ApplicationWeatherModel {
        id: currentWeatherModel
        weather: savedWeathersModel.currentWeather
        savedWeathers: savedWeathersModel
        application: weatherApplication
    }
    Instantiator {
        onObjectAdded: {
            if (weatherModels) {
                var models = weatherModels
            } else {
                var models = {}
            }
            models[object.locationId] = object
            weatherModels = models
        }

        model: SavedWeathersModel { id: savedWeathersModel }
        ApplicationWeatherModel {
            weather: model
            savedWeathers: savedWeathersModel
            application: weatherApplication
        }
    }
}
