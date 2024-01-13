class PingLog extends StatLogFile;

var bool bUseOffset;

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

    SetEncoding();
    OpenLog();

    // header
    if (bUseOffset)
        FileLog("timestamp,event,ping,offset");
    else
        FileLog("timestamp,event,ping");
}

// See Engine.StatLogFile
function SetEncoding() {
    local int EngineVersion;
    local string EngineRevision;

    EngineVersion = int(Level.EngineVersion);
    if (EngineVersion >= 469) {
        EngineRevision = Level.GetPropertyText("EngineRevision");
        EngineRevision = Left(EngineRevision, InStr(EngineRevision, " "));

        if (Len(EngineRevision) > 0 && EngineRevision != "a" && EngineRevision != "b") {
            SetPropertyText("Encoding", "FILE_ENCODING_UTF8");
        }
    }
}

function LogPing(
    float TimeStamp,
    float Ping,
    float Offset
) {
    local string LogStr;

    LogStr = string(TimeStamp) * "ping" * ((Ping * 1000.0) / Level.TimeDilation);
    if (bUseOffset)
        LogStr = LogStr * Offset;
    FileLog(LogStr);
}

function LogPause(float TimeStamp) {
    local string LogStr;

    LogStr = string(TimeStamp) * "pause,0.000000";
    if (bUseOffset)
        LogStr = LogStr * 0.0;

    FileLog(LogStr);
}

function LogUnpause(float TimeStamp) {
    local string LogStr;

    LogStr = string(TimeStamp) * "unpause,0.000000";
    if (bUseOffset)
        LogStr = LogStr * 0.0;

    FileLog(LogStr);
}

function LogEventString(string S) {
    FileLog(S);
}

defaultproperties {
    bWorld=False
}
