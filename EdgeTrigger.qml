
import Quickshell
import QtQuick
import QtQuick.Shapes

PanelWindow {
    id: root

    anchors {
        right: true
        top: true
        bottom: true
    }

    implicitWidth: 340
    color: "transparent"
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore

    property bool expanded: edge.containsMouse || panelHover.hovered

    // Panel background shape
    Shape {
        id: panelShape

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        width: root.expanded ? 340 : 0
        height: 520

        Behavior on width {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
        }

        ShapePath {
            fillColor: "#1F1D2E"
            strokeColor: "transparent"

            startX: 0
            startY: 30

            PathLine {
                x: panelShape.width - 30
                y: 30
            }

            PathLine {
                x: panelShape.width
                y: 0
            }

            PathLine {
                x: panelShape.width
                y: panelShape.height
            }

            PathLine {
                x: panelShape.width - 30
                y: panelShape.height - 30
            }

            PathLine {
                x: 0
                y: panelShape.height - 30
            }

            PathLine {
                x: 0
                y: 30
            }
        }

        HoverHandler {
            id: panelHover
        }
    }

    // Background click area, behind the controls
    MouseArea {
        anchors.fill: panelShape
        z: 1
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
    }

    // Control center contents
    ControlCenter {
        anchors.left: panelShape.left
        anchors.right: panelShape.right
        anchors.top: panelShape.top
        anchors.bottom: panelShape.bottom

        anchors.rightMargin: 30
        anchors.topMargin: 30
        anchors.bottomMargin: 30

        z: 2
        visible: root.expanded
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }
    }

    // Invisible edge trigger
    MouseArea {
        id: edge

        anchors.right: parent.right
        width: 4
        height: parent.height

        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        z: 3
    }
}

