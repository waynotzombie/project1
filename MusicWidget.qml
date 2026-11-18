
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var palette: null
    property bool expanded: false

    property var player: Mpris.players.values[0] ?? null

    readonly property color bg: palette ? palette.bg1 : "#1F1D2E"
    readonly property color fg: palette ? palette.fg : "#E0DEF4"
    readonly property color accent: palette ? palette.accent : "#EBBCBA"

    implicitWidth: expanded ? 270 : 44
    implicitHeight: expanded ? 31 : 25

    radius: height / 2
    color: bg
    clip: true

        layer.enabled: true
    layer.effect: DropShadow {
      
        horizontalOffset: 0
        verticalOffset: 2 
        radius: 12 
        samples: 25
        color: "#80000000"
        spread: 0.09
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

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Circular toggle button
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 12
            radius: 999 
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: ""
                color: root.accent
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.expanded = !root.expanded
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Expanded music widget
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            visible: root.expanded
            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 26
                radius: 7
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
                    visible: !root.player || !root.player.trackArtUrl
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.player ? (root.player.trackTitle || "Unknown title") : "Nothing playing"
                    color: root.fg
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player ? (root.player.trackArtist || "Unknown artist") : "No media player"
                    color: root.accent
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            Text {
                text: ""
                color: root.fg
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canGoPrevious)
                        root.player.previous()
                        
                      }
                      cursorShape: Qt.PointingHandCursor  
                }
            }

            Text {
                text: root.player && root.player.isPlaying ? "" : ""
                color: root.accent
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 15

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canTogglePlaying)
                        root.player.togglePlaying()

                    }
                     cursorShape: Qt.PointingHandCursor
                    

                  }    
            }

            Text {
                text: ""
                color: root.fg
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.player && root.player.canGoNext)
                        root.player.next()

                      }
                    cursorShape: Qt.PointingHandCursor
                  }


            }

            Item {
                Layout.preferredWidth: 5
            }
        }
    }
}

