class PingLogger extends UMenuModMenuItem config(User);

var PingLoggerMut Mut;

function Execute() {
    if (Mut != none) {
        Log("Destroy Mut", 'PingLogger');
        Mut.Destroy();
        Mut = none;

        MenuItem.bChecked = false;
    } else {
        Log("Create Mut", 'PingLogger');
        Mut = MenuItem.Owner.Root.Console.ViewPort.Actor.Spawn(class'PingLoggerMut');
        Mut.RegisterHUDMutator();

        MenuItem.bChecked = true;
    }
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
