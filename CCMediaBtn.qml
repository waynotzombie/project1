import QtQuick

Rectangle {
    id: root

    property var palette: null
    property string glyph: ""
    property bool primary: false
    signal clicked()

    readonly property color base: palette && palette.bg1 ? palette.bg1 : "#1F1D2E"
    readonly property color surface: palette && palette.bg2 ? palette.bg2 : "#26233A"
    readonly property color surfaceHover: palette && palette.bg3 ? palette.bg3 : "#2A2837"
    readonly property color fg: palette && palette.fg ? palette.fg : "#E0DEF4"
    readonly property color accent: palette && palette.accent ? palette.accent : "#EBBCBA"

    implicitWidth: primary ? 56 : 36
    implicitHeight: 26
    radius: 13
    scale: press.pressed ? 0.92 : 1

    color: primary
        ? (hover.hovered ? Qt.lighter(accent, 1.1) : accent)
        : (hover.hovered ? surfaceHover : surface)

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuint } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: press; onTapped: root.clicked() }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.primary ? root.base : root.fg
        font.pixelSize: 19
        font.bold: true
    }
}
