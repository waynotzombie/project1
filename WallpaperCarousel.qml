import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    signal closeRequested()

    property var palette: null
    property string wallDir: "/home/waynotzombie/Pictures/Wallpapers"
    property string currentTab: "__all__"

    // ---- theme (falls back to old look if no palette is passed) ----
    readonly property color cBg0:    palette ? palette.bg0    : "#040e0d"
    readonly property color cBg1:    palette ? palette.bg1    : "#040e0d"
    readonly property color cBg2:    palette ? palette.bg2    : "#222222"
    readonly property color cBg3:    palette ? palette.bg3    : "#383838"
    readonly property color cFg:     palette ? palette.fg     : "#f0f0f0"
    readonly property color cMuted:  palette ? palette.grey1  : "#888888"
    readonly property color cAccent: palette ? palette.accent : "#e7c08e"
    property color iconColor: cAccent

    readonly property string uiFont: "CaskaydiaCove Nerd Font"
    
    

    width: 720
    height: 240
    radius: 20
    color: cBg1
    
    clip: true

    transform: Scale {
        origin.x: root.width / 2
        origin.y: 0
        xScale: 0.05 + 0.95 * root.opacity
        yScale: 0.05 + 0.95 * root.opacity
    }

    Behavior on opacity {
        NumberAnimation { duration: 580; easing.type: Easing.OutQuint }
    }

    enabled: visible && opacity > 0.01

    // ---------- data ----------
    property var allItems: []          // [{fileName, filePath, folder}]
    ListModel { id: shown }            // filtered list shown in the carousel
    ListModel { id: tabs }             // [{label, key, count}]

    function fileUrl(p) {
        return "file://" + encodeURI(p).replace(/#/g, "%23").replace(/\?/g, "%3F")
    }

    function rebuildTabs() {
        var counts = {}
        var order = []
        for (var i = 0; i < allItems.length; i++) {
            var f = allItems[i].folder
            if (counts[f] === undefined) { counts[f] = 0; order.push(f) }
            counts[f]++
        }
        order.sort(function(a, b) { return a.toLowerCase() < b.toLowerCase() ? -1 : 1 })

        tabs.clear()
        tabs.append({ label: "All", key: "__all__", count: allItems.length })
        if (order.length > 1 || (order.length === 1 && order[0] !== "")) {
            for (var j = 0; j < order.length; j++) {
                tabs.append({
                    label: order[j] === "" ? "Root" : order[j],
                    key: order[j] === "" ? "__root__" : order[j],
                    count: counts[order[j]]
                })
            }
        }

        var stillThere = false
        for (var k = 0; k < tabs.count; k++)
            if (tabs.get(k).key === currentTab) stillThere = true
        if (!stillThere) currentTab = "__all__"
    }

    function applyFilter() {
        shown.clear()
        for (var i = 0; i < allItems.length; i++) {
            var it = allItems[i]
            var match = currentTab === "__all__"
                     || (currentTab === "__root__" && it.folder === "")
                     || it.folder === currentTab
            if (match) shown.append(it)
        }
        wallpaperList.currentIndex = 0
        wallpaperList.positionViewAtIndex(0, ListView.Center)
    }

    onCurrentTabChanged: applyFilter()

    onVisibleChanged: {
        if (visible && !scan.running) scan.running = true
    }

    Process {
        id: scan
        running: true
        command: [
            "sh", "-c",
            "cd \"$1\" 2>/dev/null && find -L . -type f \\( " +
            "-iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o " +
            "-iname '*.webp' -o -iname '*.bmp' -o -iname '*.avif' \\) " +
            "-printf '%P\\n' | sort -f",
            "sh", root.wallDir
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.split("\n").filter(function(l) { return l.length > 0 })
                var items = []
                for (var i = 0; i < lines.length; i++) {
                    var rel = lines[i]
                    var slash = rel.lastIndexOf("/")
                    items.push({
                        fileName: rel.substring(slash + 1),
                        filePath: root.wallDir + "/" + rel,
                        folder: slash < 0 ? "" : rel.substring(0, slash)
                    })
                }
                root.allItems = items
                root.rebuildTabs()
                root.applyFilter()
            }
        }
    }

    Process {
        id: applyProcess
        stderr: StdioCollector { id: applyErrors }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Wallpaper change failed:", applyErrors.text)
        }
    }

    // Background click closes the carousel.
    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: root.closeRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ---------- header ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Wallpapers"
                color: root.cFg
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                text: "/"
                color: root.cBg3
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13
            }

            Text {
                text: "Choose your background"
                color: root.cMuted
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 11
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 8
                color: root.cBg2
                implicitWidth: countLabel.implicitWidth + 16
                implicitHeight: 23

                Text {
                    id: countLabel
                    anchors.centerIn: parent
                    text: (shown.count > 0 ? (wallpaperList.currentIndex + 1) + " / " : "") + shown.count
                    color: root.cMuted
                    font.pixelSize: 10
                    font.family: "CaskaydiaCove Nerd Font"
                }
            }
        }

        // ---------- folder tabs ----------
        ListView {
            id: tabStrip
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            orientation: ListView.Horizontal
            spacing: 6
            clip: true
            model: tabs
            visible: tabs.count > 1
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: tab
                required property string label
                required property string key
                required property int count

                readonly property bool active: root.currentTab === key

                height: 24
                width: tabText.implicitWidth + 20
                radius: 12
                color: active ? root.cAccent : (tabHover.hovered ? root.cBg3 : root.cBg2)

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    id: tabText
                    anchors.centerIn: parent
                    text: tab.label + "  " + tab.count
                    color: tab.active ? root.cBg0 : root.cFg
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 10
                    font.bold: tab.active
                }

                HoverHandler { id: tabHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.currentTab = tab.key }
            }
        }

        // ---------- carousel ----------
        ListView {
            id: wallpaperList
            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real focusedW: 240
            readonly property real sideW: 160

            orientation: ListView.Horizontal
            spacing: 10
            clip: true
            model: shown

            interactive: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            // keep the current item locked to the center
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (width - focusedW) / 2
            preferredHighlightEnd: (width + focusedW) / 2
            highlightMoveDuration: 350
            highlightMoveVelocity: -1

            // ---- one wallpaper per wheel notch ----
            property real wheelAcc: 0

            Timer {
                id: wheelCooldown
                interval: 130
            }

            WheelHandler {
                target: null
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                onWheel: (event) => {
                    event.accepted = true
                    if (wheelCooldown.running) return

                    var dx = event.angleDelta.x
                    var dy = event.angleDelta.y
                    var delta = Math.abs(dx) > Math.abs(dy) ? dx : dy

                    wallpaperList.wheelAcc += delta
                    if (Math.abs(wallpaperList.wheelAcc) >= 60) {
                        if (wallpaperList.wheelAcc < 0)
                            wallpaperList.incrementCurrentIndex()
                        else
                            wallpaperList.decrementCurrentIndex()
                        wallpaperList.wheelAcc = 0
                        wheelCooldown.restart()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: shown.count === 0 && !scan.running
                text: "No wallpapers found in " + root.wallDir
                color: root.cMuted
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 11
            }

            delegate: Item {
                id: slot

                required property int index
                required property string fileName
                required property string filePath
                required property string folder

                readonly property bool focused: ListView.isCurrentItem

                width: focused ? wallpaperList.focusedW : wallpaperList.sideW
                height: wallpaperList.height

                Behavior on width {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    id: card
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: slot.focused ? slot.height : slot.height * 0.8
                    radius: 13
                    color: root.cBg2
                    clip: true

                    border.width: slot.focused ? 2 : 1
                    border.color: slot.focused ? root.cAccent
                                : (hover.hovered ? root.cMuted : root.cBg3)

                    Behavior on height {
                        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                    }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Image {
                        id: thumbnail
                        anchors.fill: parent
                        source: root.fileUrl(slot.filePath)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 500

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: thumbnail.width
                                height: thumbnail.height
                                radius: 12
                            }
                        }
                    }

                    // dim overlay for non-focused cards
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: root.cBg0
                        opacity: slot.focused ? 0 : 0.6
                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }

                    // label pill, fades in on the focused card
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        height: 26
                        radius: 8
                        color: Qt.rgba(root.cBg0.r, root.cBg0.g, root.cBg0.b, 0.78)
                        opacity: slot.focused ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            text: slot.fileName
                            color: root.cFg
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 10
                            elide: Text.ElideMiddle
                        }
                    }

                    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }

                    // Side cards slide to center first; clicking the centered card applies it.
                    TapHandler {
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        onTapped: {
                            if (!slot.focused) {
                                wallpaperList.currentIndex = slot.index
                                return
                            }
                            console.log("Applying wallpaper:", slot.filePath)
                            applyProcess.exec([
                                "awww", "img",
                                "--transition-type", "grow",
                                "--transition-duration", "1.2",
                                "--", slot.filePath
                            ])
                            root.closeRequested()
                        }
                    }
                }
            }
        }
    }
}
