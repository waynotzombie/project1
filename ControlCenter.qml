
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property bool hovered: hover.hovered

    width: 320
    height: 460
    radius: 24
    color: "#1F1D2E"

    // Makes the empty background receive mouse clicks.
    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
    }

    HoverHandler {
        id: hover
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        z: 1

        Text {
            text: "Control Center"
            color: "#E0DEF4"
            font.pixelSize: 20
            font.bold: true
        }

        // Add your volume, brightness, Wi-Fi,
        // Bluetooth and other controls here.
    }
}

