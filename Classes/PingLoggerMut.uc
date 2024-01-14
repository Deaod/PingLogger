class PingLoggerMut extends Mutator;

var PlayerPawn PlayerOwner;
var ChallengeHUD HUD;
var PingLog Logger;
var float SavedTimeStamp;
var bool bPauseState;
var bool bIGPlusInputReplication;
var vector Offset;

enum EOffsetSource {
    OSRC_436,
    OSRC_469,
    OSRC_IGPlus
};

var EOffsetSource OffsetSource;

simulated function Initialize() {
    local string FileName;
    Logger = Spawn(class'PingLog');

    if (PlayerOwner.IsA('bbPlayer') && PlayerOwner.GetPropertyText("IGPlus_AdjustLocationOffset") != "") {
        OffsetSource = OSRC_IGPlus;
        bIGPlusInputReplication = PlayerOwner.GetPropertyText("IGPlus_EnableInputReplication") ~= "True";
    } else if (PlayerOwner.GetPropertyText("AdjustLocationOffset") != "") {
        OffsetSource = OSRC_469;
    } else {
        OffsetSource = OSRC_436;
    }

    Logger.bUseOffset = (OffsetSource > OSRC_436);
    FileName = "Ping";
    FileName = FileName$"_"$SafeFileName(PlayerOwner.PlayerReplicationInfo.PlayerName);
    FileName = FileName$"_"$Level.Year$PadTo2Digits(Level.Month)$PadTo2Digits(Level.Day)$"_"$PadTo2Digits(Level.Hour)$PadTo2Digits(Level.Minute);
    FileName = FileName$"_"$Outer.Name; // this name is based on a valid file name
    FileName = FileName$"_"$SafeFileName(Level.GetAddressURL());
    Logger.FileName = FileName;
    Logger.StartLog();
}

simulated function Tick(float Delta) {
    local float AdjLocAlpha;

    super.Tick(Delta);

    if (Level.NetMode != NM_Client) {
        Disable('Tick');
        return;
    }

    if (PlayerOwner == none) {
        RegisterHUDMutator();
        return;
    }

    if (Logger == none)
        return;

    if (bPauseState != (Level.Pauser != "")) {
        if (bPauseState) {
            Logger.LogUnpause(Level.TimeSeconds);
        } else {
            Logger.LogPause(Level.TimeSeconds);
        }
    }
    bPauseState = (Level.Pauser != "");

    if (PlayerOwner.CurrentTimeStamp == SavedTimeStamp)
        return;

    SavedTimeStamp = PlayerOwner.CurrentTimeStamp;
    Offset = vect(0,0,0);

    switch (OffsetSource) {
        case OSRC_436:
            break;
        case OSRC_469:
            if (float(PlayerOwner.GetPropertyText("AdjustLocationAlpha")) > 0.0)
                SetPropertyText("Offset", PlayerOwner.GetPropertyText("AdjustLocationOffset"));
            break;
        case OSRC_IGPlus:
            AdjLocAlpha = float(PlayerOwner.GetPropertyText("IGPlus_AdjustLocationAlpha"));
            if (bIGPlusInputReplication || AdjLocAlpha > 0.0)
                SetPropertyText("Offset", PlayerOwner.GetPropertyText("IGPlus_AdjustLocationOffset"));
            if (AdjLocAlpha > 0.0)
                Offset *= AdjLocAlpha;
            break;
    }

    Logger.LogPing(Level.TimeSeconds, Level.TimeSeconds - SavedTimeStamp, VSize(Offset));

    if (PlayerOwner.GameReplicationInfo.GameEndedComments != "") {
        Logger.StopLog();
        Logger = none;
    }
}

simulated function RegisterHUDMutator() {
    local PlayerPawn P;

    foreach AllActors(class'PlayerPawn', P) {
        if (P.myHUD != none) {
            NextHUDMutator = P.myHud.HUDMutator;
            P.myHUD.HUDMutator = self;
            bHUDMutator = true;
            PlayerOwner = P;
            HUD = ChallengeHUD(P.myHUD);
            SetOwner(PlayerOwner);

            Initialize();
        }
    }
}

simulated function Destroyed() {
    if (Logger != none) {
        Logger.StopLog();
        Logger = none;
    }
    super.Destroyed();
}

final static function string PadTo2Digits(int A) {
    if (A < 10)
        return "0"$A;
    return string(A);
}

final static function string SafeFileName(string FileName) {
    FileName = Replace(FileName, ":", "_");
    FileName = Replace(FileName, ";", "_");
    FileName = Replace(FileName, "?", "");
    FileName = Replace(FileName, "/", "");
    FileName = Replace(FileName, "\\", "");
    FileName = Replace(FileName, "|", "");
    FileName = Replace(FileName, "*", "");
    FileName = Replace(FileName, "\"", "");
    FileName = Replace(FileName, "<", "");
    FileName = Replace(FileName, ">", "");
    FileName = Replace(FileName, " ", "_");

    return FileName;
}

final static function string Replace(string Haystack, string Needle, string Substitute) {
    local int Pos, NeedleLen;
    local string Result;

    NeedleLen = Len(Needle);
    Pos = InStr(Haystack, Needle);
    while(Pos >= 0) {
        Result = Result $ Left(Haystack, Pos) $ Substitute;

        Haystack = Mid(HayStack, Pos + NeedleLen);
        Pos = InStr(Haystack, Needle);
    }

    return Result $ Haystack;
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    bAlwaysTick=True
}
