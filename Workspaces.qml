import Quickshell
import QtQuick
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var palette: null
    readonly property color fg: palette ? palette.fg : "#ebdbb2"
    readonly property color accent: palette ? palette.accent : "#fe8019"
    readonly property color muted: palette ? palette.grey1 : "#bdae93"

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 25

    radius: height / 2
    color: palette ? palette.bg1 : "#3c3836"

    layer.enabled: true
    layer.effect: DropShadow {
        width: root.width
        height: root.height
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
                height: 16

                Rectangle {
                    id: dot

                    anchors.centerIn: parent

                    property bool active: modelData.active
                    property bool hovered: wsHover.hovered

                    width: active ? 10 : (hovered ? 8 : 7)
                    height: active ? 14 : (hovered ? 8 : 7)
                    radius: 6

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0
                            color: dot.active
                                ? Qt.lighter(root.accent, 1.2)
                                : Qt.lighter(root.muted, 1.15)
                        }
                        GradientStop {
                            position: 1
                            color: dot.active ? root.accent : root.muted
                        }
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 280
                            easing.type: Easing.OutBack
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 280
                            easing.type: Easing.OutBack
                        }
                    }
                }

                TapHandler {
                    onTapped: modelData.activate()
                }

                HoverHandler {
                    id: wsHover
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
