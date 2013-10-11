import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0
import "pages"

ApplicationWindow {
    id: weatherApplication
    property bool currentWeatherAvailable: savedWeathersModel.currentWeather
                                        && savedWeathersModel.currentWeather.status == Weather.Ready

    initialPage: Component { MainPage {} }
    cover: Qt.resolvedUrl("cover/WeatherCover.qml")

    signal reload(int locationId)
    signal reloadAll()

    Repeater {
        model: SavedWeathersModel { id: savedWeathersModel }
        Item {
            WeatherModel {
                id: weatherModel
                // TODO: instead pass only one location object
                locationId: model.locationId
                onError: if (model.status == Weather.Loading) savedWeathersModel.reportError(model.locationId)
                onLoaded: {
                    if (count > 0) {
                        var weather = get(0)
                        savedWeathersModel.update({"locationId": model.locationId,
                                                      "city": model.city,
                                                      "state": model.state,
                                                      "country": model.country,
                                                      "temperature": weather.temperature,
                                                      "weatherType": weather.weatherType,
                                                      "description": weather.description,
                                                      "timestamp": weather.timestamp
                                                  })
                    }
                }
            }
            Connections {
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
