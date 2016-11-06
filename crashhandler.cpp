#include "crashhandler.h"

#include <QApplication>
#include <cstdio>
#include "KCL/logging.h"

#if defined(Q_OS_LINUX)
#include "src/client/linux/handler/exception_handler.h"
#elif defined(Q_OS_WIN32)
#include "src/client/windows/handler/exception_handler.h"
#endif

namespace Breakpad
{

class CrashHandlerPrivate
{
public:
    CrashHandlerPrivate()
    {
        handler_ = NULL;
    }

    ~CrashHandlerPrivate()
    {
        delete handler_;
    }

    void initCrashHandler(const QString &dumpPath);
    void deinitCrashHandler();
    static google_breakpad::ExceptionHandler *handler_;
    static bool reportCrashesToSystem_;

    static QByteArray programToLaunch_;
    static char cmdline_[4096];
};

google_breakpad::ExceptionHandler *CrashHandlerPrivate::handler_ = NULL;
bool CrashHandlerPrivate::reportCrashesToSystem_ = false;
QByteArray CrashHandlerPrivate::programToLaunch_ = QByteArray();
char CrashHandlerPrivate::cmdline_[4096] = "";

#if defined(Q_OS_WIN32)
bool dumpCallback(const wchar_t *dumpDir, const wchar_t *minidumpId, void *context, EXCEPTION_POINTERS *exInfo, MDRawAssertionInfo *assertion, bool success)
#elif defined(Q_OS_LINUX)
bool dumpCallback(const google_breakpad::MinidumpDescriptor &md, void *context, bool success)
#endif
{
    Q_UNUSED(context)
#if defined(Q_OS_WIN32)
    Q_UNUSED(dumpDir)
    Q_UNUSED(minidumpId)
    Q_UNUSED(assertion)
    Q_UNUSED(exInfo)
#endif

    qDebug("BreakpadQt is handling a crash...");

    if (!CrashHandlerPrivate::programToLaunch_.isEmpty())
    {
        qDebug("BreakpadQt is starting external program...");
        snprintf(CrashHandlerPrivate::cmdline_, 4096, "%s \"%s\"", CrashHandlerPrivate::programToLaunch_.constData(), md.path());
        system(CrashHandlerPrivate::cmdline_);
    }

    return CrashHandlerPrivate::reportCrashesToSystem_ ? success : true;
}

void CrashHandlerPrivate::initCrashHandler(const QString &dumpPath)
{
    if (handler_ != NULL)
        return;

#if defined(Q_OS_WIN32)
    std::wstring path = (const wchar_t *) dumpPath.utf16();

    handler_ = new google_breakpad::ExceptionHandler(path, /* FilterCallback */ NULL, dumpCallback, /* context */ NULL, true);
#elif defined(Q_OS_LINUX)
    std::string path = dumpPath.toStdString();

    google_breakpad::MinidumpDescriptor md(path);

    handler_ = new google_breakpad::ExceptionHandler(md, /* FilterCallback */ NULL, dumpCallback, /* context */ NULL, true, -1);
#endif
}

void CrashHandlerPrivate::deinitCrashHandler()
{
    if (handler_)
    {
        delete handler_;
        handler_ = NULL;
    }
}

CrashHandler *CrashHandler::instance()
{
    static CrashHandler globalHandler;

    return &globalHandler;
}

CrashHandler::CrashHandler()
{
    d_ = new CrashHandlerPrivate();
}

CrashHandler::~CrashHandler()
{
    delete d_;
}

void CrashHandler::setReportCrashToSystem(bool report)
{
    d_->reportCrashesToSystem_ = report;
}

bool CrashHandler::writeMinidump()
{
    bool result = d_->handler_->WriteMinidump();

    if (result)
    {
        qDebug("BreakpadQt: writeMinidump() success.");
    }
    else
    {
        qWarning("BreakpadQt: writeMinidump() failed.");
    }

    return result;
}

void CrashHandler::init(const QString &reportPath, const QString programToLaunch)
{
    d_->initCrashHandler(reportPath);

    CrashHandlerPrivate::programToLaunch_ = programToLaunch.toUtf8();
}

void CrashHandler::deinit()
{
    d_->deinitCrashHandler();
}

}
