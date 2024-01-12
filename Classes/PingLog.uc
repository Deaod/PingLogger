class PingLog extends StatLogFile;

event BeginPlay() {
    // empty to override StatLog
}

static final operator(16) string *(coerce string A, coerce string B) {
    return A$","$B;
}

function string PadTo2Digits(int A) {
    if (A < 10)
        return "0"$A;
    return string(A);
}

function StartLog() {
    local string FileName;

    bWorld = false;
    FileName = "../Logs/Ping_"$Level.Year$PadTo2Digits(Level.Month)$PadTo2Digits(Level.Day)$"_"$PadTo2Digits(Level.Hour)$PadTo2Digits(Level.Minute);
    StatLogFile = FileName$".tmp.csv";
    StatLogFinal = FileName$".csv";

    OpenLog();

    // header
    FileLog("timestamp,ping");
}

function LogPing(
    float TimeStamp,
    float Ping
) {
    local string LogStr;
    LogStr = string(TimeStamp)*(Ping*1000.0);
    FileLog(LogStr);
}

function LogEventString(string S) {
    FileLog(S);
}

defaultproperties {
    bWorld=False
}
