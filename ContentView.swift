import SwiftUI

// MARK: - App Entry
@main
struct DevToolsApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var userTracker = UserTracker()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(userTracker)
                .preferredColorScheme(appState.colorScheme)
                .onAppear { userTracker.trackFirstLaunch() }
        }
    }
}

// MARK: - AppState
class AppState: ObservableObject {
    @Published var selectedLanguage: AppLanguage = .english
    @Published var colorScheme: ColorScheme? = nil
    @Published var isDarkMode: Bool = false
    @Published var selectedTab: Int = 0
    @AppStorage("dark_mode") var darkModeStored: Bool = false
    @AppStorage("app_language") var storedLanguage: String = "en"
    init() {
        isDarkMode = darkModeStored
        colorScheme = darkModeStored ? .dark : .light
        if let lang = AppLanguage(rawValue: storedLanguage) { selectedLanguage = lang }
        LocalizationManager.shared.setLanguage(selectedLanguage)
    }
    func toggleDarkMode() {
        isDarkMode.toggle(); darkModeStored = isDarkMode
        withAnimation(.spring(response:0.4,dampingFraction:0.8)) { colorScheme = isDarkMode ? .dark : .light }
    }
    func setLanguage(_ lang: AppLanguage) {
        withAnimation { selectedLanguage = lang; storedLanguage = lang.rawValue; LocalizationManager.shared.setLanguage(lang) }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case arabic="ar", english="en", german="de", russian="ru", japanese="ja", chinese="zh"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .arabic: return "العربية"; case .english: return "English"
        case .german: return "Deutsch"; case .russian: return "Русский"
        case .japanese: return "日本語"; case .chinese: return "中文"
        }
    }
    var flag: String {
        switch self {
        case .arabic: return "🇸🇦"; case .english: return "🇺🇸"
        case .german: return "🇩🇪"; case .russian: return "🇷🇺"
        case .japanese: return "🇯🇵"; case .chinese: return "🇨🇳"
        }
    }
    var isRTL: Bool { self == .arabic }
    var locale: Locale { Locale(identifier: rawValue) }
}

// MARK: - UserTracker
class UserTracker: ObservableObject {
    @Published var totalUsers: Int = 0
    @Published var isFirstLaunch: Bool = false
    @Published var lastVisit: Date = Date()
    func trackFirstLaunch() {
        let d = UserDefaults.standard
        if let s = d.object(forKey:"last_visit") as? Date { lastVisit = s }
        d.set(Date(), forKey:"last_visit")
        if !d.bool(forKey:"launched") {
            isFirstLaunch = true; d.set(true, forKey:"launched")
            if d.string(forKey:"uid") == nil {
                d.set(UUID().uuidString, forKey:"uid")
                d.set(d.integer(forKey:"ucount")+1, forKey:"ucount")
            }
        }
        totalUsers = max(1, d.integer(forKey:"ucount"))
    }
    var userId: String { UserDefaults.standard.string(forKey:"uid") ?? "---" }
    func formattedLastVisit(for lang: AppLanguage) -> String {
        let f = DateFormatter(); f.locale = lang.locale; f.dateStyle = .medium; f.timeStyle = .short
        return f.string(from: lastVisit)
    }
}

// MARK: - Localization
func L(_ key: String) -> String { LocalizationManager.shared.localize(key) }
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    private var strings: [String:String] = [:]
    func setLanguage(_ lang: AppLanguage) {
        strings = Strings.all[lang.rawValue] ?? Strings.english
        objectWillChange.send()
    }
    func localize(_ key: String) -> String { strings[key] ?? key }
}
struct Strings {
    static let all: [String:[String:String]] = ["en":english,"ar":arabic,"de":german,"ru":russian,"ja":japanese,"zh":chinese]
    static let english: [String:String] = [
        "nav_home":"Home","nav_explore":"Explore","nav_favorites":"Favorites","nav_settings":"Settings","nav_trending":"Trending",
        "home_title":"Dev Tools","home_subtitle":"World's Best Developer Tools","home_featured":"Featured",
        "home_trending":"Trending Now","home_top_rated":"Top Rated","home_new_arrivals":"New Arrivals",
        "home_last_visit":"Last Visit","cat_all":"All","cat_ai":"AI & ML","cat_devops":"DevOps",
        "cat_frontend":"Frontend","cat_backend":"Backend","cat_database":"Database","cat_mobile":"Mobile",
        "cat_security":"Security","cat_testing":"Testing","cat_collab":"Collaboration","cat_cloud":"Cloud",
        "cat_editor":"Editor","cat_api":"API Tools","cat_monitoring":"Monitoring",
        "filter_title":"Filters","filter_reset":"Reset","filter_apply":"Apply","filter_sort_rating":"Rating",
        "filter_sort_new":"Newest","filter_sort_stars":"Stars","filter_sort_growth":"Growth",
        "detail_rating":"Rating","detail_source":"Source","detail_pricing":"Pricing","detail_platforms":"Platforms",
        "detail_version":"Version","detail_last_updated":"Last Updated","detail_tags":"Tags",
        "detail_weekly_growth":"Weekly Growth","detail_open_website":"Open Website","detail_github":"GitHub",
        "favorites_title":"Favorites","favorites_empty":"No Favorites Yet",
        "favorites_empty_desc":"Tap the heart on any tool to save it here",
        "settings_title":"Settings","settings_language":"Language","settings_theme":"Appearance",
        "settings_dark_mode":"Dark Mode","settings_about":"About","settings_version":"Version",
        "settings_user_count":"Global Users","settings_user_id":"Your ID",
        "see_all":"See All","weekly_growth":"weekly","open_source":"Open Source","free":"Free","paid":"Paid"
    ]
    static let arabic: [String:String] = [
        "nav_home":"الرئيسية","nav_explore":"استكشاف","nav_favorites":"المفضلة","nav_settings":"الإعدادات","nav_trending":"رواجاً",
        "home_title":"أدوات المطورين","home_subtitle":"أفضل أدوات التطوير عالمياً","home_featured":"مميز",
        "home_trending":"الأكثر رواجاً","home_top_rated":"الأعلى تقييماً","home_new_arrivals":"الأحدث",
        "home_last_visit":"آخر زيارة","cat_all":"الكل","cat_ai":"ذكاء اصطناعي","cat_devops":"DevOps",
        "cat_frontend":"الواجهة","cat_backend":"الخلفية","cat_database":"قواعد البيانات","cat_mobile":"الجوال",
        "cat_security":"الأمن","cat_testing":"الاختبار","cat_collab":"التعاون","cat_cloud":"السحابة",
        "cat_editor":"المحررات","cat_api":"API","cat_monitoring":"المراقبة",
        "filter_title":"تصفية","filter_reset":"إعادة تعيين","filter_apply":"تطبيق","filter_sort_rating":"التقييم",
        "filter_sort_new":"الأحدث","filter_sort_stars":"النجوم","filter_sort_growth":"النمو",
        "detail_rating":"التقييم","detail_source":"المصدر","detail_pricing":"التسعير","detail_platforms":"المنصات",
        "detail_version":"الإصدار","detail_last_updated":"آخر تحديث","detail_tags":"الوسوم",
        "detail_weekly_growth":"النمو الأسبوعي","detail_open_website":"فتح الموقع","detail_github":"GitHub",
        "favorites_title":"المفضلة","favorites_empty":"لا توجد مفضلات","favorites_empty_desc":"اضغط على القلب لحفظ أي أداة",
        "settings_title":"الإعدادات","settings_language":"اللغة","settings_theme":"المظهر",
        "settings_dark_mode":"الوضع الداكن","settings_about":"حول","settings_version":"الإصدار",
        "settings_user_count":"المستخدمون","settings_user_id":"معرفك",
        "see_all":"عرض الكل","weekly_growth":"أسبوعياً","open_source":"مفتوح المصدر","free":"مجاني","paid":"مدفوع"
    ]
    static let german: [String:String] = [
        "nav_home":"Startseite","nav_explore":"Erkunden","nav_favorites":"Favoriten","nav_settings":"Einstellungen","nav_trending":"Trending",
        "home_title":"Dev Tools","home_subtitle":"Weltbeste Entwicklertools","home_featured":"Empfohlen",
        "home_trending":"Trending","home_top_rated":"Beste","home_new_arrivals":"Neu",
        "home_last_visit":"Letzter Besuch","cat_all":"Alle","cat_ai":"KI & ML","cat_devops":"DevOps",
        "cat_frontend":"Frontend","cat_backend":"Backend","cat_database":"Datenbank","cat_mobile":"Mobile",
        "cat_security":"Sicherheit","cat_testing":"Testing","cat_collab":"Zusammenarbeit","cat_cloud":"Cloud",
        "cat_editor":"Editor","cat_api":"API","cat_monitoring":"Monitoring",
        "filter_title":"Filter","filter_reset":"Zurücksetzen","filter_apply":"Anwenden","filter_sort_rating":"Bewertung",
        "filter_sort_new":"Neueste","filter_sort_stars":"Sterne","filter_sort_growth":"Wachstum",
        "detail_rating":"Bewertung","detail_source":"Quelle","detail_pricing":"Preis","detail_platforms":"Plattformen",
        "detail_version":"Version","detail_last_updated":"Aktualisiert","detail_tags":"Tags",
        "detail_weekly_growth":"Wöchentliches Wachstum","detail_open_website":"Webseite","detail_github":"GitHub",
        "favorites_title":"Favoriten","favorites_empty":"Keine Favoriten","favorites_empty_desc":"Herz tippen zum Speichern",
        "settings_title":"Einstellungen","settings_language":"Sprache","settings_theme":"Design",
        "settings_dark_mode":"Dunkelmodus","settings_about":"Über","settings_version":"Version",
        "settings_user_count":"Nutzer","settings_user_id":"Ihre ID",
        "see_all":"Alle","weekly_growth":"wöchentlich","open_source":"Open Source","free":"Kostenlos","paid":"Bezahlt"
    ]
    static let russian: [String:String] = [
        "nav_home":"Главная","nav_explore":"Обзор","nav_favorites":"Избранное","nav_settings":"Настройки","nav_trending":"Тренды",
        "home_title":"Dev Tools","home_subtitle":"Лучшие инструменты разработчика","home_featured":"Рекомендуемые",
        "home_trending":"В тренде","home_top_rated":"Высший рейтинг","home_new_arrivals":"Новинки",
        "home_last_visit":"Последний визит","cat_all":"Все","cat_ai":"ИИ и МО","cat_devops":"DevOps",
        "cat_frontend":"Frontend","cat_backend":"Backend","cat_database":"БД","cat_mobile":"Мобильные",
        "cat_security":"Безопасность","cat_testing":"Тестирование","cat_collab":"Совместная работа","cat_cloud":"Облако",
        "cat_editor":"Редактор","cat_api":"API","cat_monitoring":"Мониторинг",
        "filter_title":"Фильтры","filter_reset":"Сброс","filter_apply":"Применить","filter_sort_rating":"Рейтинг",
        "filter_sort_new":"Новейшие","filter_sort_stars":"Звёзды","filter_sort_growth":"Рост",
        "detail_rating":"Рейтинг","detail_source":"Источник","detail_pricing":"Цена","detail_platforms":"Платформы",
        "detail_version":"Версия","detail_last_updated":"Обновлено","detail_tags":"Теги",
        "detail_weekly_growth":"Нед. рост","detail_open_website":"Открыть сайт","detail_github":"GitHub",
        "favorites_title":"Избранное","favorites_empty":"Нет избранного","favorites_empty_desc":"Нажмите сердечко для сохранения",
        "settings_title":"Настройки","settings_language":"Язык","settings_theme":"Тема",
        "settings_dark_mode":"Тёмный режим","settings_about":"О приложении","settings_version":"Версия",
        "settings_user_count":"Пользователи","settings_user_id":"Ваш ID",
        "see_all":"Все","weekly_growth":"в неделю","open_source":"Открытый код","free":"Бесплатно","paid":"Платный"
    ]
    static let japanese: [String:String] = [
        "nav_home":"ホーム","nav_explore":"探索","nav_favorites":"お気に入り","nav_settings":"設定","nav_trending":"トレンド",
        "home_title":"開発ツール","home_subtitle":"世界最高の開発者ツール","home_featured":"おすすめ",
        "home_trending":"トレンド","home_top_rated":"高評価","home_new_arrivals":"新着",
        "home_last_visit":"前回の訪問","cat_all":"すべて","cat_ai":"AI・ML","cat_devops":"DevOps",
        "cat_frontend":"フロントエンド","cat_backend":"バックエンド","cat_database":"データベース","cat_mobile":"モバイル",
        "cat_security":"セキュリティ","cat_testing":"テスト","cat_collab":"コラボ","cat_cloud":"クラウド",
        "cat_editor":"エディタ","cat_api":"API","cat_monitoring":"モニタリング",
        "filter_title":"フィルター","filter_reset":"リセット","filter_apply":"適用","filter_sort_rating":"評価",
        "filter_sort_new":"新着順","filter_sort_stars":"スター","filter_sort_growth":"成長",
        "detail_rating":"評価","detail_source":"ソース","detail_pricing":"価格","detail_platforms":"プラットフォーム",
        "detail_version":"バージョン","detail_last_updated":"最終更新","detail_tags":"タグ",
        "detail_weekly_growth":"週間成長","detail_open_website":"ウェブサイト","detail_github":"GitHub",
        "favorites_title":"お気に入り","favorites_empty":"お気に入りなし","favorites_empty_desc":"ハートをタップして保存",
        "settings_title":"設定","settings_language":"言語","settings_theme":"外観",
        "settings_dark_mode":"ダークモード","settings_about":"情報","settings_version":"バージョン",
        "settings_user_count":"ユーザー","settings_user_id":"あなたのID",
        "see_all":"すべて見る","weekly_growth":"週間","open_source":"オープンソース","free":"無料","paid":"有料"
    ]
    static let chinese: [String:String] = [
        "nav_home":"主页","nav_explore":"探索","nav_favorites":"收藏","nav_settings":"设置","nav_trending":"趋势",
        "home_title":"开发工具","home_subtitle":"全球最佳开发者工具","home_featured":"精选",
        "home_trending":"趋势","home_top_rated":"高评分","home_new_arrivals":"最新",
        "home_last_visit":"上次访问","cat_all":"全部","cat_ai":"AI与ML","cat_devops":"DevOps",
        "cat_frontend":"前端","cat_backend":"后端","cat_database":"数据库","cat_mobile":"移动端",
        "cat_security":"安全","cat_testing":"测试","cat_collab":"协作","cat_cloud":"云服务",
        "cat_editor":"编辑器","cat_api":"API","cat_monitoring":"监控",
        "filter_title":"筛选","filter_reset":"重置","filter_apply":"应用","filter_sort_rating":"评分",
        "filter_sort_new":"最新","filter_sort_stars":"星标","filter_sort_growth":"增长",
        "detail_rating":"评分","detail_source":"来源","detail_pricing":"定价","detail_platforms":"平台",
        "detail_version":"版本","detail_last_updated":"最后更新","detail_tags":"标签",
        "detail_weekly_growth":"周增长","detail_open_website":"打开网站","detail_github":"GitHub",
        "favorites_title":"收藏","favorites_empty":"暂无收藏","favorites_empty_desc":"点击爱心即可保存",
        "settings_title":"设置","settings_language":"语言","settings_theme":"外观",
        "settings_dark_mode":"深色模式","settings_about":"关于","settings_version":"版本",
        "settings_user_count":"全球用户","settings_user_id":"您的ID",
        "see_all":"查看全部","weekly_growth":"每周","open_source":"开源","free":"免费","paid":"付费"
    ]
}
