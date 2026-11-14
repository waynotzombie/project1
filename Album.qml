import Quickshell
import QtQuick 
import Quickshell.Services.Mpris
import QtQuick.Layouts

Rectangle {
  id: root
  property string album: ""
  property bool expanded: false
  
  implicitWidth: row.implicitWidth + 30
  implicitHeight: 28

  radius: height / 2
  color: "#ffffff"
  clip: true
  
   HoverHandler {
      onHoveredChanged: root.expanded = hovered
   }

   Behavior on implicitWidth {
        NumberAnimation {
        duration: 250 
        easing.type: Easing.OutBack
     }
   }

  Text {
    text: root.label
    color: "#f5e2c5"
    font.family: "CaskaydiaCove Nerd Font"
    font.pixelSize: 13
    elide: Text.ElideRight
  } 
}

