import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case korean = "ko"
    case english = "en"
    case japanese = "ja"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        case .japanese: return "日本語"
        }
    }

    private var localeIdentifier: String {
        switch self {
        case .korean: return "ko_KR"
        case .english: return "en_US"
        case .japanese: return "ja_JP"
        }
    }

    func text(_ key: AppText) -> String {
        switch self {
        case .korean: return AppTranslations.korean[key] ?? key.rawValue
        case .english: return key.rawValue
        case .japanese: return AppTranslations.japanese[key] ?? key.rawValue
        }
    }

    func format(_ key: AppText, _ arguments: CVarArg...) -> String {
        format(key, arguments: arguments)
    }

    func format(_ key: AppText, arguments: [CVarArg]) -> String {
        String(
            format: text(key),
            locale: Locale(identifier: localeIdentifier),
            arguments: arguments
        )
    }
}

enum AppListSortOrder: String, CaseIterable, Identifiable {
    case protectedFirst
    case unprotectedFirst
    case name

    var id: String { rawValue }

    var titleKey: AppText {
        switch self {
        case .protectedFirst: return .sortProtectedFirst
        case .unprotectedFirst: return .sortUnprotectedFirst
        case .name: return .sortName
        }
    }
}

enum AppText: String {
    case exceptionsTab = "Exceptions"
    case advancedTab = "Advanced"
    case allApps = "All Apps"
    case running = "Running"
    case loginItems = "Open at Login"
    case appsToSpare = "Apps to Spare"
    case protectedCount = "%d protected"
    case sort = "Sort"
    case sortProtectedFirst = "Protected First"
    case sortUnprotectedFirst = "Unprotected First"
    case sortName = "Name"
    case loadingApps = "Loading apps…"
    case noApps = "No apps"
    case noSearchResults = "No results"
    case chooseAnotherList = "Choose another list."
    case tryAnotherSearch = "Try another app name, bundle ID, or path."
    case searchPrompt = "App name, bundle ID, or path"
    case loginBadge = "Login"
    case quitting = "Force quitting…"
    case forceQuitThisApp = "Force Quit This App"
    case forceQuitFailed = "Couldn’t Force Quit"
    case forceQuitFailureDetail = "%@ still has %d process failures and %d relaunch-prevention failures."
    case language = "Language"
    case languageHint = "Changes apply immediately."
    case addBundleID = "Add Bundle ID"
    case bundleIDExample = "Example: com.apple.Safari"
    case addToExceptions = "Add to Exceptions"
    case menubarBundles = "Apps Treated as Menu Bar Apps"
    case menubarHint = "Use this to protect an app like a menu bar utility even when it isn’t an LSUIElement app."
    case bundleID = "Bundle ID"
    case add = "Add"
    case policyFile = "Policy File"
    case exportPolicy = "Export Policy…"
    case importPolicy = "Import Policy…"
    case ok = "OK"
    case saved = "Saved"
    case saveFailed = "Couldn’t Save"
    case exportFailed = "Couldn’t Export"
    case newerPolicy = "This policy file is from a newer version."
    case updateThenRetry = "Update the app, then try again."
    case overwritePolicy = "Overwrite the current policy?"
    case overwritePolicyDetail = "Your current exceptions will be replaced by the JSON file."
    case cancel = "Cancel"
    case overwrite = "Overwrite"
    case readFailed = "Couldn’t Read File"
    case mainPrompt = "Kill everybody?"
    case killEverybody = "Kill Everybody"
    case spareSome = "Spare Some"
    case quit = "Quit"
    case manageExceptions = "Manage Exceptions…"
    case someAppsRemain = "Some apps survived."
    case killResult = "%d succeeded, %d failed to quit, and %d failed to disable relaunching.\n%@"
    case retryAsAdmin = "Retry as Administrator"
    case adminRetryFailed = "Administrator Retry Failed"
    case appleScriptCreationFailed = "Couldn’t create the administrator script."
    case adminRetrySent = "Sent Again as Administrator"
    case adminRetryDetail = "Sent another quit request to %d processes."
    case checkForUpdates = "Check for Updates…"
    case openLatestRelease = "Open Latest Release…"
}

private enum AppTranslations {
    static let korean: [AppText: String] = [
        .exceptionsTab: "예외 앱",
        .advancedTab: "고급",
        .allApps: "전체 앱",
        .running: "실행 중",
        .loginItems: "로그인 시 실행",
        .appsToSpare: "적당히 죽이기에서 살아남을 앱",
        .protectedCount: "%d개 보호 중",
        .sort: "정렬",
        .sortProtectedFirst: "보호 앱 먼저",
        .sortUnprotectedFirst: "비보호 앱 먼저",
        .sortName: "이름순",
        .loadingApps: "앱 목록을 불러오는 중…",
        .noApps: "앱이 없어요",
        .noSearchResults: "검색 결과가 없어요",
        .chooseAnotherList: "다른 목록을 선택해 보세요.",
        .tryAnotherSearch: "앱 이름, 번들 ID, 경로로 다시 찾아보세요.",
        .searchPrompt: "앱 이름, 번들 ID, 경로",
        .loginBadge: "로그인",
        .quitting: "강제 종료 중…",
        .forceQuitThisApp: "이 앱 강제 종료",
        .forceQuitFailed: "강제 종료하지 못했어요",
        .forceQuitFailureDetail: "%@에서 프로세스 %d개와 자동 재실행 방지 %d개가 실패했어요.",
        .language: "언어",
        .languageHint: "바꾸면 바로 적용됩니다.",
        .addBundleID: "번들 ID 직접 추가",
        .bundleIDExample: "예: com.apple.Safari",
        .addToExceptions: "예외에 추가",
        .menubarBundles: "메뉴 막대로 취급할 앱",
        .menubarHint: "LSUIElement가 아니어도 메뉴 막대 앱처럼 보호하고 싶을 때 사용해요.",
        .bundleID: "번들 ID",
        .add: "추가",
        .policyFile: "정책 파일",
        .exportPolicy: "정책 보내기…",
        .importPolicy: "정책 가져오기…",
        .ok: "확인",
        .saved: "저장했어요",
        .saveFailed: "저장 실패",
        .exportFailed: "보내기 실패",
        .newerPolicy: "버전이 더 새 파일이에요",
        .updateThenRetry: "앱을 업데이트한 뒤 다시 시도해 주세요.",
        .overwritePolicy: "정책을 덮어쓸까요?",
        .overwritePolicyDetail: "지금 목록이 JSON 파일 내용으로 바뀝니다.",
        .cancel: "취소",
        .overwrite: "덮어쓰기",
        .readFailed: "읽기 실패",
        .mainPrompt: "다 죽일까요?",
        .killEverybody: "다죽이기",
        .spareSome: "적당히 죽이기",
        .quit: "종료",
        .manageExceptions: "예외 앱 설정…",
        .someAppsRemain: "일부 앱이 남았어요",
        .killResult: "%d개 성공, %d개 종료 실패, %d개 자동 실행 해제 실패.\n%@",
        .retryAsAdmin: "관리자 권한으로 재시도",
        .adminRetryFailed: "관리자 재시도 실패",
        .appleScriptCreationFailed: "관리자 스크립트를 만들 수 없습니다.",
        .adminRetrySent: "관리자 권한으로 다시 보냈어요",
        .adminRetryDetail: "%d개 프로세스에 추가 종료 요청을 보냈습니다.",
        .checkForUpdates: "업데이트 확인…",
        .openLatestRelease: "최신 릴리즈 열기…",
    ]

    static let japanese: [AppText: String] = [
        .exceptionsTab: "例外アプリ",
        .advancedTab: "詳細",
        .allApps: "すべてのアプリ",
        .running: "実行中",
        .loginItems: "ログイン時に実行",
        .appsToSpare: "「ほどほどに殺す」で生き残るアプリ",
        .protectedCount: "%d件を保護中",
        .sort: "並べ替え",
        .sortProtectedFirst: "保護中を先に",
        .sortUnprotectedFirst: "未保護を先に",
        .sortName: "名前順",
        .loadingApps: "アプリを読み込み中…",
        .noApps: "アプリがありません",
        .noSearchResults: "検索結果がありません",
        .chooseAnotherList: "別の一覧を選んでください。",
        .tryAnotherSearch: "アプリ名、バンドル ID、パスを変えて検索してください。",
        .searchPrompt: "アプリ名、バンドル ID、パス",
        .loginBadge: "ログイン",
        .quitting: "強制終了中…",
        .forceQuitThisApp: "このアプリを強制終了",
        .forceQuitFailed: "強制終了できませんでした",
        .forceQuitFailureDetail: "%@ でプロセス %d件、再起動防止 %d件が失敗しました。",
        .language: "言語",
        .languageHint: "変更はすぐに反映されます。",
        .addBundleID: "バンドル ID を追加",
        .bundleIDExample: "例: com.apple.Safari",
        .addToExceptions: "例外に追加",
        .menubarBundles: "メニューバーアプリとして扱うアプリ",
        .menubarHint: "LSUIElement でなくても、メニューバーアプリと同じように保護したい場合に使います。",
        .bundleID: "バンドル ID",
        .add: "追加",
        .policyFile: "ポリシーファイル",
        .exportPolicy: "ポリシーを書き出す…",
        .importPolicy: "ポリシーを読み込む…",
        .ok: "OK",
        .saved: "保存しました",
        .saveFailed: "保存できませんでした",
        .exportFailed: "書き出せませんでした",
        .newerPolicy: "新しいバージョンのポリシーファイルです",
        .updateThenRetry: "アプリをアップデートしてから、もう一度お試しください。",
        .overwritePolicy: "現在のポリシーを上書きしますか？",
        .overwritePolicyDetail: "現在の例外設定は JSON ファイルの内容に置き換わります。",
        .cancel: "キャンセル",
        .overwrite: "上書き",
        .readFailed: "ファイルを読み込めませんでした",
        .mainPrompt: "みんな殺す？",
        .killEverybody: "みんな殺す",
        .spareSome: "ほどほどに殺す",
        .quit: "終了",
        .manageExceptions: "例外アプリを設定…",
        .someAppsRemain: "生き残ったアプリがあります",
        .killResult: "%d件成功、%d件の終了に失敗、%d件の自動起動解除に失敗しました。\n%@",
        .retryAsAdmin: "管理者権限で再試行",
        .adminRetryFailed: "管理者権限での再試行に失敗しました",
        .appleScriptCreationFailed: "管理者用スクリプトを作成できませんでした。",
        .adminRetrySent: "管理者権限でもう一度送りました",
        .adminRetryDetail: "%d件のプロセスに終了要求をもう一度送りました。",
        .checkForUpdates: "アップデートを確認…",
        .openLatestRelease: "最新リリースを開く…",
    ]
}
