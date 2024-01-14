class PingLog extends StatLogFile;

var bool bUseOffset;
var string FileName;

event BeginPlay() {
    // empty to override StatLog
}

static final operator(16) string *(coerce string A, coerce string B) {
    return A$","$B;
}

function StartLog() {
    local string FilePath;

    bWorld = false;
    FilePath = "../Logs/"$FileName;
    StatLogFile = FilePath$".tmp.csv";
    StatLogFinal = FilePath$".csv";

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
            SetPropertyText("Encoding", "FILE_ENCODING_UTF8_BOM");
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
