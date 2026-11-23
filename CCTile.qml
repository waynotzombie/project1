import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var palette: null
    property string title: ""
    property string sub: ""
    property bool active: false
    signal clicked()

    readonly property color base: palette && palette.bg1 ? palette.bg1 : "#1F1D2E"
    readonly property color surface: palette && palette.bg2 ? palette.bg2 : "#26233A"
    readonly property color surfaceHover: palette && palette.bg3 ? palette.bg3 : "#2A2837"
    readonly property color fg: palette && palette.fg ? palette.fg : "#E0DEF4"
    readonly property color grey: palette && palette.grey ? palette.grey : "#6E6A86"
    readonly property color accent: palette && palette.accent ? palette.accent : "#EBBCBA"

    Layout.fillWidth: true
    implicitHeight: 60
    radius: 14
    scale: press.pressed ? 0.96 : 1

    color: active
        ? (hover.hovered ? Qt.lighter(accent, 1.1) : accent)
        : (hover.hovered ? surfaceHover : surface)

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: press; onTapped: root.clicked() }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: root.active ? root.base : root.fg
            font.pixelSize: 14
            font.bold: true
            font.family: "CaskaydiaCove Nerd Font"
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: 140 } }
        }

        Text {
            width: parent.width
            text: root.sub
            color: root.active ? root.base : root.grey
            opacity: root.active ? 0.75 : 1
            font.pixelSize: 11
            font.family: "CaskaydiaCove Nerd Font"
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: 140 } }
        }
    }
}
