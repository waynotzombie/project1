import Quickshell
import Quickshell.Wayland
import QtQuick
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: carouselWindow

    property bool open: false
    signal closeRequested()

    readonly property int shadowPad: 40

    visible: open || carousel.opacity > 0.01

    anchors.top: true
    margins.top: 0
    implicitWidth: carousel.width + shadowPad * 2
    implicitHeight: carousel.height + shadowPad      // bottom padding only
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // padding is transparent, so don't let it eat clicks
    mask: Region {
    x: carouselWindow.shadowPad
    y: 0
    width: carousel.width
    height: carousel.height
}

    Theme { id: carouselTheme }

    RectangularGlow {
        anchors.fill: carousel
        glowRadius: 24
        spread: 0.1
        color: "#99000000"
        cornerRadius: carousel.radius + glowRadius
        opacity: carousel.opacity
        scale: 0.05 + 0.95 * carousel.opacity
        transformOrigin: Item.Top
    }

    WallpaperCarousel {
        id: carousel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8                         // was shadowPad
        palette: carouselTheme
        opacity: carouselWindow.open ? 1 : 0
        onCloseRequested: carouselWindow.closeRequested()
    }
}
