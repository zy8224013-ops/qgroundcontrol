# MARS GCS Custom Build

ArduPilot Rover 定制版 QGroundControl（无人车简化地面站）。

## 与官方 custom-example 的差异

- **剔除 PX4 专用件**：不包含 `CustomAutoPilotPlugin`（继承 PX4AutoPilotPlugin）与
  `CustomFirmwarePlugin/Factory`（PX4CustomMode 硬编码），不设置
  `QGC_DISABLE_APM_PLUGIN_FACTORY` / `QGC_DISABLE_PX4_PLUGIN_FACTORY` ——
  ArduPilot 支持必须保留。
- **离线规划默认**：固件 ArduPilot、载具 Rover（`adjustSettingMetaData` 锁定并隐藏选项）。
- **一级主页面（Fly View）**：
  - 关闭仪表板（姿态仪）与多载具列表（`CustomFlyViewOptions`）；
  - `FlyViewCustomLayer.qml` 重写为底部遥测条：速度/航向/定位(RTK)/卫星/电池/坐标；
  - `FlyViewToolStripActionList.qml` 只保留：开始任务、暂停、返航(RTL)、更多（溢出菜单）；
    去掉起飞、降落、飞行前检查、Viewer3D、夹爪。
  - 关闭 Orbit/ROI 引导（无人车不适用）。
- **二级界面（Plan View）**：`planCreators()` 只保留空白任务（航点编辑），
  Survey/CorridorScan/StructureScan 不再提供；`complexMissionItemNames` 未覆写但创建入口已收窄。
- **包名/应用名**：`com.yaoyou.marsgcs` / `MARS GCS`（cmake/CustomOverrides.cmake），
  与官方 QGroundControl 同机共存。
- 未包含 PerimeterScan 示例任务项及其资源。

## 编译

官方 CI（android.yml，workflow_dispatch，arm64-v8a）或本地：
`cmake -DQGC_CUSTOM_DIR=custom ...`（目录名 `custom` 为默认检测值，无需显式传参）。
