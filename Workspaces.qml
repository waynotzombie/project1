
import Quickshell
import QtQuick
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var palette: null
    readonly property color bg: palette ? palette.bg1 : "#1F1D2E"
    readonly property color fg: palette ? palette.fg : "#E0DEF4"
    readonly property color accent: palette ? palette.accent : "#EBBCBA"

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 25

    radius: height / 2
    color: palette ? palette.bg1 : "#040d0d"

    layer.enabled: true
    layer.effect: DropShadow {
        opacity: root.expanded ? 1 : 0
        anchors.fill: root
        source: root
        horizontalOffset: 0
        verticalOffset: 0
        radius: 13
        samples: 16
        color: "#30000000"
        spread: 0.50
        transparentBorder: true
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                required property var modelData

                width: dot.width
                height: 15

                Rectangle {
                    id: dot

                    anchors.centerIn: parent

                    property bool active: modelData.active

                    width: active ? 9 : 7
                    height: active ? 14 : 7
                    radius: 6

                    color: active
                        ? "transparent"
                        : (root.palette ? root.palette.fg : "#fbb606")

                    border.width: active ? 2 : 0
                    border.color: root.palette
                        ? root.palette.accent
                        : "#f87503"

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }
                }

                TapHandler {
                    onTapped: modelData.activate()
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
