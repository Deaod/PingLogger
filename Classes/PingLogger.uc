class PingLogger extends UMenuModMenuItem config(User);

var PingLoggerMut Mut;

function Execute() {
    if (MenuItem.Owner.Root.Console.ViewPort.Actor.Level.NetMode != NM_Client)
        return;

    if (Mut != none) {
        Mut.Destroy();
        Mut = none;
    }

    Mut = MenuItem.Owner.Root.Console.ViewPort.Actor.Spawn(class'PingLoggerMut');
    Mut.RegisterHUDMutator();

    MenuItem.bChecked = true;
}

function Tick(float Delta) {
    if (MenuItem.bChecked && Mut == none)
        MenuItem.bChecked = false;
}

defaultproperties
{
      MenuCaption="&PingLogger"
      MenuHelp=""
      MenuItem=None
}
