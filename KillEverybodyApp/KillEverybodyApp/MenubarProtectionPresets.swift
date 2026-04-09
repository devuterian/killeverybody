import Foundation

/// LSUIElement가 아니어도 메뉴 막대 도구로 흔한 앱의 번들 ID. 오탐 시 사용자가 목록을 조정하거나 이 프리셋을 코드에서 수정합니다.
enum MenubarProtectionPresets {
    static let bundleIDs: Set<String> = [
        "com.surteesstudios.Bartender",
        "net.matthewpalmer.Vanilla",
        "com.dwarvesv.minimalbar",
        "com.bjango.istatmenus",
        "com.bjango.istatmenus-sensors",
        "eu.exelban.Stats",
        "com.apphousekitchen.aldente-pro",
        "com.apphousekitchen.aldente",
        "com.charliemonroe.Dato",
        "com.charliemonroe.MuteKey",
        "com.stclairsoft.AppTamer",
        "com.tracesOf.Uebersicht",
    ]
}
