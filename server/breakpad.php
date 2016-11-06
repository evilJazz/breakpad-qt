<?php

define("BREAKPAD_SERVER_DIR", dirname($_SERVER['SCRIPT_FILENAME']) . DIRECTORY_SEPARATOR);
define("CONFIG_FILE", BREAKPAD_SERVER_DIR . "breakpad.php.inc");

if (file_exists(CONFIG_FILE))
    include(CONFIG_FILE);

if (!defined("MAIL_FROM_ADDRESS") || !defined("MAIL_FROM_NAME") || empty($MAIL_RECIPIENTS))
{
    echo nl2br("Please create breakpad.php.inc file and add:
define('MAIL_FROM_ADDRESS', 'crash@some.server.net');
define('MAIL_FROM_NAME', 'App Crash Reporter');
\$MAIL_RECIPIENTS = array('some.recipient@some.server.net');

Optionally define these variables if you want to support uploading of symbols from your deployment process and want to accept minidump files from clients.

define('MINIDUMP_STACKWALK', '/opt/symbols/minidump_stackwalk');
define('SYMBOLS_POOL', '/opt/symbols/pool');
");
    exit;
}

define('SUPPORT_SYMBOL_UPLOAD', defined("MINIDUMP_STACKWALK") && defined("SYMBOLS_POOL"));

# Check dependencies
if (SUPPORT_SYMBOL_UPLOAD)
{
    foreach (array(MINIDUMP_STACKWALK, SYMBOLS_POOL) as $file)
    {
        if (!file_exists($file))
        {
            echo $file . ' does not exist!';
            exit;
        }

        if (!is_executable($file))
        {
            echo $file . ' does not exist!';
            exit;
        }
    }

    if (!is_dir(SYMBOLS_POOL))
    {
        echo SYMBOLS_POOL . ' is not a directory!';
        exit;
    }

    if (!is_writable(SYMBOLS_POOL))
    {
        echo SYMBOLS_POOL . ' is not writable!';
        exit;
    }
}

function sendMailWithAttachments($files, $mailTo, $fromMail, $fromName, $subject, $message)
{
    $uid = "------------" . md5(uniqid(time()));

    $header = "From: " . $fromName . " <" . $fromMail . ">\r\n";
    $header .= "X-Mailer: PHP/" . phpversion() . "\r\n";
    $header .= "MIME-Version: 1.0\r\n";
    $header .= "Content-Type: multipart/mixed; boundary=\"" . $uid . "\"\r\n";

    $content = "This is a multi-part message in MIME format.\r\n";
    $content .= "--" . $uid . "\r\n";
    $content .= "Content-Type: text/plain; charset=ISO-8859-1\r\n";
    $content .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
    $content .= $message . "\r\n\r\n";

    foreach ($files as $file)
    {
        $attachmentName = basename($file["name"]);

        if (isset($file["contentFileName"]))
            $attachmentContent = chunk_split(base64_encode(file_get_contents($file["contentFileName"])));
        else if (isset($file["content"]))
            $attachmentContent = chunk_split(base64_encode($file["content"]));
        else
            continue;

        $content .= "--" . $uid . "\r\n";
        $content .= "Content-Type: application/octet-stream; name=\"" . $attachmentName . "\"\r\n"; // use different content types here
        $content .= "Content-Transfer-Encoding: base64\r\n";
        $content .= "Content-Disposition: attachment; filename=\"" . $attachmentName . "\"\r\n\r\n";
        $content .= $attachmentContent . "\r\n\r\n";
    }

    $content .= "--" . $uid . "--\r\n";

    if (is_array($mailTo))
        $mailTo = implode(", ", $mailTo);

    return mail($mailTo, $subject, $content, $header);
}

function sendCrashMail($files)
{
    global $MAIL_RECIPIENTS;

    $hostName = filter_var($_POST['host'], FILTER_SANITIZE_STRING);
    $productName = filter_var($_POST['prod'], FILTER_SANITIZE_STRING);
    $productVersion = filter_var($_POST['ver'], FILTER_SANITIZE_STRING);

    # E-Mail result
    $mailSent = sendMailWithAttachments(
        $files,
        $MAIL_RECIPIENTS,
        MAIL_FROM_ADDRESS,
        MAIL_FROM_NAME,
        'New crash report from ' . $hostName,
        'Hello, we received a new crash report!

Hostname: ' . $hostName . '
Software name: ' . $productName . '
Software version: '. $productVersion . '

Files are attached.'
    );

    if (!$mailSent)
        error_log ('Could not send stackwalk mail to ' . json_encode(MAIL_RECIPIENTS));

    return $mailSent;
}

# Main program
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_FILES))
{
    if (SUPPORT_SYMBOL_UPLOAD && !empty($_FILES['upload_file_minidump'])) # Do we have a minidump?
    {
        $minidumpArray = $_FILES['upload_file_minidump'];

        # Check for upload errors
        if ($minidumpArray['error'] !== UPLOAD_ERR_OK)
        {
            error_log('Error while uploading minidump file: ' . print_r($minidumpArray, true));
            exit;
        }

        $stackwalkOutputArray = array();
        $stackwalkReturn = 0;
        $stackwalkCommand = MINIDUMP_STACKWALK . ' -s ' . $minidumpArray['tmp_name'] . ' ' . SYMBOLS_POOL;
        exec($stackwalkCommand, $stackwalkOutputArray, $stackwalkReturn);

        if ($stackwalkReturn != 0)
            error_log('Error while running ' . $stackwalkCommand . ': ' . $stackwalkReturn);

        $stackwalkOutput = implode("\n", $stackwalkOutputArray);

        sendCrashMail(
            array(
                array("name" => "stacktrace.log", "content" => $stackwalkOutput)
            )
        );
    }
    else if (!empty($_FILES['upload_file_crashreport'])) # Do we have a completely processed crash report?
    {
        $crashReportArray = $_FILES['upload_file_crashreport'];

        # Check for upload errors
        if ($crashReportArray['error'] !== UPLOAD_ERR_OK)
        {
            echo 'Error while uploading crashreport file: ' . print_r($crashReportArray, true);
            exit;
        }

        $logArray = $_FILES['upload_file_log'];

        # Check for upload errors
        if ($logArray['error'] !== UPLOAD_ERR_OK)
        {
            echo 'Error while uploading log file: ' . print_r($logArray, true);
            exit;
        }

        sendCrashMail(
            array(
                array("name" => "stacktrace.log", "contentFileName" => $crashReportArray["tmp_name"]),
                array("name" => "logfile.log", "contentFileName" => $logArray["tmp_name"])
            )
        );
    }
    else if (SUPPORT_SYMBOL_UPLOAD) # Perhaps a symbol file
    {
        foreach (array_keys($_FILES) as $fileKey)
        {
            $symbolFileArray = $_FILES[$fileKey];

            # Check for upload errors
            if ($symbolFileArray['error'] !== UPLOAD_ERR_OK)
            {
                error_log('Error while uploading symbol file: ' . print_r($symbolFileArray, true));
                continue;
            }

            $symbolFileName = $_FILES[$fileKey]['name'];
            $symbolTmpFileName = $_FILES[$fileKey]['tmp_name'];

            $firstLineArray = explode(' ', rtrim(fgets(fopen($symbolTmpFileName, 'r'))));
            $moduleID = $firstLineArray[3];
            $moduleName = $firstLineArray[4];

            if (empty($moduleID) || empty($moduleName))
            {
                error_log('Invalid contents in file ' . $symbolFileName);
                continue;
            }

            $symbolDestDir = SYMBOLS_POOL . DIRECTORY_SEPARATOR . $moduleName . DIRECTORY_SEPARATOR . $moduleID;
            $symbolDestFileName = $symbolDestDir . DIRECTORY_SEPARATOR . $moduleName . '.sym';

            if (!file_exists($symbolDestDir))
            {
                $createdDirectory = mkdir($symbolDestDir, 0755, true);

                if (!$createdDirectory)
                {
                    error_log('Could not create directory ' . $symbolDestDir);
                    continue;
                }
            }

            $moved = move_uploaded_file($symbolTmpFileName, $symbolDestFileName);

            if (!$moved)
            {
                error_log('Could not move file ' . $symbolTmpFileName . ' to ' . $symbolDestFileName);
                continue;
            }
        }
    }
}
