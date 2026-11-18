// Audioware test for CyPort. Needs Audioware (+ Codeware) and r6/audioware/CyPortAudiowareTest.
//   main menu opens      -> rising four-note tone  (cyport_test_menu)
//   a save finishes loading (player attached) -> two beeps and a higher one, 3 s later (cyport_test_session)
// Each step also writes a line to the game log channel DEBUG. Remove this folder and r6/audioware/CyPortAudiowareTest to uninstall.
module CyPortAudiowareTest
import Audioware.*
import Codeware.Localization.PlayerGender

public class CyPortAudiowareTestDelay extends DelayCallback {
  public func Call() -> Void {
    let system = new AudioSystemExt();
    FTLog(s"[CyPortAudiowareTest] session tone, Audioware \(system.Version()), duration \(system.Duration(n"cyport_test_session")) s");
    system.Play(n"cyport_test_session");
  }
}

@wrapMethod(SingleplayerMenuGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  let system = new AudioSystemExt();
  FTLog(s"[CyPortAudiowareTest] menu tone, Audioware \(system.Version()), duration \(system.Duration(n"cyport_test_menu")) s");
  system.Play(n"cyport_test_menu");
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result = wrappedMethod();
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(new CyPortAudiowareTestDelay(), 3.0, false);
  return result;
}
