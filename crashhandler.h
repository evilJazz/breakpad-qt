#ifndef CRASHHANDLER_H
#define CRASHHANDLER_H

#pragma once

#include <QString>
#include <QStringList>

namespace Breakpad
{

class CrashHandlerPrivate;
class CrashHandler
{
public:
    static CrashHandler *instance();
    void init(const QString &reportPath, const QString programToLaunch = QString());

    void setReportCrashToSystem(bool report);
    bool writeMinidump();

    void deinit();

private:
    CrashHandler();
    ~CrashHandler();
    Q_DISABLE_COPY(CrashHandler)
    CrashHandlerPrivate *d_;
};

}

#endif // CRASHHANDLER_H
