
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string cpuUsage: "0"
    property string ramUsage: "0"
    property bool expanded: false

    implicitWidth: row.implicitWidth + 30
    implicitHeight: 28

    radius: height / 2
    color: "#040e0d"
    clip: true

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
            color: "#e7c08e"
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
            color: "#e7c08e"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }

        Text {
            visible: root.expanded
            text: root.ramUsage + "%" + " 󰓅"
            color: "#e7c08e"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }
    }
}

