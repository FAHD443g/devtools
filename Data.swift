import Foundation

// MARK: - Filter Options
struct FilterOptions {
    var minRating: Double = 0
    var selectedPlatforms: Set<String> = []
    var sortBy: SortOption = .rating
    var searchText: String = ""
    var isActive: Bool { minRating > 0 || !selectedPlatforms.isEmpty || sortBy != .rating }
    mutating func reset() { minRating=0; selectedPlatforms=[]; sortBy = .rating; searchText="" }
}

enum SortOption: String, CaseIterable {
    case rating, newest, stars, growth
    var label: String {
        switch self {
        case .rating: return L("filter_sort_rating")
        case .newest: return L("filter_sort_new")
        case .stars:  return L("filter_sort_stars")
        case .growth: return L("filter_sort_growth")
        }
    }
}

// MARK: - Tools Service
class ToolsService: ObservableObject {
    @Published var tools: [DevTool] = []
    @Published var isLoading = false
    @Published var favorites: Set<String> = []
    private var favsStored: String {
        get { UserDefaults.standard.string(forKey:"favs") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey:"favs") }
    }
    
    init() { loadFavs(); load() }
    
    func load() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline:.now()+0.8) {
            self.tools = Self.database
            self.isLoading = false
        }
    }
    
    func filtered(category: ToolCategory, filter: FilterOptions) -> [DevTool] {
        var r = tools
        if category != .all { r = r.filter { $0.category == category } }
        if !filter.searchText.isEmpty {
            let q = filter.searchText.lowercased()
            r = r.filter { $0.name.lowercased().contains(q) || ($0.descriptions["en"] ?? "").lowercased().contains(q) || $0.tags.contains { $0.lowercased().contains(q) } }
        }
        if filter.minRating > 0 { r = r.filter { $0.rating >= filter.minRating } }
        if !filter.selectedPlatforms.isEmpty { r = r.filter { t in t.platforms.contains { filter.selectedPlatforms.contains($0.rawValue) } } }
        switch filter.sortBy {
        case .rating: r.sort { $0.rating > $1.rating }
        case .newest: r.sort { $0.lastUpdated > $1.lastUpdated }
        case .stars:  r.sort { ($0.githubStars ?? 0) > ($1.githubStars ?? 0) }
        case .growth: r.sort { $0.weeklyGrowth > $1.weeklyGrowth }
        }
        return r
    }
    
    var featured:    [DevTool] { tools.filter { $0.isFeatured }.sorted { $0.rating > $1.rating } }
    var trending:    [DevTool] { tools.sorted { $0.weeklyGrowth > $1.weeklyGrowth }.prefix(10).map{$0} }
    var topRated:    [DevTool] { tools.sorted { $0.rating > $1.rating }.prefix(10).map{$0} }
    var newArrivals: [DevTool] { tools.sorted { $0.lastUpdated > $1.lastUpdated }.prefix(10).map{$0} }
    var favoriteTools:[DevTool] { tools.filter { favorites.contains($0.id) } }
    
    func isFavorite(_ t: DevTool) -> Bool { favorites.contains(t.id) }
    func toggleFavorite(_ t: DevTool) {
        if favorites.contains(t.id) { favorites.remove(t.id) } else { favorites.insert(t.id) }
        favsStored = favorites.joined(separator:",")
    }
    private func loadFavs() {
        if !favsStored.isEmpty { favorites = Set(favsStored.split(separator:",").map(String.init)) }
    }
    
    // MARK: - Database
    static let database: [DevTool] = {
        let now = Date()
        func d(_ days: Int) -> Date { Calendar.current.date(byAdding:.day, value:-days, to:now) ?? now }
        return [
            DevTool(id:"cursor", name:"Cursor", category:.aiML, rating:4.9, ratingCount:89000,
                    descriptions:["en":"AI-first code editor built for pair-programming with GPT-4. Edit code in natural language and generate entire features instantly.","ar":"محرر كود ذكاء اصطناعي مع GPT-4. حرر الكود بلغة طبيعية وأنشئ ميزات كاملة فوراً.","de":"KI-first Code-Editor mit GPT-4 für Pair-Programming.","ru":"ИИ-редактор с GPT-4 для парного программирования.","ja":"GPT-4を使ったAIファーストコードエディタ。","zh":"基于GPT-4的AI优先代码编辑器。"],
                    source:.official, tags:["AI","Editor","GPT-4","Productivity"],
                    accentColor:"#7C3AED", isFeatured:true, weeklyGrowth:28.3, githubStars:45000,
                    pricing:.freemium("$20/mo"), platforms:[.macOS,.windows,.linux],
                    websiteURL:"https://cursor.sh", githubURL:"https://github.com/getcursor/cursor",
                    lastUpdated:d(1), version:"0.42"),
            
            DevTool(id:"copilot", name:"GitHub Copilot", category:.aiML, rating:4.8, ratingCount:125000,
                    descriptions:["en":"AI-powered code completion trained on billions of lines of public code. Suggests whole lines and functions as you type.","ar":"إتمام الكود بالذكاء الاصطناعي مدرب على مليارات الأسطر. يقترح أسطراً كاملة أثناء الكتابة.","de":"KI-Codevervollständigung basierend auf Milliarden Codezeilen.","ru":"ИИ-автодополнение на основе миллиардов строк кода.","ja":"数十億行で訓練されたAIコード補完ツール。","zh":"基于数十亿行代码训练的AI代码补全。"],
                    source:.github, tags:["AI","Code Completion","IDE","OpenAI"],
                    accentColor:"#24292E", isFeatured:true, weeklyGrowth:12.5, githubStars:nil,
                    pricing:.paid("$10/mo"), platforms:[.web,.macOS,.windows,.linux],
                    websiteURL:"https://github.com/features/copilot", githubURL:nil,
                    lastUpdated:d(2), version:"1.140"),
            
            DevTool(id:"ollama", name:"Ollama", category:.aiML, rating:4.8, ratingCount:67000,
                    descriptions:["en":"Run large language models locally on your machine. Supports Llama 3, Mistral, Phi-3 and hundreds more with a simple CLI.","ar":"شغّل نماذج اللغة الكبيرة محلياً. يدعم Llama 3 وMistral والمزيد.","de":"LLMs lokal ausführen. Unterstützt Llama 3, Mistral und mehr.","ru":"Запуск LLM локально. Поддержка Llama 3, Mistral и других.","ja":"ローカルでLLMを実行。Llama 3、Mistral等をサポート。","zh":"在本地运行LLM。支持Llama 3、Mistral等。"],
                    source:.github, tags:["LLM","Local AI","Privacy","CLI","Open Source"],
                    accentColor:"#1A1A2E", isFeatured:false, weeklyGrowth:42.1, githubStars:85000,
                    pricing:.openSource, platforms:[.macOS,.windows,.linux],
                    websiteURL:"https://ollama.ai", githubURL:"https://github.com/ollama/ollama",
                    lastUpdated:d(1), version:"0.3.12"),
            
            DevTool(id:"v0", name:"v0 by Vercel", category:.aiML, rating:4.7, ratingCount:42000,
                    descriptions:["en":"Generative UI by Vercel. Describe your interface in plain text and get production-ready React components instantly.","ar":"واجهة توليدية من Vercel. صف واجهتك واحصل على مكونات React جاهزة فوراً.","de":"Generatives UI von Vercel für sofortige React-Komponenten.","ru":"Генеративный UI от Vercel для мгновенных React-компонентов.","ja":"VercelのジェネレーティブUI。テキストからReactコンポーネントを即生成。","zh":"Vercel的生成式UI，即时生成React组件。"],
                    source:.official, tags:["AI","UI","React","Vercel","Design"],
                    accentColor:"#000000", isFeatured:true, weeklyGrowth:35.7, githubStars:nil,
                    pricing:.freemium("$20/mo"), platforms:[.web],
                    websiteURL:"https://v0.dev", githubURL:nil,
                    lastUpdated:d(3), version:"2.0"),
            
            DevTool(id:"vscode", name:"VS Code", category:.codeEditor, rating:4.9, ratingCount:456000,
                    descriptions:["en":"The world's most popular code editor. Free, open source, runs everywhere with thousands of extensions available.","ar":"المحرر الأكثر شعبية في العالم. مجاني ومفتوح المصدر مع آلاف الإضافات.","de":"Der beliebteste Code-Editor der Welt. Kostenlos und Open Source.","ru":"Самый популярный редактор кода. Бесплатный и открытый.","ja":"世界で最も人気のあるコードエディタ。無料でオープンソース。","zh":"全球最受欢迎的代码编辑器。免费开源。"],
                    source:.github, tags:["Editor","IDE","Extensions","Microsoft","TypeScript"],
                    accentColor:"#007ACC", isFeatured:true, weeklyGrowth:3.2, githubStars:162000,
                    pricing:.openSource, platforms:[.macOS,.windows,.linux,.web],
                    websiteURL:"https://code.visualstudio.com", githubURL:"https://github.com/microsoft/vscode",
                    lastUpdated:d(2), version:"1.91"),
            
            DevTool(id:"nextjs", name:"Next.js", category:.frontend, rating:4.9, ratingCount:245000,
                    descriptions:["en":"The React framework used by world's leading companies to build high-quality web applications with SSR and SSG.","ar":"إطار React المستخدم من كبار الشركات لبناء تطبيقات ويب عالية الجودة.","de":"Das React-Framework für hochwertige Webanwendungen.","ru":"React-фреймворк для высококачественных веб-приложений.","ja":"高品質なWebアプリ構築のためのReactフレームワーク。","zh":"用于构建高质量Web应用的React框架。"],
                    source:.github, tags:["React","SSR","Framework","Vercel","TypeScript"],
                    accentColor:"#000000", isFeatured:true, weeklyGrowth:8.2, githubStars:125000,
                    pricing:.openSource, platforms:[.web,.macOS,.windows,.linux],
                    websiteURL:"https://nextjs.org", githubURL:"https://github.com/vercel/next.js",
                    lastUpdated:d(2), version:"14.2"),
            
            DevTool(id:"tailwind", name:"Tailwind CSS", category:.frontend, rating:4.8, ratingCount:198000,
                    descriptions:["en":"Utility-first CSS framework. Compose classes like flex, pt-4, text-center to build any design directly in your markup.","ar":"إطار CSS يركز على الأدوات. كوّن فئات لبناء أي تصميم مباشرة.","de":"Utility-first CSS-Framework für direktes Design im Markup.","ru":"Utility-first CSS-фреймворк для создания дизайна в разметке.","ja":"マークアップ内で直接デザインを構築するCSS フレームワーク。","zh":"实用优先的CSS框架，直接在标记中构建设计。"],
                    source:.github, tags:["CSS","Design","Utility","Styling","Framework"],
                    accentColor:"#38BDF8", isFeatured:false, weeklyGrowth:6.5, githubStars:79000,
                    pricing:.openSource, platforms:[.web],
                    websiteURL:"https://tailwindcss.com", githubURL:"https://github.com/tailwindlabs/tailwindcss",
                    lastUpdated:d(5), version:"3.4.4"),
            
            DevTool(id:"docker", name:"Docker", category:.devOps, rating:4.8, ratingCount:312000,
                    descriptions:["en":"Build, share and run containerized applications. The open platform for developing, shipping and running modern software.","ar":"ابنِ وشارك وشغّل التطبيقات في حاويات. المنصة المفتوحة للتطوير الحديث.","de":"Containerisierte Anwendungen erstellen und ausführen.","ru":"Создание и запуск контейнеризованных приложений.","ja":"コンテナ化アプリの構築・共有・実行プラットフォーム。","zh":"构建、共享和运行容器化应用程序。"],
                    source:.official, tags:["Container","DevOps","Cloud","Microservices"],
                    accentColor:"#2496ED", isFeatured:true, weeklyGrowth:5.1, githubStars:28000,
                    pricing:.freemium("$9/mo"), platforms:[.macOS,.windows,.linux],
                    websiteURL:"https://docker.com", githubURL:"https://github.com/docker/docker-ce",
                    lastUpdated:d(4), version:"27.1"),
            
            DevTool(id:"supabase", name:"Supabase", category:.backend, rating:4.8, ratingCount:134000,
                    descriptions:["en":"Open source Firebase alternative with Postgres database, Auth, Realtime subscriptions, and Storage built in.","ar":"بديل Firebase مفتوح المصدر مع Postgres والمصادقة وواجهات برمجية فورية والتخزين.","de":"Open-Source-Firebase-Alternative mit Postgres, Auth und Echtzeit-APIs.","ru":"Open-source альтернатива Firebase с Postgres и real-time API.","ja":"Postgres、Auth、リアルタイムを備えたFirebase代替。","zh":"带Postgres、Auth和实时API的开源Firebase替代品。"],
                    source:.github, tags:["Database","Auth","Realtime","PostgreSQL","BaaS"],
                    accentColor:"#3ECF8E", isFeatured:true, weeklyGrowth:18.9, githubStars:72000,
                    pricing:.freemium("$25/mo"), platforms:[.web,.ios,.android],
                    websiteURL:"https://supabase.com", githubURL:"https://github.com/supabase/supabase",
                    lastUpdated:d(2), version:"2.0"),
            
            DevTool(id:"postman", name:"Postman", category:.apiTools, rating:4.7, ratingCount:287000,
                    descriptions:["en":"The world's most popular API platform. Design, build, test and document your APIs with an intuitive interface.","ar":"منصة API الأكثر شعبية في العالم. صمم واختبر ووثّق واجهاتك البرمجية.","de":"Die weltweit beliebteste API-Plattform für Design und Test.","ru":"Самая популярная платформа для работы с API.","ja":"世界で最も人気のあるAPIプラットフォーム。","zh":"全球最受欢迎的API平台。"],
                    source:.official, tags:["API","REST","GraphQL","Testing","Documentation"],
                    accentColor:"#FF6C37", isFeatured:true, weeklyGrowth:5.3, githubStars:nil,
                    pricing:.freemium("$14/mo"), platforms:[.web,.macOS,.windows,.linux],
                    websiteURL:"https://postman.com", githubURL:nil,
                    lastUpdated:d(6), version:"11.4"),
            
            DevTool(id:"playwright", name:"Playwright", category:.testing, rating:4.8, ratingCount:89000,
                    descriptions:["en":"Reliable end-to-end testing for modern web apps. Cross-browser automation across Chromium, Firefox and WebKit.","ar":"اختبار شامل موثوق لتطبيقات الويب عبر Chromium وFirefox وWebKit.","de":"Zuverlässige E2E-Tests für moderne Web-Apps in allen Browsern.","ru":"Надежное E2E-тестирование во всех браузерах.","ja":"全ブラウザ対応の信頼性の高いE2Eテスト。","zh":"跨浏览器的可靠端到端测试框架。"],
                    source:.github, tags:["Testing","E2E","Browser","Automation","Microsoft"],
                    accentColor:"#2EAD33", isFeatured:false, weeklyGrowth:13.6, githubStars:65000,
                    pricing:.openSource, platforms:[.macOS,.windows,.linux,.cli],
                    websiteURL:"https://playwright.dev", githubURL:"https://github.com/microsoft/playwright",
                    lastUpdated:d(2), version:"1.45"),
            
            DevTool(id:"grafana", name:"Grafana", category:.monitoring, rating:4.7, ratingCount:143000,
                    descriptions:["en":"Query, visualize and alert on metrics from any data source. Create beautiful real-time dashboards for your team.","ar":"استعلم وصوّر وأنشئ تنبيهات على المقاييس من أي مصدر. لوحات معلومات جميلة.","de":"Metriken aus beliebigen Quellen visualisieren und überwachen.","ru":"Визуализация и мониторинг метрик из любых источников.","ja":"あらゆるソースのメトリクスを可視化・アラート。","zh":"从任何数据源查询、可视化和告警。"],
                    source:.github, tags:["Monitoring","Dashboard","Metrics","Observability"],
                    accentColor:"#F46800", isFeatured:false, weeklyGrowth:7.1, githubStars:63000,
                    pricing:.freemium("$299/mo"), platforms:[.web,.linux,.macOS,.windows],
                    websiteURL:"https://grafana.com", githubURL:"https://github.com/grafana/grafana",
                    lastUpdated:d(3), version:"11.1"),
            
            DevTool(id:"vercel", name:"Vercel", category:.cloudInfra, rating:4.8, ratingCount:167000,
                    descriptions:["en":"Deploy web projects with zero configuration. Automatic SSL, global CDN, and seamless Git integration for frontend teams.","ar":"انشر مشاريع الويب بدون إعداد. SSL تلقائي وشبكة CDN عالمية وتكامل Git سلس.","de":"Web-Projekte ohne Konfiguration deployen mit automatischem SSL.","ru":"Деплой без конфигурации с SSL и глобальным CDN.","ja":"設定不要でデプロイ。自動SSL、グローバルCDN。","zh":"零配置部署，自动SSL和全球CDN。"],
                    source:.official, tags:["Hosting","CDN","Serverless","Edge","Deployment"],
                    accentColor:"#000000", isFeatured:true, weeklyGrowth:9.4, githubStars:nil,
                    pricing:.freemium("$20/mo"), platforms:[.web,.cli],
                    websiteURL:"https://vercel.com", githubURL:nil,
                    lastUpdated:d(1), version:"Latest"),
            
            DevTool(id:"linear", name:"Linear", category:.collaboration, rating:4.8, ratingCount:78000,
                    descriptions:["en":"Project management built for modern product teams. Lightning-fast issue tracking, sprints, and roadmaps in one place.","ar":"إدارة مشاريع للفرق الحديثة. تتبع المشكلات والسباقات والخرائط بسرعة البرق.","de":"Projektmanagement für moderne Teams mit blitzschnellem Interface.","ru":"Управление проектами для современных команд.","ja":"現代チーム向け超高速プロジェクト管理。","zh":"为现代产品团队构建的超快速项目管理工具。"],
                    source:.official, tags:["Project Management","Issues","Sprint","Roadmap","Team"],
                    accentColor:"#5E6AD2", isFeatured:false, weeklyGrowth:16.3, githubStars:nil,
                    pricing:.freemium("$8/mo"), platforms:[.web,.macOS,.ios,.android],
                    websiteURL:"https://linear.app", githubURL:nil,
                    lastUpdated:d(3), version:"Latest"),
            
            DevTool(id:"expo", name:"Expo", category:.mobile, rating:4.7, ratingCount:112000,
                    descriptions:["en":"Build universal native apps for iOS, Android and Web from a single JavaScript and React Native codebase.","ar":"ابنِ تطبيقات أصلية عالمية لـ iOS وAndroid والويب من كودبيس واحد.","de":"Universelle native Apps für iOS, Android und Web mit React Native.","ru":"Нативные приложения для iOS, Android и Web на одной кодовой базе.","ja":"単一コードベースでiOS/Android/Web対応アプリを構築。","zh":"用单一代码库构建iOS、Android和Web原生应用。"],
                    source:.github, tags:["React Native","Mobile","Cross Platform","iOS","Android"],
                    accentColor:"#000020", isFeatured:false, weeklyGrowth:10.7, githubStars:33000,
                    pricing:.freemium("$99/mo"), platforms:[.ios,.android,.web],
                    websiteURL:"https://expo.dev", githubURL:"https://github.com/expo/expo",
                    lastUpdated:d(4), version:"51.0"),
        ]
    }()
}

