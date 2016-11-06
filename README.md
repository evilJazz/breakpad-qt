# breakpad-qt
An alternative implementation of Breakpad for Qt applications specificly geared towards usage on Linux servers.

This implementation is loosely based https://github.com/JPNaude/dev_notes/wiki/Using-Google-Breakpad-with-Qt

Notable changes:
- Introduces support for calling a custom handler on crash.
- Includes helper scripts for easier usage on servers by not requiring the intricacies of dumping and storing symbols before deployment.
  Instead it supports on-the-fly crash report creation. Note: this requires your server app to be build with debug symbols - something only suitable for usage on servers that you actually trust and/or control.

Usage

Call ./bootstrap.sh

Add in your .pro file:

    include($$PWD/breakpad-qt/crashhandler.pri)

Add to your main() entrypoint:

    QString crashOutputDirectory = "<YOUR CRASH OUTPUT DIRECTORY HERE>";
    QString breakPadGenerateReport = qApp->applicationDirPath() + "/breakpad/breakpad_generate_report.sh";
    Breakpad::CrashHandler::instance()->init(
        crashOutputDirectory,
        QString("\"%1\" -u \"%2\" -b \"%3\"") // Add additional params here if needed. Check breakpad_generate_report.sh for syntax.
            .arg(breakPadGenerateReport)
            .arg(<YOUR breakpad.php SERVER URL HERE>)
            .arg(qApp->applicationFilePath())
    );

