TARGET = sailfish-weather

CONFIG += warn_on

SOURCES += weather.cpp

HEADERS +=

qml.files = weather.qml cover pages model common

desktop.files = sailfish-weather.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)

OTHER_FILES = rpm/sailfish-weather.spec
