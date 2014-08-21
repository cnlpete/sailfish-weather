import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import "cover"
import "model"
import "pages"

ApplicationWindow {
    id: weatherApplication

    property var weatherModels
    property bool locationReady: LocationDetection.ready
    property bool currentWeatherAvailable: savedWeathersModel.currentWeather
                                        && savedWeathersModel.currentWeather.status == Weather.Ready

    initialPage: Component { MainPage {} }
    cover: Component { WeatherCover {} }

    signal reload(int locationId)
    signal reloadAll()

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (!Qt.application.active) {
                savedWeathersModel.save()
            }
        }
    }
    Connections {
        target: LocationDetection
        onReadyChanged: updateLocation()
        onLocationIdChanged: updateLocation()
        function updateLocation() {
            if (LocationDetection.ready && LocationDetection.locationId.length > 0) {
                savedWeathersModel.setCurrentWeather({
                                                          "locationId": LocationDetection.locationId,
                                                          "city": LocationDetection.city,
                                                          "state": "",
                                                          "country": ""
                                                      })
                TemperatureConverter.metric = LocationDetection.metric
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
