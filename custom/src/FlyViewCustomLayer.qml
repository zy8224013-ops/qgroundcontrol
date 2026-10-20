import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.FlyView

// MARS GCS rover fly view overlay:
//  - bottom telemetry bar (speed / heading / fix / satellites / battery / coordinates)
//  - RTK button (top right) opening a dedicated CORS/NTRIP quick setup popup
// The regular instrument panel is disabled via CustomFlyViewOptions.
Item {
    id: _root

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

    readonly property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    readonly property real _margins:       ScreenTools.defaultFontPixelWidth

    // MARS brand colors (Yaoyou seal: ink + seal red)
    readonly property color _brandRed:     "#B03A2E"
    readonly property color _brandInk:     "#14161A"
    readonly property color _fixGreen:     "#27BF89"
    readonly property color _fixAmber:     "#E67E22"

    QGCToolInsets {
        id: _toolInsets

        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    parentToolInsets.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset + _bottomReserve
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset + _bottomReserve
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset + _bottomReserve
    }

    readonly property real _bottomReserve: telemetryBar.height + telemetryBar.anchors.margins * 2

    function _lockText() {
        if (!_activeVehicle) return qsTr("未连接")
        var lockString = _activeVehicle.gps.lock.enumStringValue
        if (lockString.indexOf("RTK Fixed") >= 0) return qsTr("RTK 固定解")
        if (lockString.indexOf("RTK Float") >= 0) return qsTr("RTK 浮点解")
        if (lockString.indexOf("Single")    >= 0) return qsTr("单点定位")
        return lockString
    }

    function _lockColor() {
        if (!_activeVehicle) return "#9AA0A6"
        var lockString = _activeVehicle.gps.lock.enumStringValue
        if (lockString.indexOf("RTK Fixed") >= 0) return _fixGreen
        if (lockString.indexOf("RTK Float") >= 0) return _fixAmber
        return "#F5F1E8"
    }

    function _speedText() {
        if (!_activeVehicle) return "--"
        return (_activeVehicle.groundSpeed.rawValue * 3.6).toFixed(1) + " km/h"
    }

    function _headingText() {
        if (!_activeVehicle) return "--"
        var headingValue = Math.round(_activeVehicle.heading.rawValue)
        return isNaN(headingValue) ? "--" : headingValue + "°"
    }

    function _satelliteText() {
        if (!_activeVehicle) return "--"
        return _activeVehicle.gps.count.valueString + qsTr(" 颗")
    }

    function _voltageText() {
        if (!_activeVehicle || _activeVehicle.batteries.count === 0) return "--"
        var voltage = _activeVehicle.batteries.get(0).voltage.rawValue
        return isNaN(voltage) ? "--" : voltage.toFixed(1) + " V"
    }

    function _coordinateText() {
        if (!_activeVehicle) return "--"
        var coordinate = _activeVehicle.coordinate
        if (isNaN(coordinate.latitude) || isNaN(coordinate.longitude)) return "--"
        return coordinate.latitude.toFixed(6) + ", " + coordinate.longitude.toFixed(6)
    }

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: true
    }

    component TelemetryValue: Column {
        property string label
        property string value
        property color  valueColor: "#F5F1E8"
        property bool   smallValue: false

        spacing: _margins / 4

        QGCLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: label
            color: "#B9AFA2"
            font.pointSize: ScreenTools.smallFontPointSize
        }

        QGCLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: value
            color: valueColor
            font.pointSize: smallValue ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize
            font.bold: !smallValue
        }
    }

    // RTK quick setup button (top right)
    Rectangle {
        id: rtkButton

        anchors.top:    parent.top
        anchors.right:  parent.right
        anchors.margins: _margins * 2

        width:  ScreenTools.defaultFontPixelHeight * 3.4
        height: width
        radius: width / 2
        color:  _activeVehicle && _activeVehicle.gps.lock.enumStringValue.indexOf("RTK") >= 0 ? _fixGreen : _brandRed
        border.color: "#F5F1E8"
        border.width: 2

        QGCLabel {
            anchors.centerIn: parent
            text: "RTK"
            color: "#FFFFFF"
            font.bold: true
            font.pointSize: ScreenTools.defaultFontPointSize
        }

        QGCMouseArea {
            anchors.fill: parent
            onClicked: rtkPopup.open()
        }
    }

    // RTK / CORS quick setup popup
    Popup {
        id: rtkPopup

        modal: true
        focus:  true
        x:      (parent.width - width) / 2
        y:      (parent.height - height) / 2
        width:  parent.width * 0.55
        padding: _margins * 2
        background: Rectangle {
            radius: _margins
            color:  _brandInk
            border.color: _brandRed
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: _margins

            QGCLabel {
                text: qsTr("RTK / CORS 网络设置")
                color: "#F5F1E8"
                font.pointSize: ScreenTools.largeFontPointSize
                font.bold: true
            }

            FactCheckBox {
                fact: QGroundControl.settingsManager.ntripSettings.ntripServerConnectEnabled
                text: qsTr("启用 NTRIP 网络 CORS 接入")
            }

            GridLayout {
                columns: 2
                columnSpacing: _margins * 2
                rowSpacing: _margins

                QGCLabel { text: qsTr("服务器地址"); color: "#F5F1E8" }
                FactTextField {
                    Layout.fillWidth: true
                    fact: QGroundControl.settingsManager.ntripSettings.ntripServerHostAddress
                }

                QGCLabel { text: qsTr("端口"); color: "#F5F1E8" }
                FactTextField {
                    Layout.fillWidth: true
                    fact: QGroundControl.settingsManager.ntripSettings.ntripServerPort
                }

                QGCLabel { text: qsTr("挂载点"); color: "#F5F1E8" }
                FactTextField {
                    Layout.fillWidth: true
                    fact: QGroundControl.settingsManager.ntripSettings.ntripMountpoint
                }

                QGCLabel { text: qsTr("用户名"); color: "#F5F1E8" }
                FactTextField {
                    Layout.fillWidth: true
                    fact: QGroundControl.settingsManager.ntripSettings.ntripUsername
                }

                QGCLabel { text: qsTr("密码"); color: "#F5F1E8" }
                FactTextField {
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    fact: QGroundControl.settingsManager.ntripSettings.ntripPassword
                }
            }

            QGCLabel {
                Layout.fillWidth: true
                text: qsTr("提示：千寻等 CORS 服务端口通常为 8002（RTCM3），账号密码由服务商提供。开启后保持数传在线即可自动接入。")
                color: "#B9AFA2"
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode: QGCLabel.WordWrap
            }

            QGCButton {
                Layout.alignment: Qt.AlignRight
                text: qsTr("关闭")
                onClicked: rtkPopup.close()
            }
        }
    }

    Rectangle {
        id: telemetryBar

        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.margins:            _margins * 1.5

        width:  telemetryRow.implicitWidth + _margins * 5
        height: telemetryRow.implicitHeight + _margins * 1.8
        radius: height / 2
        color:  "#E614161A"
        border.width: 1
        border.color: "#4A4E55"

        // brand accent line
        Rectangle {
            anchors.top:    parent.top
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.margins: _margins / 2
            height: 2
            radius: 1
            color: _brandRed
        }

        Row {
            id: telemetryRow

            anchors.centerIn: parent
            spacing: _margins * 2.5

            TelemetryValue { label: qsTr("速度"); value: _speedText() }
            TelemetryValue { label: qsTr("航向"); value: _headingText() }
            TelemetryValue { label: qsTr("定位"); value: _lockText(); valueColor: _lockColor() }
            TelemetryValue { label: qsTr("卫星"); value: _satelliteText() }
            TelemetryValue { label: qsTr("电池"); value: _voltageText() }
            TelemetryValue { label: qsTr("坐标"); value: _coordinateText(); smallValue: true }
        }
    }
}
