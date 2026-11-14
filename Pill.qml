
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: "#e7c08e"
    property int maxLabelWidth: 400

    implicitWidth: row.implicitWidth + 30
    implicitHeight: 24
    radius: height / 2
    color: "#040e0d"

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: root.icon
            color: root.iconColor
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 13
        }

        Text {
            text: root.label
            color: "#f5e2c5"
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 13
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            Layout.minimumWidth: implicitWidth
        }
    }
}

