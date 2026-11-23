import QtQuick

// A little vinyl disc that spins up while music plays and spins down
// (with a bit of inertia) when it stops.
Item {
    id: root
    

    property var palette: null
    property bool spinning: false

    readonly property color base: palette && palette.bg1 ? palette.bg1 : "#1F1D2E"
    readonly property color groove: palette && palette.bg4 ? palette.bg4 : "#393552"
    readonly property color fg: palette && palette.fg ? palette.fg : "#E0DEF4"
    readonly property color accent: palette && palette.accent ? palette.accent : "#EBBCBA"

    implicitWidth: 52
    implicitHeight: 52

    // 0 = stopped, 1 = full speed; animated for the spin-up / spin-down feel
    property real speed: spinning ? 1 : 0
    Behavior on speed { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }

    FrameAnimation {
        running: root.speed > 0.001
        // 150 degrees per second at full speed, about one turn every 2.4s
        onTriggered: disc.rotation = (disc.rotation + frameTime * 150 * root.speed) % 360
    }

    Item {
        id: disc
        anchors.fill: parent

        // record body
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: root.base
            border.width: 1
            border.color: root.groove
        }

        // grooves
        Repeater {
            model: 3
            Rectangle {
                required property int index
                anchors.centerIn: parent
                width: disc.width - 8 - index * 8
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: root.groove
                opacity: 0.6
            }
        }

        // faint reflection across the record, so the rotation is visible
        Rectangle {
            anchors.centerIn: parent
            width: disc.width - 4
            height: 2
            radius: 1
            color: root.fg
            opacity: 0.12
            rotation: 35
        }

        // center label
        Rectangle {
            anchors.centerIn: parent
            width: disc.width * 0.36
            height: width
            radius: width / 2
            color: root.accent

            // mark on the label
            Rectangle {
                width: 4
                height: 4
                radius: 2
                color: root.base
                x: parent.width / 2 - width / 2
                y: 2
            }
        }

        // spindle hole
        Rectangle {
            anchors.centerIn: parent
            width: 5
            height: 5
            radius: 3
            color: root.base
        }
    }
}
