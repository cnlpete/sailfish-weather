import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import "cover"
import "model"
import "pages"

ApplicationWindow {
    id: weatherApplication

    property var weatherModels
    property bool currentWeatherAvailable: savedWeathersModel.currentWeather
                                        && savedWeathersModel.currentWeather.populated

    initialPage: Component { MainPage {} }
    cover: Component { WeatherCover {} }

    signal reload(int locationId)
    signal reloadAll()
    signal reloadAllIfAllowed()

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

        savedWeathers: savedWeathersModel
        weather: savedWeathersModel.currentWeather
    }
    Instantiator {
        onObjectAdded: {
            var models = weatherModels ? weatherModels : {}
            models[object.locationId] = object
            weatherModels = models
        }

        model: SavedWeathersModel { id: savedWeathersModel }
        ApplicationWeatherModel {
            savedWeathers: savedWeathersModel
            weather: model
        }
    }
}
