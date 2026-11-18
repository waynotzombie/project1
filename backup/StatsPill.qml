import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
Rectangle {
    id: root

    property var palette: null
    property string cpuUsage: "0"
    property string ramUsage: "0"
    property bool expanded: false

    implicitWidth: row.implicitWidth + 30
    implicitHeight: 26

    radius: height / 2
    color: palette ? palette.bg1 : "#040e0d"
    clip: true

    layer.enabled: true
    layer.effect: DropShadow {
        verticalOffset: 3
        radius: 12
        samples: 180
        spread: 0.19
        color: "#50000000"
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
        }
    }

    HoverHandler {
        onHoveredChanged: root.expanded = hovered
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: "󰍛 " + root.cpuUsage + "%"
            color: root.palette ? root.palette.purple : "#e7c08e"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }

        Text {
            text: "SYST"
            color: "transparent"
            font.pixelSize: 12
        }

        Text {
            visible: root.expanded
            text: "󰘚 " + root.cpuUsage + "%"
            color: root.palette ? root.palette.accent : "#e7c08e"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }

        Text {
            visible: root.expanded
            text: root.ramUsage + "%" + " 󰓅"
            color: root.palette ? root.palette.accent : "#e7c08e"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }
    }
}
