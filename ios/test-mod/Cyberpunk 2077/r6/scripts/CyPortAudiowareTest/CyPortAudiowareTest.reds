// Audioware test for CyPort. Needs Audioware (+ Codeware) and r6/audioware/CyPortAudiowareTest.
//   main menu opens                 -> rising four-note tone (cyport_test_menu), twice: first through a script class that forwards
//                                      its parameter to the native, then through the plugin's one-argument overload
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

// A script function of a script class that forwards its own parameter to the five-argument native (what the one-argument
// overload of AudioSystemExt does, but outside the plugin's class).
public class CyPortAudiowareTestForward {
  public static func Play(name: CName) -> Void {
    let system = new AudioSystemExt();
    let noEntity: EntityID;
    let noSettings: ref<AudioSettingsExt>;
    system.Play(name, noEntity, n"None", scnDialogLineType.Regular, noSettings);
  }
}

@wrapMethod(SingleplayerMenuGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  // 1st Play line in the log: parameter forwarded by a script class. 2nd: the plugin's one-argument overload.
  CyPortAudiowareTestForward.Play(n"cyport_test_menu");
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
