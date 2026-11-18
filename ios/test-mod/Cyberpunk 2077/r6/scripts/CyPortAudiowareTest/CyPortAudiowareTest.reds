// Audioware test for CyPort. Needs Audioware (+ Codeware) and r6/audioware/CyPortAudiowareTest.
//   main menu opens                 -> rising four-note tone (cyport_test_menu), through the one-argument script overload
//   3 s after a save finishes loading -> two beeps and a higher one (cyport_test_session), through the five-argument native directly
//   5 s after a save finishes loading -> Duration() of both sounds (no sound; the values are in the Audioware log on Apple builds)
// Every native call writes a line to red4ext/logs/audioware-*.log on Apple builds. Remove this folder and
// r6/audioware/CyPortAudiowareTest to uninstall.
module CyPortAudiowareTest
import Audioware.*
import Codeware.Localization.PlayerGender

public class CyPortAudiowareTestSession extends DelayCallback {
  public func Call() -> Void {
    let system = new AudioSystemExt();
    let noEntity: EntityID;
    let noSettings: ref<AudioSettingsExt>;
    system.Play(n"cyport_test_session", noEntity, n"None", scnDialogLineType.Regular, noSettings);
  }
}

public class CyPortAudiowareTestDuration extends DelayCallback {
  public func Call() -> Void {
    let system = new AudioSystemExt();
    FTLog(s"[CyPortAudiowareTest] Audioware \(system.Version()), durations \(system.Duration(n"cyport_test_menu")) s and \(system.Duration(n"cyport_test_session")) s");
  }
}

@wrapMethod(SingleplayerMenuGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  let system = new AudioSystemExt();
  system.Play(n"cyport_test_menu");
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result = wrappedMethod();
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(new CyPortAudiowareTestSession(), 3.0, false);
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(new CyPortAudiowareTestDuration(), 5.0, false);
  return result;
}
