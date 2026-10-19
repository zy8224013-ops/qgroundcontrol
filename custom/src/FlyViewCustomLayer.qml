import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

// MARS GCS rover fly view overlay:
// bottom telemetry bar (speed / heading / position fix / satellites / battery / coordinates).
// The regular instrument panel is disabled via CustomFlyViewOptions.
Item {
    id: _root

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

    readonly property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    readonly property real _margins:       ScreenTools.defaultFontPixelWidth

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
        property bool   smallValue: false

        spacing: _margins / 4

        QGCLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: label
            color: qgcPal.text
            font.pointSize: ScreenTools.smallFontPointSize
        }

        QGCLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: value
            color: qgcPal.text
            font.pointSize: smallValue ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize
            font.bold: !smallValue
        }
    }

    Rectangle {
        id: telemetryBar

        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.margins:            _margins * 1.5

        width:  telemetryRow.implicitWidth + _margins * 5
        height: telemetryRow.implicitHeight + _margins * 1.5
        radius: height / 2
        color:  qgcPal.window
        opacity: 0.92
        border.width: 1
        border.color: qgcPal.mapWidgetBorderLight

        Row {
            id: telemetryRow

            anchors.centerIn: parent
            spacing: _margins * 2.5

            TelemetryValue { label: qsTr("速度"); value: _speedText() }
            TelemetryValue { label: qsTr("航向"); value: _headingText() }
            TelemetryValue { label: qsTr("定位"); value: _lockText() }
            TelemetryValue { label: qsTr("卫星"); value: _satelliteText() }
            TelemetryValue { label: qsTr("电池"); value: _voltageText() }
            TelemetryValue { label: qsTr("坐标"); value: _coordinateText(); smallValue: true }
        }
    }
}
