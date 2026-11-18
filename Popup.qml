
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

Rectangle {
    id: root

    property var palette: null
    property var player: Mpris.players.values[0] ?? null
    property bool expanded: false
    property real trackPosition: root.player ? root.player.position : 0
    property bool hovered: false

    
    Timer {
    interval: 100
    repeat: true

    running: root.expanded
        && root.player !== null
        && root.player.playbackState === MprisPlaybackState.Playing

    onTriggered: {
        root.player.positionChanged()
        root.trackPosition = root.player.position
    }
    }


    layer.enabled: true

    layer.effect: DropShadow {
        opacity: root.expanded ? 1 : 0
        anchors.fill: root
        source: root
        horizontalOffset: 0
        verticalOffset: 0
        radius: 13
        samples: 16
        color: "#30000000"
        spread: 0.50
        transparentBorder: true

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    readonly property color bg: palette ? palette.bg1 : "#1F1D2E"
    readonly property color fg: palette ? palette.fg : "#E0DEF4"
    readonly property color accent: palette ? palette.accent : "#EBBCBA"

    implicitWidth: expanded ? 250 : 44
    implicitHeight: expanded ? 175 : 25

    color: palette ? palette.bg1 : "#040e0d"
    radius: expanded ? 20 : height / 2
    clip: false

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 390
            easing.type: Easing.OutQuint
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 390
            easing.type: Easing.OutQuint
            
        }
    }

    // Background click area: stays behind the popup content
    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: root.expanded = !root.expanded
        cursorShape: Qt.PointingHandCursor
    }

    // Collapsed music icon
    Text {
        anchors.centerIn: parent
        z: 1

        visible: !root.expanded
        text: ""
        color: "transparent"
        font.family: "CaskaydiaCove Nerd Font"
        font.pixelSize: 14

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = true
            cursorShape: Qt.PointingHandCursor
        }
    }

    // Expanded content
    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 12
            leftMargin: 12
            rightMargin: 12
        }

        z: 1
        spacing: 12

        visible: root.expanded
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        // Album art and track information
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52

                radius: 8
                color: root.palette ? root.palette.bg2 : "#26233A"
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.accent
                    font.pixelSize: 25
                    visible: !root.player || !root.player.trackArtUrl
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: root.player
                        ? (root.player.trackTitle || "Unknown title")
                        : "Nothing playing"

                    color: root.fg
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player
                        ? (root.player.trackArtist || "Unknown artist")
                        : "No media player"

                    color: root.accent
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }

        // Seek bar and timestamps
        
        // Seek bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Item {
                id: seekTrack

                Layout.fillWidth: true
                Layout.preferredHeight: 20

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 4
                    color: root.palette ? root.palette.bg3 : "#504945"
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: seekTrack.width * (
                        root.player && root.player.length > 0
                        ? Math.max(0, Math.min(1, root.trackPosition / root.player.length))
                        : 0
                    )
                    height: 4
                    radius: 4
                    color: root.palette ? root.palette.accent : "#e7c08e"
                }

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: root.palette ? root.palette.accent : "#e7c08e"
                    anchors.verticalCenter: parent.verticalCenter

                    x: Math.max(0, Math.min(
                        seekTrack.width - width,
                        seekTrack.width * (
                            root.player && root.player.length > 0
                            ? root.trackPosition / root.player.length
                            : 0
                        ) - width / 2
                    ))
                }

                MouseArea {
                    anchors.fill: parent
                    z: 10
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor

                    function seek(mouseX) {
                        if (!root.player || !root.player.canSeek ||
                            root.player.length <= 0)
                            return

                        let fraction = Math.max(0, Math.min(1, mouseX / width))
                        let position = fraction * root.player.length

                        root.trackPosition = position
                        root.player.position = position
                    }

                    onPressed: mouse => seek(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            seek(mouse.x)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: Qt.formatTime(
                        new Date(root.trackPosition * 1000), "m:ss"
                    )
                    color: root.fg
                    font.pixelSize: 10
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.player
                        ? Qt.formatTime(
                            new Date(root.player.length * 1000), "m:ss"
                        )
                        : "0:00"
                    color: root.fg
                    font.pixelSize: 10
                }
            }
        }


        // Playback controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            // Shuffle
            Text {
                text: "󰒟"
                color: root.player && root.player.shuffle
                    ? root.accent : root.fg

                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 18
                visible: root.player && root.player.shuffleSupported

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.player && root.player.shuffleSupported)
                            root.player.shuffle = !root.player.shuffle
                    }
                }
            }

            // Previous
            Text {
                text: ""
                color: root.fg
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canGoPrevious)
                            root.player.previous()
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Play / Pause
            Text {
                text: root.player && root.player.isPlaying ? "" : ""
                color: root.accent
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canTogglePlaying)
                            root.player.togglePlaying()
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Next
            Text {
                text: ""
                color: root.fg
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canGoNext)
                            root.player.next()
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Repeat
            Text {
                text: {
                    if (!root.player || !root.player.loopSupported)
                        return ""

                    if (root.player.loopState === MprisLoopState.Track)
                        return "↻¹"

                    return "↻"
                }

                color: {
                    if (!root.player || !root.player.loopSupported)
                        return "transparent"

                    return root.player.loopState === MprisLoopState.None
                        ? root.fg : root.accent
                }

                font.pixelSize: 22
                font.family: "CaskaydiaCove Nerd Font"
                visible: root.player && root.player.loopSupported

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!root.player || !root.player.loopSupported)
                            return

                        if (root.player.loopState === MprisLoopState.None) {
                            root.player.loopState = MprisLoopState.Playlist
                        } else if (root.player.loopState === MprisLoopState.Playlist) {
                            root.player.loopState = MprisLoopState.Track
                        } else {
                            root.player.loopState = MprisLoopState.None
                        }
                    }
                }
            }
        }
    }
}
