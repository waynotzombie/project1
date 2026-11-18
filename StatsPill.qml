import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


Rectangle {
    id: root

    property var palette: null
    property string cpuUsage: "0"
    property string ramUsage: "0"
    property bool expanded: false
    property bool popupHovered: false

    

    implicitWidth: row.implicitWidth + 30
    implicitHeight: 26

    layer.enabled: true
    layer.effect: DropShadow {
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

    radius: height / 2
    color: palette ? palette.bg1 : "#040e0d"
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
        }
    }

    HoverHandler {
        id: hoverHandler
    onHoveredChanged: {
        root.expanded = hovered || root.popupHovered
        }
    }

    onPopupHoveredChanged: {
        root.expanded = hoverHandler.hovered || popupHovered
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: "󰍛 " + root.cpuUsage + "%"
            color: root.palette ? root.palette.accent : "#e7c08e"
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
            color: "transparent"
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
