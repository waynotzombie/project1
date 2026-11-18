
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var palette: null
    property string icon: ""
    property string label: ""
    property color iconColor: palette ? palette.accent : "#e7c08e"
    property int maxLabelWidth: 400

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    DropShadow {
        anchors.fill: pill
        source: pill
        horizontalOffset: 0
        verticalOffset: 2
        radius: 12
        samples: 25
        color: "#80000000"
        spread: 0.09
        transparentBorder: true
    }

    Rectangle {
        id: pill
        implicitWidth: row.implicitWidth + 30
        implicitHeight: 25
        radius: height / 2
        color: root.palette ? root.palette.bg1 : "#040e0d"

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: root.icon
                color: root.iconColor
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13
            }

            Text {
                text: root.label
                color: root.palette ? root.palette.fg : "#f5e2c5"
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.maximumWidth: root.maxLabelWidth
                Layout.minimumWidth: implicitWidth
            }
        }
    }
}

