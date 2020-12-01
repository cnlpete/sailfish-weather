TARGET = sailfish-weather

CONFIG += warn_on

SOURCES += weather.cpp

qml.files = weather.qml cover model pages
desktop.files = sailfish-weather.desktop

dbus_service.files = com.jolla.weather.service
dbus_service.path = /usr/share/dbus-1/services

include(sailfishapplication/sailfishapplication.pri)
include(translations.pri)

INSTALLS += dbus_service

OTHER_FILES = \
    org.sailfishos.weather.service \
    rpm/sailfish-weather.spec
