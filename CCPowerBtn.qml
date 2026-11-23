import QtQuick
import QtQuick.Layouts

// first click arms the button (with a draining timer bar), second click runs it
Rectangle {
    id: root

    property var palette: null
    property string label: ""
    property bool confirm: false
    property bool armed: false
    signal fire()

    readonly property color base: palette && palette.bg1 ? palette.bg1 : "#1F1D2E"
    readonly property color surface: palette && palette.bg2 ? palette.bg2 : "#26233A"
    readonly property color surfaceHover: palette && palette.bg3 ? palette.bg3 : "#2A2837"
    readonly property color fg: palette && palette.fg ? palette.fg : "#E0DEF4"
    readonly property color red: palette && palette.red ? palette.red : "#EB6F92"

    Layout.fillWidth: true
    implicitHeight: 40
    radius: 12
    scale: press.pressed ? 0.95 : 1
    color: armed ? red : (hover.hovered ? surfaceHover : surface)

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler {
        id: press
        onTapped: {
            if (root.confirm && !root.armed) {
                root.armed = true
                drain.restart()
            } else {
                drain.stop()
                bar.width = 0
                root.armed = false
                root.fire()
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.armed ? "Sure?" : root.label
        color: root.armed ? root.base : root.fg
        font.pixelSize: 12
        font.family: "CaskaydiaCove Nerd Font"
        font.bold: true
    }

    Rectangle {
        id: bar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 10
        height: 2
        radius: 1
        width: 0
        color: root.base
        opacity: 0.55
    }

    NumberAnimation {
        id: drain
        target: bar
        property: "width"
        from: root.width - 20
        to: 0
        duration: 3000
        onFinished: root.armed = false
    }
}
