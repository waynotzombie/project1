
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel

Rectangle {
    id: root

    signal closeRequested()

    property var palette: null
    property color iconColor: palette ? palette.accent : "#e7c08e"

    width: 720
    height: 205
    radius: 20

    color: palette ? palette.bg1 : "#040e0d"
    border.width: 1
    border.color: palette ? palette.bg3 : "#000000"
    clip: true

    transform: Scale {
        origin.x: root.width / 2
        origin.y: 0
        xScale: 0.05 + 0.95 * root.opacity
        yScale: 0.05 + 0.95 * root.opacity
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutBack
        }
    }

    enabled: visible && opacity > 0.01

    FolderListModel {
        id: wallpapers

        folder: "file:///home/waynotzombie/Pictures/Wallpapers"

        nameFilters: [
            "*.png", "*.jpg", "*.jpeg",
            "*.webp", "*.bmp", "*.avif"
        ]

        showDirs: false
        showFiles: true
        sortField: FolderListModel.Name
    }

    Process {
        id: applyProcess

        stderr: StdioCollector {
            id: applyErrors
        }

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
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Wallpapers"
                color: "#f0f0f0"
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                text: "/"
                color: "#555555"
                font.pixelSize: 13
            }

            Text {
                text: "Choose your background"
                color: "#888888"
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 11
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                radius: 8
                color: "#252525"
                implicitWidth: countLabel.implicitWidth + 16
                implicitHeight: 23

                Text {
                    id: countLabel
                    anchors.centerIn: parent
                    text: wallpapers.count + " wallpapers"
                    color: "#aaaaaa"
                    font.pixelSize: 10
                    font.family: "CaskaydiaCove Nerd Font"
                }
            }
        }

        ListView {
            id: wallpaperList

            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: ListView.Horizontal
            spacing: 12
            clip: true

            model: wallpapers

            interactive: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                onWheel: (event) => {
                wallpaperList.contentX = Math.max(
                0,
                Math.min(
                wallpaperList.contentWidth - wallpaperList.width,
                wallpaperList.contentX + event.angleDelta.y * -0.5
                        )
                    )
                }
            }

            delegate: Rectangle {
                id: wallpaperCard

                required property url fileUrl
                required property string fileName
                required property string filePath

                width: 205
                height: 145
                radius: 13

                color: "#222222"
                border.width: 1
                border.color: hover.hovered ? "#888888" : "#383838"

                clip: true

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Image {
                    id: thumbnail

                    anchors.fill: parent

                    source: fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    layer.enabled: true

                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: thumbnail.width
                            height: thumbnail.height
                            radius: 12
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: 38
                    color: "#99000000"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft

                        text: fileName
                        color: "#eeeeee"

                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 10

                        elide: Text.ElideMiddle
                    }
                }

                HoverHandler {
                    id: hover
                    cursorShape: Qt.PointingHandCursor
                }

                // TapHandler allows ListView dragging to work.
                TapHandler {
                    gesturePolicy: TapHandler.ReleaseWithinBounds

                    onTapped: {
                        console.log("Applying wallpaper:", filePath)

                        applyProcess.exec([
                            "awww",
                            "img",
                            "--transition-type",
                            "grow",
                            "--transition-duration",
                            "1.2",
                            "--",
                            filePath
                        ])

                        root.closeRequested()
                    }
                }
            }
        }
    }
}
