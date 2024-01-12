class PingLoggerMut extends Mutator;

var PlayerPawn PlayerOwner;
var ChallengeHUD HUD;
var PingLog Logger;
var float SavedTimeStamp;

event PostBeginPlay() {
    super.PostBeginPlay();
    Logger = Spawn(class'PingLog');
    Logger.StartLog();
}

function Tick(float Delta) {
    super.Tick(Delta);

    if (PlayerOwner.CurrentTimeStamp == SavedTimeStamp)
        return;

    SavedTimeStamp = PlayerOwner.CurrentTimeStamp;
    Logger.LogPing(Level.TimeSeconds, Level.TimeSeconds - SavedTimeStamp);
}

function RegisterHUDMutator() {
    local PlayerPawn P;

    foreach AllActors(class'PlayerPawn', P) {
        if (P.myHUD != none) {
            NextHUDMutator = P.myHud.HUDMutator;
            P.myHUD.HUDMutator = self;
            bHUDMutator = true;
            PlayerOwner = P;
            HUD = ChallengeHUD(P.myHUD);
            SetOwner(PlayerOwner);
        }
    }
}

function Destroyed() {
    Logger.StopLog();
    super.Destroyed();
}
