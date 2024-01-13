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
    Logger.StartLog();
}

simulated function Tick(float Delta) {
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
            if (bIGPlusInputReplication || float(PlayerOwner.GetPropertyText("IGPlus_AdjustLocationAlpha")) > 0.0)
                SetPropertyText("Offset", PlayerOwner.GetPropertyText("IGPlus_AdjustLocationOffset"));
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

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    bAlwaysTick=True
}
