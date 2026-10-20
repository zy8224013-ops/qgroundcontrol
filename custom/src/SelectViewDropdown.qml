import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// MARS GCS view selection menu (overrides stock SelectViewDropdown).
// Ink & seal-red brand style with rover-themed custom icons.
ColumnLayout {
    id: _root

    spacing: ScreenTools.defaultFontPixelWidth

    readonly property color _ink:   "#23262B"
    readonly property color _red:   "#B03A2E"
    readonly property real _tile:   ScreenTools.defaultFontPixelHeight * 2.2
    readonly property real _m:      ScreenTools.defaultFontPixelWidth

    component MenuRow: Rectangle {
        id: menuRow

        property string label
        property string iconRes
        property var    onActivate: null

        width:  rowContent.implicitWidth + _m * 6
        height: _tile + _m * 2
        radius: 10
        color:  ma.pressed ? "#f0e3de" : "#FFFFFF"
        border.color: "#E0D6CC"
        border.width: 1

        Row {
            id: rowContent

            anchors.centerIn: parent
            spacing: _m * 1.5

            Rectangle {
                width: _tile
                height: _tile
                radius: 8
                color: "#FFFFFF"
                border.color: _red
                border.width: 2

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: iconRes
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
            }

            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: label
                color: _ink
                font.bold: true
                font.pointSize: ScreenTools.defaultFontPointSize
            }
        }

        QGCMouseArea {
            anchors.fill: parent
            onClicked: {
                if (onActivate) {
                    onActivate()
                }
            }
        }
    }

    MenuRow {
        label: qsTr("飞行")
        iconRes: "/Custom/res/menu_rover.svg"
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.showFlyView() }
    }
    MenuRow {
        label: qsTr("规划")
        iconRes: "/Custom/res/menu_route.svg"
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.showPlanView() }
    }
    MenuRow {
        label: qsTr("分析")
        iconRes: "/Custom/res/menu_analyze.svg"
        visible: QGroundControl.corePlugin.showAdvancedUI
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.showAnalyzeTool() }
    }
    MenuRow {
        label: qsTr("配置")
        iconRes: "/Custom/res/menu_gear.svg"
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.showVehicleConfig() }
    }
    MenuRow {
        label: qsTr("设置")
        iconRes: "/Custom/res/menu_sliders.svg"
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.showSettingsTool() }
    }
    MenuRow {
        label: qsTr("关闭")
        iconRes: "/Custom/res/menu_power.svg"
        onActivate: () => { mainWindow.closeIndicatorDrawer(); mainWindow.close() }
    }

    QGCLabel {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("%1 版本").arg(QGroundControl.appName)
        color: "#808080"
        font.pointSize: ScreenTools.smallFontPointSize
    }

    QGCLabel {
        Layout.alignment: Qt.AlignHCenter
        text: QGroundControl.qgcVersion
        color: "#808080"
        font.pointSize: ScreenTools.smallFontPointSize
    }

    Item { Layout.fillHeight: true }
}
