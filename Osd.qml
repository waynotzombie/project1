import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire

// Volume + brightness OSD.
// Volume reacts automatically to PipeWire changes.
// Brightness watches /sys/class/backlight, so any source of change shows the OSD.

Scope {
    id: root

    Theme { id: theme }

    // --- Style (pulled from the generated Theme object) ---
    readonly property color bgColor: Qt.alpha(theme.bg0, 0.85)
    readonly property color borderColor: Qt.alpha(theme.bg3, 0.6)
    readonly property color fgColor: theme.fg
    readonly property color trackColor: theme.bg3
    readonly property color accentColor: theme.accent
    readonly property color mutedColor: theme.grey
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int hideDelay: 1500

    // --- State ---
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1 (volume can exceed 1 with boost)
    property bool muted: false
    property bool shown: false
    property bool ready: false       // ignore the initial PipeWire sync at startup

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker { objects: [root.sink] }

    Timer {
        interval: 1000
        running: true
        onTriggered: root.ready = true
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root.shown = false
    }

    function pop() {
        shown = true
        hideTimer.restart()
    }

    function showVolume() {
        if (!ready || !sink?.audio) return
        kind = "volume"
        value = sink.audio.volume
        muted = sink.audio.muted
        pop()
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { root.showVolume() }
        function onMutedChanged() { root.showVolume() }
    }

    // --- Brightness: watch the backlight in sysfs (no keybind/IPC needed) ---
    // Device name comes from `brightnessctl -m` (first field).
    readonly property string backlight: "amdgpu_bl1"
    property int lastRaw: -1

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root.backlight + "/max_brightness"
        blockLoading: true
    }

    FileView {
        id: curFile
        path: "/sys/class/backlight/" + root.backlight + "/brightness"
        blockLoading: true
    }

    Timer {
        interval: 120
        running: true
        repeat: true
        onTriggered: {
            curFile.reload()
            const raw = parseInt(curFile.text())
            const max = parseInt(maxFile.text())
            if (isNaN(raw) || isNaN(max) || max <= 0) return

            // First read only records the starting value (no popup at startup)
            if (root.lastRaw >= 0 && raw !== root.lastRaw) {
                root.kind = "brightness"
                root.value = raw / max
                root.muted = false
                root.pop()
            }
            root.lastRaw = raw
        }
    }

    // --- Icons (Nerd Font, Material Design set) ---
    function glyph(code) { return String.fromCodePoint(code) }

    function iconFor() {
        if (kind === "brightness") return glyph(value > 0.5 ? 0xF00E0 : 0xF00DF)
        if (muted || value <= 0) return glyph(0xF075F)
        if (value < 0.34) return glyph(0xF057F)
        if (value < 0.67) return glyph(0xF0580)
        return glyph(0xF057E)
    }

    // --- Window ---
    PanelWindow {
        id: win
        visible: root.shown || card.opacity > 0.01

        anchors.bottom: true
        margins.bottom: 90
        implicitWidth: 300
        implicitHeight: 64
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-osd"

        // Empty mask = click-through
        mask: Region {}

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 18
            color: root.bgColor
            border.width: 1
            border.color: root.borderColor

            opacity: root.shown ? 1 : 0
            scale: root.shown ? 1 : 0.94
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 14

                Text {
                    text: root.iconFor()
                    color: root.muted ? root.mutedColor : root.accentColor
                    font.family: root.fontFamily
                    font.pixelSize: 26
                    Layout.alignment: Qt.AlignVCenter
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 8
                    radius: 4
                    color: root.trackColor

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        width: parent.width * Math.max(0, Math.min(1, root.value))
                        color: root.muted ? root.mutedColor : root.accentColor
                        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                Text {
                    text: Math.round(root.value * 100) + "%"
                    color: root.fgColor
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 42
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
