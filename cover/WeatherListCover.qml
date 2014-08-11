import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    id: root

    property int visibleItemCount: 4
    property int maximumHeight: parent.height - Theme.itemSizeSmall/2
    property int itemHeight: Math.round(maximumHeight / visibleItemCount)

    PathView {
        id: view

        x: Theme.paddingLarge
        model: savedWeathersModel
        width: parent.width - 2*x
        pathItemCount: count > 4 ? 5 : Math.min(visibleItemCount, count)
        height: Math.min(visibleItemCount, count)/visibleItemCount*maximumHeight
        delegate: Column {
            width: view.width

            Item {
                width: parent.width
                height: Theme.paddingLarge + Theme.paddingSmall
            }
            Label {
                width: parent.width
                text: model.status === Weather.Error ? model.city : model.temperature + "\u00B0" + " " + model.city
                truncationMode: TruncationMode.Fade
            }
            Label {
                width: parent.width
                //% "Loading failed"
                text: model.status === Weather.Error ? qsTrId("weather-la-loading_failed") : model.description
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }
        }
        path: Path {
            startX: view.width/2; startY: view.count > 4 ? -itemHeight/2 : itemHeight/2
            PathLine { x: view.width/2; y: view.height + (view.count > 4 ? itemHeight/2 : itemHeight/2) }
        }
        Binding {
            when: view.count <= 4
            target: view
            property: "offset"
            value: 0
        }
        NumberAnimation on offset {
            running: cover.status === Cover.Active && view.visible && view.count > 4
            loops: Animation.Infinite
            from: 0.0
            to: view.count
            duration: 3000*view.count
        }
    }
    OpacityRampEffect {
        enabled: view.count > 3
        sourceItem: root
        parent: root.parent
        direction: OpacityRamp.TopToBottom
        slope: 3
        offset: 1 - 1 / slope
    }
}

