import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var palette: null
    property string icon: ""
    property string label: ""
    property color iconColor: palette ? palette.purple : "#e7c08e"
    property int maxLabelWidth: 400
    property bool hovered: mouse.containsMouse

    implicitWidth: row.implicitWidth + 30
    implicitHeight: 24
    radius: height / 2
    color: palette ? palette.bg1 : "#040e0d"

    

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: root.icon
            color: root.iconColor
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 12
        }

        Text {
            text: root.label
            color: root.palette ? root.palette.fg : "#f5e2c5"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 13
            font.weight: 600
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            Layout.minimumWidth: implicitWidth
        }
      }
         
}

