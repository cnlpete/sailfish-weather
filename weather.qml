import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: weatherApplication
    property var weatherModels
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
        WeatherModel {
            id: weatherModel
            locationId: model.locationId
            onError: if (model.status == Weather.Loading) savedWeathersModel.reportError(model.locationId)
            onLoaded: {
                savedWeathersModel.update({   "locationId": model.locationId,
                                              "city": model.city,
                                              "state": model.state,
                                              "country": model.country,
                                              "temperature": currentWeather.temperature,
                                              "temperatureFeel": currentWeather.temperatureFeel,
                                              "weatherType": currentWeather.weatherType,
                                              "description": currentWeather.description,
                                              "timestamp": currentWeather.timestamp
                                          })
            }
            property Connections reloadOnOpen: Connections {
                target: Qt.application
                onActiveChanged: {
                    if (Qt.application.active) {
                        weatherModel.reload()
                    }
                }
            }
            property Connections reloadOnUsersRequest: Connections {
                target: weatherApplication
                onReload: {
                    if (locationId === model.locationId) {
                        weatherModel.reload()
                    }
                }
                onReloadAll: {
                    weatherModel.reload()
                }
            }
        }
    }
}
