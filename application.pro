TARGET = sailfish-weather

CONFIG += warn_on

SOURCES += weather.cpp

qml.files = weather.qml cover model pages
desktop.files = sailfish-weather.desktop

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)

OTHER_FILES = rpm/sailfish-weather.spec
