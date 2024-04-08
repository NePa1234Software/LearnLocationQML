
import QtQuick
import QtPositioning
import QtLocation

// https://doc.qt.io/qt-6/qtlocation-index.html
// The Qt Location API enables you to:
//     Access and present map data.
//     Support touch gesture on a specific area of the map.
//     Query for a specific geographical location and route.
//     Add additional layers on top, such as polylines and circles.
//     Search for places and related images.
Window {
    width: 600
    height: 600
    visible: true
    title: qsTr("Learning the Location Module")

    Plugin {
        id: mapPlugin
        name: "osm"
        allowExperimental: true

        // Workaround to get rid of the "API Key Required" text on the map
        // https://bugreports.qt.io/browse/QTBUG-115742
        PluginParameter {
            name: "osm.mapping.custom.host"
            value: "https://tile.openstreetmap.org/"
            //value: "https://tile.thunderforest.com/cycle/%z/%x/%y.png?apikey=<my API key here>"
        }

        Component.onCompleted: {
            console.log("availableServiceProviders:", mapPlugin.availableServiceProviders)
            console.log("parameters:", mapPlugin.parameters)
        }
    }

    // MapView wraps a Map object and adds pan, zoom and tilt
    MapView {
        id: mapView
        anchors.fill: parent
        map.plugin: mapPlugin
        map.center: QtPositioning.coordinate(50.76730821421347, -1.3138444738017094) // (59.91, 10.75) // Oslo
        map.zoomLevel: 18
        map.activeMapType: mapView.map.supportedMapTypes[mapView.map.supportedMapTypes.length - 1]

        Column {
            Text { text: "availableServiceProviders: " + mapPlugin.availableServiceProviders.toString(); }
            Text { text: "supportedMapTypes: \n " + mapView.map.supportedMapTypes.join('\n'); }
            // Text { text: "plugin: " + mapPlugin.toString(); }
        }

        TapHandler {
            id: tapHandler
            property variant lastCoordinate
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressedChanged: (eventPoint, button) => {
                if (pressed) {
                    lastCoordinate = mapView.map.toCoordinate(tapHandler.point.position)
                }
            }

            onSingleTapped: (eventPoint, button) => {
                    if (button === Qt.RightButton) {
                        // showMainMenu(lastCoordinate)
                    }
            }

            onDoubleTapped: (eventPoint, button) => {
                var preZoomPoint = mapView.map.toCoordinate(eventPoint.position);
                if (button === Qt.LeftButton) {
                    mapView.map.zoomLevel = Math.floor(mapView.map.zoomLevel + 1)
                } else if (button === Qt.RightButton) {
                    mapView.map.zoomLevel = Math.floor(mapView.map.zoomLevel - 1)
                }
                var postZoomPoint = mapView.map.toCoordinate(eventPoint.position);
                var dx = postZoomPoint.latitude - preZoomPoint.latitude;
                var dy = postZoomPoint.longitude - preZoomPoint.longitude;

                mapView.map.center = QtPositioning.coordinate(mapView.map.center.latitude - dx,
                                                           mapView.map.center.longitude - dy);
            }
        }
    }
}
