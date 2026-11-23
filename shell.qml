

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "."

PanelWindow {
    id: bar

    Theme {
        id: theme
    }

    property var mediaPlayer: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying) ?? players[0] ?? null
    }

    property bool wallpaperOpen: false

    IpcHandler {
        target: "wallpaperCarousel"

        function toggle(): void {
            bar.wallpaperOpen = !bar.wallpaperOpen
        }
    }
    
    ControlCenter { id: controlCenter; palette: theme }
    
    WallpaperWindow {
        open: bar.wallpaperOpen
        onCloseRequested: bar.wallpaperOpen = false
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 370
    exclusiveZone: 37
    color: "transparent"

    // Only these widget areas receive mouse input.
    // Everything else in the 300px panel is click-through.
  mask: Region {
    Region {
        item: leftItems
    }

    Region {
        item: popup
    }

    Region {
        item: stats
    }

    Region {
        item: clockDisplay
    }

    Region {
        item: rightItems
    }

    
  }

    Poller {
        id: clock
        command: "date +%H:%M"
        interval: 60000
    }

    Poller {
        id: vol
        command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf\"%d\", $2*100}'"
        interval: 1000
    }

    Poller {
        id: date 
        command: "date +\"%A %d %B\""
    }

    Poller {
        id: bat
        command: "cat /sys/class/power_supply/BAT0/capacity"
        interval: 30000
    }

    Poller {
        id: bt
        command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
    }

    Poller {
        id: net
        command: "nmcli -t -f NAME connection show --active | head -n1"
        interval: 5000
    }

    Poller {
        id: cpu
        command: "LC_ALL=C top -bn1 | awk -F'[, ]+' '/Cpu\\(s\\)/ {for(i=1;i<=NF;i++) if($i==\"id\") {printf \"%.0f\",100-$(i-1); exit}}'"
        interval: 2000
    }

    Poller {
        id: ram
        command: "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"
        interval: 3000
    }

    Osd {}

    
    Item {
        id: barContents

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 41

        
        

        RowLayout {
            id: leftItems
            

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 14
            }

            spacing: 8

            Pill {
                palette: theme
                icon: "󰁹"
                label: bat.value + "%"
            }

            Workspaces {
                palette: theme
            }


        }

        Popup {
            id: popup
            visible: !bar.wallpaperOpen

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            anchors.topMargin: 8

            z: 0
            palette: theme
        }


        



        StatsPill {
          id: stats
          anchors.centerIn: parent
          z: 2
          opacity: (popup.expanded || bar.wallpaperOpen) ? 0 : 1   
          visible: opacity > 0
          enabled: opacity > 0.1

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuint
        }
    }


 
            palette: theme
            cpuUsage: cpu.value
            ramUsage: ram.value
        }
    
        Item {
    id: clockContainer

    width: parent.width
    height: parent.height
    anchors.centerIn: parent

    // Keep this above the StatsPill and Popup
    z: 3

            Clock {
            id: clockDisplay

            label: Qt.formatTime(new Date(), "hh:mm")    
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -4
            z: 3
            opacity: (popup.expanded || bar.wallpaperOpen) ? 0 : 1
            visible: opacity > 0
            enabled: opacity > 0.1
        
        Behavior on opacity {
            NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuint
            }
        }

          palette: theme 
        }
}

        RowLayout {
            id: rightItems
            

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 14
            }

            spacing: 6


            Pill {
                palette: theme 
                label: date.value
            }
        }
    }
}


