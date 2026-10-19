import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

ToolStripActionList {
    id: _root

    signal displayPreFlightChecklist

    // MARS GCS: rover actions only. Takeoff / Land / PreFlight checklist /
    // Viewer3D / Gripper are flight specific and removed.
    model: [
        GuidedToolStripAction {
            text:       globals.guidedControllerFlyView.startMissionTitle
            message:    globals.guidedControllerFlyView.startMissionMessage
            actionID:   globals.guidedControllerFlyView.actionStartMission
            visible:    globals.guidedControllerFlyView.showStartMission
        },
        GuidedActionPause { },
        GuidedActionRTL { },
        FlyViewAdditionalActionsButton { }
    ]
}
