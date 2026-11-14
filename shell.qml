import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

PanelWindow {
  id: bar
  property var mediaPlayer: {
    const players = Mpris.players.values
    return players.find(p => p.isPlaying) ?? players[0] ?? null
  }
   

  anchors { top: true; left: true; right: true }
  implicitHeight: 40
  color: "transparent"

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

 
  RowLayout {
      anchors.left: parent.left 
      anchors.verticalCenter: parent.verticalCenter 
      anchors.leftMargin: 14
      spacing: 8

      Pill { icon: "󰁹"; label: bat.value + "%"; iconColor: "#f5e2c5" }

      Pill { icon: ""; label: vol.value + "%"; iconColor: "#f5e2c5" }

  }

  StatsPill {
    anchors.centerIn: parent

    cpuUsage: cpu.value
    ramUsage: ram.value
  }

  RowLayout {
     anchors.right: parent.right 
     anchors.verticalCenter: parent.verticalCenter 
     anchors.rightMargin: 14
     spacing: 6

     Pill {
     icon: "󰎆"
     label: mediaPlayer
        ? mediaPlayer.trackTitle + " — " + mediaPlayer.trackArtist
        : "Play Some Music!"
      }

      Pill {
        icon: " "
       
     } 


  }

  RowLayout {
     anchors.centerIn: parent
     spacing: 7

     Pill { label: Qt.formatTime(new Date(), "hh:mm ")
     }

    
  }

}
