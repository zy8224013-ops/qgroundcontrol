#pragma once

#include <QtQml/QQmlAbstractUrlInterceptor>

#include "QGCCorePlugin.h"
#include "QGCOptions.h"

class PlanCreator;

class CustomOptions;
class CustomPlugin;
class QQmlApplicationEngine;

Q_DECLARE_LOGGING_CATEGORY(CustomLog)

class CustomFlyViewOptions : public QGCFlyViewOptions
{
    Q_OBJECT

public:
    explicit CustomFlyViewOptions(CustomOptions *options, QObject *parent = nullptr);

    /// The rover telemetry bar replaces the regular instrument panel.
    bool showInstrumentPanel() const final { return false; }
    /// Single vehicle operation only. Simplifies various parts of the QGC ui.
    bool showMultiVehicleList() const final { return false; }
    /// Orbit is not applicable to rovers.
    bool guidedBarShowOrbit() const final { return false; }
    /// ROI is camera specific and not used on rovers.
    bool guidedBarShowROI() const final { return false; }
};

/*===========================================================================*/

class CustomOptions : public QGCOptions
{
    Q_OBJECT

public:
    explicit CustomOptions(CustomPlugin *plugin, QObject *parent = nullptr);

    // Overrides from QGCOptions

    /// Firmware upgrade page is only shown in Advanced Mode.
    bool showFirmwareUpgrade() const final { return _plugin->showAdvancedUI(); }
    QGCFlyViewOptions *flyViewOptions() const final { return _flyViewOptions; }

private:
    QGCCorePlugin *_plugin = nullptr;
    CustomFlyViewOptions *_flyViewOptions = nullptr;
};

/*===========================================================================*/

class CustomPlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    explicit CustomPlugin(QObject *parent = nullptr);

    static QGCCorePlugin *instance();

    // Overrides from QGCCorePlugin

    QGCOptions *options() final { return _options; }
    /// This allows you to override/hide QGC Application settings
    void adjustSettingMetaData(const QString &settingsGroup, FactMetaData &metaData, bool &userVisible) final;
    /// This modifies QGC colors palette to match custom branding
    void paletteOverride(const QString &colorName, QGCPalette::PaletteColorInfo_t &colorInfo) final;
    /// We override this so we can get access to QQmlApplicationEngine and use it to install the url interceptor
    QQmlApplicationEngine *createQmlApplicationEngine(QObject *parent) final;
    /// Releases the url interceptor attached in createQmlApplicationEngine before the engine is destroyed
    void destroyQmlApplicationEngine(QQmlApplicationEngine *qmlEngine) final;
    /// Rover plans: only the blank (waypoint) plan creator.
    QList<PlanCreator *> planCreators(PlanMasterController *planMasterController) final;
    /// Flight-specific complex items (survey etc.) are not offered on rovers.
    QVariantList complexMissionItemNames(Vehicle *vehicle) final;

private:
    CustomOptions *_options = nullptr;
    QQmlApplicationEngine *_qmlEngine = nullptr;
    class CustomOverrideInterceptor *_urlInterceptor = nullptr;
};

/*===========================================================================*/

class CustomOverrideInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    CustomOverrideInterceptor();

    QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) final;
};
