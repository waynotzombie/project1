import Quickshell
import QtQuick

PanelWindow {
    id: popupWindow

    visible: false

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 280
    exclusiveZone: 0
    color: "transparent"

    Popup {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        palette: Theme {}
    }
}