import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var palette: null
    property var player: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying)
            ?? players.find(p => (p.identity || "").toLowerCase().includes("cmus"))
            ?? players[0]
            ?? null
    }

    property bool expanded: false
    property real trackPosition: root.player ? root.player.position : 0
    property bool hovered: false

    readonly property bool playing: root.player !== null && root.player.isPlaying
    readonly property color base: palette ? palette.bg1 : "#3c3836"
    readonly property color soft: palette ? palette.bg2 : "#504945"
    readonly property color stroke: palette ? palette.bg3 : "#665c54"
    readonly property color fg: palette ? palette.fg : "#ebdbb2"
    readonly property color muted: palette ? palette.grey1 : "#bdae93"
    readonly property color accent: palette ? palette.accent : "#fe8019"

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

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    implicitWidth: expanded ? 250 : 90
    implicitHeight: expanded ? 175 : 25

    color: root.base
    radius: expanded ? 20 : height / 2

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

    // Collapsed music pill: animated equalizer while something is playing
    Row {
        anchors.centerIn: parent
        spacing: 8
        visible: !root.expanded
        z: 1

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            color: root.accent
            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 13
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            visible: root.playing

            Repeater {
                model: 4

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 5
                    radius: 1
                    color: root.accent

                    NumberAnimation on height {
                        from: 3
                        to: 11
                        duration: 420 + index * 110
                        loops: Animation.Infinite
                        easing.type: Easing.InOutSine
                        running: root.playing && !root.expanded
                    }
                }
            }
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
        spacing: 10
        visible: root.expanded

        // Album art and track information
        RowLayout {
            Layout.fillWidth: true
            spacing: 11

            Rectangle {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                radius: 11
                color: root.soft
                clip: true

                Image {
                    id: art
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
                    visible: !root.player || !root.player.trackArtUrl || art.status !== Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: root.player
                        ? (root.player.trackTitle || "Unknown title")
                        : "Nothing playing"

                    color: root.fg
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player
                        ? (root.player.trackArtist || "Unknown artist")
                        : "No media player"

                    color: root.accent
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }

        // Seek bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Item {
                id: seekTrack

                Layout.fillWidth: true
                Layout.preferredHeight: 18

                readonly property real fraction: root.player && root.player.length > 0
                    ? Math.max(0, Math.min(1, root.trackPosition / root.player.length))
                    : 0

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: root.stroke
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: seekTrack.width * seekTrack.fraction
                    height: 4
                    radius: 2
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.darker(root.accent, 1.25) }
                        GradientStop { position: 1; color: Qt.lighter(root.accent, 1.12) }
                    }

                    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: root.accent
                    anchors.verticalCenter: parent.verticalCenter

                    x: Math.max(0, Math.min(
                        seekTrack.width - width,
                        seekTrack.width * seekTrack.fraction - width / 2
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
                    text: Qt.formatTime(new Date(root.trackPosition * 1000), "m:ss")
                    color: root.muted
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.player
                        ? Qt.formatTime(new Date(root.player.length * 1000), "m:ss")
                        : "0:00"
                    color: root.muted
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 10
                }
            }
        }

        // Playback controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 24
                visible: root.player && root.player.shuffleSupported

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: shuffleHover.hovered ? root.soft : root.base
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒟"
                    color: root.player && root.player.shuffle ? root.accent : root.fg
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 14
                }

                HoverHandler { id: shuffleHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (root.player && root.player.shuffleSupported)
                            root.player.shuffle = !root.player.shuffle
                    }
                }
            }

            Item {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 24

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: prevHover.hovered ? root.soft : root.base
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.player ? root.fg : root.muted
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 15
                }

                HoverHandler { id: prevHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (root.player && root.player.canGoPrevious)
                            root.player.previous()
                    }
                }
            }

            Item {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 30

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0; color: Qt.lighter(root.accent, 1.15) }
                        GradientStop { position: 1; color: root.accent }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.isPlaying ? "" : ""
                    color: "#1a1512"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 15
                    z: 1
                }

                HoverHandler { id: playHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (root.player && root.player.canTogglePlaying)
                            root.player.togglePlaying()
                    }
                }
            }

            Item {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 24

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: nextHover.hovered ? root.soft : root.base
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.player ? root.fg : root.muted
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 15
                }

                HoverHandler { id: nextHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (root.player && root.player.canGoNext)
                            root.player.next()
                    }
                }
            }

            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 24
                visible: root.player && root.player.loopSupported

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: loopHover.hovered ? root.soft : root.base
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (!root.player || !root.player.loopSupported)
                            return ""

                        if (root.player.loopState === MprisLoopState.Track)
                            return "↻¹"

                        return "↻"
                    }
                    color: !root.player || root.player.loopState === MprisLoopState.None
                        ? root.fg : root.accent
                    font.pixelSize: 14
                    font.family: "CaskaydiaCove Nerd Font"
                }

                HoverHandler { id: loopHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
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
