import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var palette: null
    property string label: ""
    property real value: 0
    signal moved(real v)

    readonly property color base: palette && palette.bg1 ? palette.bg1 : "#1F1D2E"
    readonly property color track: palette && palette.bg2 ? palette.bg2 : "#26233A"
    readonly property color fg: palette && palette.fg ? palette.fg : "#E0DEF4"
    readonly property color accent: palette && palette.accent ? palette.accent : "#EBBCBA"

    // color of the filled part; override per slider
    property color fill: accent

    property real local: 0
    readonly property bool dragging: ma.pressed
    property real displayed: dragging ? local : value
    readonly property string caption: label + "   " + Math.round(displayed * 100) + "%"

    Behavior on displayed {
        enabled: !root.dragging
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }
    Behavior on fill { ColorAnimation { duration: 160 } }

    Layout.fillWidth: true
    implicitHeight: 38

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.track

        Text {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.caption
            color: root.fg
            font.pixelSize: 12
            font.family: "CaskaydiaCove Nerd Font"
            font.bold: true
        }

        // filled part; its own copy of the text is clipped to it, so the
        // label stays readable on both the track and the fill
        Item {
            width: Math.max(parent.height, parent.width * root.displayed)
            height: parent.height
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: root.fill
            }

            Text {
                x: 14
                anchors.verticalCenter: parent.verticalCenter
                text: root.caption
                color: root.base
                font.pixelSize: 12
                font.family: "CaskaydiaCove Nerd Font"
                font.bold: true
            }

            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: root.base
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                opacity: (ma.containsMouse || root.dragging) ? 0.9 : 0
                scale: root.dragging ? 1.25 : 1
                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function upd(x) {
            root.local = Math.max(0, Math.min(1, x / width))
            root.moved(root.local)
        }
        onPressed: mouse => upd(mouse.x)
        onPositionChanged: mouse => { if (pressed) upd(mouse.x) }
        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            root.local = Math.max(0, Math.min(1, root.value + step))
            root.moved(root.local)
        }
    }
}
