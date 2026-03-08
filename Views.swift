import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userTracker: UserTracker
    @StateObject var ts = ToolsService()
    @State private var showWelcome = false
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem { Label(L("nav_home"), systemImage:"house.fill") }.tag(0)
                ExploreView()
                    .tabItem { Label(L("nav_explore"), systemImage:"safari.fill") }.tag(1)
                TrendingView()
                    .tabItem { Label(L("nav_trending"), systemImage:"flame.fill") }.tag(2)
                FavoritesView()
                    .tabItem { Label(L("nav_favorites"), systemImage:"heart.fill") }.tag(3)
                SettingsView()
                    .tabItem { Label(L("nav_settings"), systemImage:"gearshape.fill") }.tag(4)
            }
            .tint(.primary)
            .environmentObject(ts)
            .environment(\.layoutDirection, appState.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            
            if showWelcome {
                WelcomeView(isShowing: $showWelcome)
                    .transition(.opacity).zIndex(100)
            }
        }
        .onAppear {
            if userTracker.isFirstLaunch {
                DispatchQueue.main.asyncAfter(deadline:.now()+0.5) {
                    withAnimation { showWelcome = true }
                }
            }
        }
    }
}

// MARK: - Welcome
struct WelcomeView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var userTracker: UserTracker
    @State private var phase = 0
    
    var body: some View {
        ZStack {
            LinearGradient(colors:[Color(hex:"#0F0C29") ?? .black, Color(hex:"#302B63") ?? .purple, Color(hex:"#24243E") ?? .black],
                           startPoint:.topLeading, endPoint:.bottomTrailing).ignoresSafeArea()
            VStack(spacing:32) {
                Spacer()
                ZStack {
                    Circle().fill(LinearGradient(colors:[Color(hex:"#6C63FF") ?? .purple, Color(hex:"#3D5AF1") ?? .blue],
                                                 startPoint:.topLeading, endPoint:.bottomTrailing)).frame(width:100,height:100)
                        .shadow(color:.purple.opacity(0.5),radius:20)
                    Image(systemName:"wrench.and.screwdriver.fill").font(.system(size:42)).foregroundColor(.white)
                }
                .scaleEffect(phase >= 1 ? 1:0.2)
                .animation(.spring(response:0.6,dampingFraction:0.65).delay(0.1), value:phase)
                
                VStack(spacing:12) {
                    Text("Dev Tools Store")
                        .font(.system(size:32,weight:.black,design:.rounded)).foregroundColor(.white)
                        .opacity(phase >= 2 ? 1:0).offset(y:phase >= 2 ? 0:20)
                        .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.3), value:phase)
                    Text(L("home_subtitle"))
                        .font(.system(size:16,weight:.medium)).foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center)
                        .opacity(phase >= 2 ? 1:0)
                        .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.4), value:phase)
                    HStack(spacing:8) {
                        Image(systemName:"person.3.fill").foregroundColor(.yellow)
                        Text("You are user #\(userTracker.totalUsers.formattedWithCommas)")
                            .font(.system(size:14,weight:.semibold)).foregroundColor(.white)
                    }
                    .padding(.horizontal,20).padding(.vertical,10)
                    .background(.white.opacity(0.15)).clipShape(Capsule())
                    .opacity(phase >= 3 ? 1:0)
                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.55), value:phase)
                }
                
                Spacer()
                
                VStack(spacing:14) {
                    ForEach(Array([
                        ("star.fill","Top-rated tools, curated daily",Color.yellow),
                        ("globe.americas.fill","6 languages supported",Color.green),
                        ("bolt.fill","120Hz smooth experience",Color.orange),
                        ("heart.fill","No account required, ever",Color.red)
                    ].enumerated()), id:\.offset) { i, item in
                        HStack(spacing:16) {
                            ZStack {
                                Circle().fill(item.2.opacity(0.2)).frame(width:40,height:40)
                                Image(systemName:item.0).foregroundColor(item.2)
                            }
                            Text(item.1).font(.system(size:15,weight:.medium)).foregroundColor(.white.opacity(0.9))
                            Spacer()
                        }
                        .opacity(phase >= 3 ? 1:0).offset(x:phase >= 3 ? 0:50)
                        .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.65+Double(i)*0.1), value:phase)
                    }
                }.padding(.horizontal,36)
                
                Spacer()
                
                Button {
                    HapticFeedback.medium()
                    withAnimation(.spring(response:0.4,dampingFraction:0.8)) { isShowing = false }
                } label: {
                    HStack {
                        Text("Get Started").font(.system(size:18,weight:.bold))
                        Image(systemName:"arrow.right")
                    }
                    .foregroundColor(.white).frame(maxWidth:.infinity).frame(height:56)
                    .background(LinearGradient(colors:[Color(hex:"#6C63FF") ?? .purple, Color(hex:"#3D5AF1") ?? .blue],
                                               startPoint:.leading, endPoint:.trailing))
                    .clipShape(RoundedRectangle(cornerRadius:28))
                    .shadow(color:.purple.opacity(0.4),radius:15,y:5)
                }
                .padding(.horizontal,36)
                .opacity(phase >= 4 ? 1:0).offset(y:phase >= 4 ? 0:30)
                .animation(.spring(response:0.5,dampingFraction:0.8).delay(1.1), value:phase)
                
                Spacer().frame(height:40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05) { phase=1 }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.25) { phase=2 }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.45) { phase=3 }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.65) { phase=4 }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userTracker: UserTracker
    @EnvironmentObject var ts: ToolsService
    @State private var selected: DevTool? = nil
    @State private var animated = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment:.top) {
                ScrollView(showsIndicators:false) {
                    VStack(spacing:0) {
                        Color.clear.frame(height:105)
                        if ts.isLoading {
                            VStack(spacing:14) {
                                ForEach(0..<4,id:\.self) { _ in
                                    RoundedRectangle(cornerRadius:16)
                                        .fill(Color(.secondarySystemBackground))
                                        .frame(height:70).overlay(ShimmerView()).clipShape(RoundedRectangle(cornerRadius:16))
                                        .padding(.horizontal,20)
                                }
                            }.padding(.top,20)
                        } else {
                            VStack(spacing:26) {
                                // Stats
                                HStack(spacing:10) {
                                    SPill(icon:"wrench.and.screwdriver.fill",text:"\(ts.tools.count)+ Tools",color:.blue)
                                    SPill(icon:"star.fill",text:"Top Rated",color:.yellow)
                                    SPill(icon:"arrow.up.right",text:"Updated Daily",color:.green)
                                }.padding(.horizontal,20)
                                    .opacity(animated ? 1:0).offset(y:animated ? 0:20)
                                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.05),value:animated)
                                
                                // Featured
                                VStack(alignment:.leading,spacing:14) {
                                    Text(L("home_featured")).font(.system(size:20,weight:.bold,design:.rounded)).padding(.horizontal,20)
                                    ScrollView(.horizontal,showsIndicators:false) {
                                        HStack(spacing:16) {
                                            ForEach(ts.featured) { t in
                                                FeatCard(tool:t).onTapGesture { HapticFeedback.light(); selected=t }
                                            }
                                        }.padding(.horizontal,20).padding(.vertical,4)
                                    }
                                }
                                .opacity(animated ? 1:0).offset(y:animated ? 0:30)
                                .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.1),value:animated)
                                
                                ToolRow(title:L("home_trending"), tools:ts.trending, showGrowth:true)
                                    .opacity(animated ? 1:0).offset(y:animated ? 0:40)
                                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.15),value:animated)
                                
                                ToolRow(title:L("home_top_rated"), tools:ts.topRated, showGrowth:false)
                                    .opacity(animated ? 1:0).offset(y:animated ? 0:50)
                                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.2),value:animated)
                                
                                ToolRow(title:L("home_new_arrivals"), tools:ts.newArrivals, showGrowth:false)
                                    .opacity(animated ? 1:0).offset(y:animated ? 0:60)
                                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.25),value:animated)
                                
                                Color.clear.frame(height:90)
                            }.padding(.top,16)
                        }
                    }
                }
                // Header
                VStack(spacing:0) {
                    HStack(alignment:.center,spacing:12) {
                        VStack(alignment:.leading,spacing:2) {
                            Text(L("home_title")).font(.system(size:26,weight:.black,design:.rounded))
                            Text(L("home_subtitle")).font(.system(size:11,weight:.medium)).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment:.trailing,spacing:1) {
                            Text(L("home_last_visit")).font(.system(size:9,weight:.semibold)).foregroundColor(.secondary)
                            Text(userTracker.formattedLastVisit(for:appState.selectedLanguage))
                                .font(.system(size:10,weight:.bold,design:.rounded)).lineLimit(1).minimumScaleFactor(0.6)
                        }
                        .padding(.horizontal,10).padding(.vertical,6)
                        .background(Color(.secondarySystemBackground)).cornerRadius(10)
                        .shadow(color:.black.opacity(0.07),radius:5)
                    }
                    .padding(.horizontal,20).padding(.top,56).padding(.bottom,12)
                    .background(Color(.systemBackground).opacity(0.92).background(.ultraThinMaterial).ignoresSafeArea(edges:.top))
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation(.spring(response:0.6,dampingFraction:0.8).delay(0.2)) { animated=true } }
        }
        .sheet(item:$selected) { DetailView(tool:$0) }
    }
}

struct SPill: View {
    let icon:String; let text:String; let color:Color
    var body: some View {
        HStack(spacing:5) {
            Image(systemName:icon).font(.system(size:11)).foregroundColor(color)
            Text(text).font(.system(size:11,weight:.semibold))
        }.padding(.horizontal,10).padding(.vertical,6).background(color.opacity(0.1)).clipShape(Capsule())
    }
}

struct FeatCard: View {
    let tool: DevTool
    @EnvironmentObject var ts: ToolsService
    @EnvironmentObject var appState: AppState
    @State private var pressed = false
    var body: some View {
        ZStack(alignment:.bottomLeading) {
            RoundedRectangle(cornerRadius:24,style:.continuous)
                .fill(LinearGradient(colors:tool.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing))
                .frame(width:268,height:172)
            RoundedRectangle(cornerRadius:24,style:.continuous).fill(.black.opacity(0.12)).frame(width:268,height:172)
            Circle().fill(.white.opacity(0.07)).frame(width:110).offset(x:165,y:-50)
            VStack(alignment:.leading,spacing:10) {
                HStack {
                    ZStack {
                        Circle().fill(.white.opacity(0.2)).frame(width:40,height:40)
                        Image(systemName:tool.category.icon).font(.system(size:17)).foregroundColor(.white)
                    }
                    Spacer()
                    Button { HapticFeedback.medium(); ts.toggleFavorite(tool) } label: {
                        Image(systemName:ts.isFavorite(tool) ? "heart.fill":"heart")
                            .foregroundColor(.white).padding(8).background(.white.opacity(0.2)).clipShape(Circle())
                    }
                }
                Spacer()
                VStack(alignment:.leading,spacing:4) {
                    Text(tool.name).font(.system(size:19,weight:.bold)).foregroundColor(.white)
                    HStack(spacing:6) {
                        StarRatingView(rating:tool.rating,size:11,color:.yellow)
                        Text(tool.formattedRating).font(.system(size:12,weight:.bold)).foregroundColor(.white)
                        Text(tool.weeklyGrowth.percentFormatted).font(.system(size:12,weight:.bold)).foregroundColor(.green)
                    }
                    Text(tool.localizedDescription(for:appState.selectedLanguage))
                        .font(.system(size:11)).foregroundColor(.white.opacity(0.8)).lineLimit(2)
                }
            }.padding(18).frame(width:268,height:172)
        }
        .scaleEffect(pressed ? 0.96:1)
        .shadow(color:(tool.category.gradient.first ?? .blue).opacity(0.35),radius:14,y:6)
        .animation(.spring(response:0.3,dampingFraction:0.7),value:pressed)
        .simultaneousGesture(DragGesture(minimumDistance:0).onChanged{_ in pressed=true}.onEnded{_ in pressed=false})
    }
}

struct ToolRow: View {
    let title:String; let tools:[DevTool]; let showGrowth:Bool
    @State private var sel: DevTool? = nil
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            HStack {
                Text(title).font(.system(size:20,weight:.bold,design:.rounded))
                Spacer()
                Text(L("see_all")).font(.system(size:13,weight:.semibold)).foregroundColor(.blue)
            }.padding(.horizontal,20)
            ScrollView(.horizontal,showsIndicators:false) {
                HStack(spacing:14) {
                    ForEach(tools) { t in
                        CCard(tool:t,showGrowth:showGrowth).onTapGesture { HapticFeedback.light(); sel=t }
                    }
                }.padding(.horizontal,20).padding(.vertical,4)
            }
        }.sheet(item:$sel) { DetailView(tool:$0) }
    }
}

struct CCard: View {
    let tool:DevTool; let showGrowth:Bool
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            HStack(spacing:10) {
                ZStack {
                    RoundedRectangle(cornerRadius:12,style:.continuous)
                        .fill(LinearGradient(colors:tool.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing))
                        .frame(width:44,height:44)
                    Image(systemName:tool.category.icon).font(.system(size:18)).foregroundColor(.white)
                }
                VStack(alignment:.leading,spacing:2) {
                    Text(tool.name).font(.system(size:14,weight:.bold)).lineLimit(1)
                    HStack(spacing:3) {
                        Image(systemName:"star.fill").font(.system(size:9)).foregroundColor(.yellow)
                        Text(tool.formattedRating).font(.system(size:11,weight:.semibold)).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button { HapticFeedback.medium(); ts.toggleFavorite(tool) } label: {
                    Image(systemName:ts.isFavorite(tool) ? "heart.fill":"heart")
                        .font(.system(size:13)).foregroundColor(ts.isFavorite(tool) ? .red:.secondary)
                }
            }
            Text(tool.localizedDescription(for:appState.selectedLanguage))
                .font(.system(size:11)).foregroundColor(.secondary).lineLimit(2)
            HStack {
                Text(tool.category.localizedName).font(.system(size:10,weight:.semibold))
                    .foregroundColor(tool.category.gradient.first ?? .blue)
                    .padding(.horizontal,7).padding(.vertical,3)
                    .background((tool.category.gradient.first ?? .blue).opacity(0.1)).clipShape(Capsule())
                Spacer()
                if showGrowth {
                    HStack(spacing:2) {
                        Image(systemName:"arrow.up.right").font(.system(size:9))
                        Text(tool.weeklyGrowth.percentFormatted).font(.system(size:10,weight:.bold))
                    }.foregroundColor(.green)
                } else if tool.githubStars != nil {
                    HStack(spacing:2) {
                        Image(systemName:"star.fill").font(.system(size:9))
                        Text(tool.formattedStars).font(.system(size:10,weight:.semibold))
                    }.foregroundColor(.orange)
                }
            }
        }.padding(14).frame(width:210).cardStyle()
    }
}

// MARK: - Explore
struct ExploreView: View {
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    @State private var category:ToolCategory = .all
    @State private var filter = FilterOptions()
    @State private var search = ""
    @State private var gridMode = true
    @State private var sel:DevTool? = nil
    @State private var showFilters = false
    @State private var animated = false
    let cols = [GridItem(.flexible(),spacing:14),GridItem(.flexible(),spacing:14)]
    var tools:[DevTool] { var f=filter; f.searchText=search; return ts.filtered(category:category,filter:f) }
    
    var body: some View {
        NavigationStack {
            VStack(spacing:0) {
                HStack(spacing:10) {
                    Image(systemName:"magnifyingglass").foregroundColor(.secondary)
                    TextField(L("search_placeholder") , text:$search)
                    if !search.isEmpty { Button { withAnimation { search="" } } label: { Image(systemName:"xmark.circle.fill").foregroundColor(.secondary) } }
                }.padding(.horizontal,14).padding(.vertical,11)
                    .background(Color(.secondarySystemBackground)).cornerRadius(14)
                    .padding(.horizontal,16).padding(.vertical,8)
                
                ScrollView(.horizontal,showsIndicators:false) {
                    HStack(spacing:8) {
                        ForEach(ToolCategory.allCases) { cat in
                            Button { HapticFeedback.selection(); withAnimation(.spring(response:0.35,dampingFraction:0.8)) { category=cat } } label: {
                                HStack(spacing:5) {
                                    Image(systemName:cat.icon).font(.system(size:11))
                                    Text(cat.localizedName).font(.system(size:12,weight:.semibold))
                                }
                                .foregroundColor(category==cat ? .white:.primary)
                                .padding(.horizontal,12).padding(.vertical,8)
                                .background(category==cat
                                            ? AnyView(LinearGradient(colors:cat.gradient,startPoint:.leading,endPoint:.trailing))
                                            : AnyView(Color(.secondarySystemBackground)))
                                .clipShape(Capsule())
                                .shadow(color:category==cat ? (cat.gradient.first?.opacity(0.4) ?? .clear):.clear,radius:6,y:2)
                            }.buttonStyle(BounceButtonStyle())
                        }
                    }.padding(.horizontal,16)
                }.padding(.bottom,8)
                
                HStack {
                    Text("\(tools.count) tools").font(.system(size:13,weight:.medium)).foregroundColor(.secondary)
                    Spacer()
                    Menu {
                        ForEach(SortOption.allCases,id:\.self) { opt in
                            Button { HapticFeedback.light(); filter.sortBy=opt } label: {
                                HStack { Text(opt.label); if filter.sortBy==opt { Image(systemName:"checkmark") } }
                            }
                        }
                    } label: {
                        HStack(spacing:4) {
                            Image(systemName:"arrow.up.arrow.down").font(.system(size:11))
                            Text(filter.sortBy.label).font(.system(size:12,weight:.medium))
                        }.foregroundColor(.primary).padding(.horizontal,10).padding(.vertical,6)
                            .background(Color(.secondarySystemBackground)).clipShape(Capsule())
                    }
                    Button { HapticFeedback.light(); showFilters=true } label: {
                        HStack(spacing:4) {
                            Image(systemName:"slider.horizontal.3").font(.system(size:11))
                            Text(L("filter_title")).font(.system(size:12,weight:.medium))
                            if filter.isActive { Circle().fill(.blue).frame(width:6,height:6) }
                        }.foregroundColor(filter.isActive ? .blue:.primary).padding(.horizontal,10).padding(.vertical,6)
                            .background(filter.isActive ? Color.blue.opacity(0.1):Color(.secondarySystemBackground)).clipShape(Capsule())
                    }
                    Button { HapticFeedback.light(); withAnimation { gridMode.toggle() } } label: {
                        Image(systemName:gridMode ? "list.bullet":"square.grid.2x2").foregroundColor(.primary)
                    }
                }.padding(.horizontal,16).padding(.bottom,8)
                
                if tools.isEmpty {
                    VStack(spacing:16) {
                        Image(systemName:"magnifyingglass").font(.system(size:48)).foregroundColor(.secondary.opacity(0.4))
                        Text(L("search_no_results")).font(.system(size:18,weight:.semibold)).foregroundColor(.secondary)
                        Button { search=""; filter.reset(); category = .all } label: {
                            Text(L("filter_reset")).font(.system(size:15,weight:.semibold)).foregroundColor(.blue)
                        }
                    }.frame(maxWidth:.infinity,maxHeight:.infinity)
                } else {
                    ScrollView(showsIndicators:false) {
                        if gridMode {
                            LazyVGrid(columns:cols,spacing:14) {
                                ForEach(tools.indices,id:\.self) { i in
                                    GCard(tool:tools[i]).onTapGesture { HapticFeedback.light(); sel=tools[i] }
                                        .opacity(animated ? 1:0).offset(y:animated ? 0:20)
                                        .animation(.spring(response:0.45,dampingFraction:0.8).delay(Double(i%6)*0.04),value:animated)
                                }
                            }.padding(.horizontal,16)
                        } else {
                            LazyVStack(spacing:12) {
                                ForEach(tools.indices,id:\.self) { i in
                                    LCard(tool:tools[i]).onTapGesture { HapticFeedback.light(); sel=tools[i] }
                                        .opacity(animated ? 1:0)
                                        .animation(.spring(response:0.45,dampingFraction:0.8).delay(Double(i%10)*0.03),value:animated)
                                }
                            }.padding(.horizontal,16)
                        }
                        Color.clear.frame(height:90)
                    }
                }
            }
            .navigationTitle(L("nav_explore")).navigationBarTitleDisplayMode(.large)
        }
        .sheet(item:$sel) { DetailView(tool:$0) }
        .sheet(isPresented:$showFilters) { FiltersSheet(filter:$filter) }
        .onAppear { withAnimation(.spring(response:0.5,dampingFraction:0.8).delay(0.1)) { animated=true } }
        .onChange(of:category) { _,_ in animated=false; DispatchQueue.main.asyncAfter(deadline:.now()+0.05) { withAnimation { animated=true } } }
    }
}

struct GCard: View {
    let tool:DevTool
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius:13,style:.continuous)
                        .fill(LinearGradient(colors:tool.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing))
                        .frame(width:48,height:48)
                    Image(systemName:tool.category.icon).font(.system(size:20)).foregroundColor(.white)
                }
                Spacer()
                Button { HapticFeedback.medium(); ts.toggleFavorite(tool) } label: {
                    Image(systemName:ts.isFavorite(tool) ? "heart.fill":"heart")
                        .font(.system(size:14)).foregroundColor(ts.isFavorite(tool) ? .red:.secondary)
                }
            }
            Text(tool.name).font(.system(size:14,weight:.bold)).lineLimit(1)
            Text(tool.localizedDescription(for:appState.selectedLanguage)).font(.system(size:11)).foregroundColor(.secondary).lineLimit(3)
            Spacer()
            HStack {
                HStack(spacing:3) {
                    Image(systemName:"star.fill").font(.system(size:9)).foregroundColor(.yellow)
                    Text(tool.formattedRating).font(.system(size:11,weight:.bold))
                }
                Spacer()
                Text(tool.pricing.displayText).font(.system(size:10,weight:.semibold)).foregroundColor(tool.pricing.color)
                    .padding(.horizontal,7).padding(.vertical,3).background(tool.pricing.color.opacity(0.1)).clipShape(Capsule())
            }
        }.padding(14).frame(minHeight:168).cardStyle()
    }
}

struct LCard: View {
    let tool:DevTool
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    var body: some View {
        HStack(spacing:12) {
            ZStack {
                RoundedRectangle(cornerRadius:13,style:.continuous)
                    .fill(LinearGradient(colors:tool.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing))
                    .frame(width:52,height:52)
                Image(systemName:tool.category.icon).font(.system(size:21)).foregroundColor(.white)
            }
            VStack(alignment:.leading,spacing:5) {
                HStack {
                    Text(tool.name).font(.system(size:15,weight:.bold))
                    Spacer()
                    HStack(spacing:3) {
                        Image(systemName:"star.fill").font(.system(size:10)).foregroundColor(.yellow)
                        Text(tool.formattedRating).font(.system(size:12,weight:.bold))
                    }
                }
                Text(tool.localizedDescription(for:appState.selectedLanguage)).font(.system(size:12)).foregroundColor(.secondary).lineLimit(2)
                HStack(spacing:8) {
                    Text(tool.category.localizedName).font(.system(size:10,weight:.semibold))
                        .foregroundColor(tool.category.gradient.first ?? .blue)
                        .padding(.horizontal,7).padding(.vertical,3)
                        .background((tool.category.gradient.first ?? .blue).opacity(0.1)).clipShape(Capsule())
                    Text(tool.pricing.displayText).font(.system(size:10,weight:.semibold)).foregroundColor(tool.pricing.color)
                    Spacer()
                    Button { HapticFeedback.medium(); ts.toggleFavorite(tool) } label: {
                        Image(systemName:ts.isFavorite(tool) ? "heart.fill":"heart")
                            .font(.system(size:14)).foregroundColor(ts.isFavorite(tool) ? .red:.secondary)
                    }
                }
            }
        }.padding(14).cardStyle()
    }
}

struct FiltersSheet: View {
    @Binding var filter:FilterOptions
    @Environment(\.dismiss) var dismiss
    @State private var tmp = FilterOptions()
    init(filter:Binding<FilterOptions>) { _filter=filter; _tmp=State(initialValue:filter.wrappedValue) }
    var body: some View {
        NavigationStack {
            List {
                Section("Sort By") {
                    ForEach(SortOption.allCases,id:\.self) { opt in
                        Button { HapticFeedback.light(); tmp.sortBy=opt } label: {
                            HStack { Text(opt.label).foregroundColor(.primary); Spacer()
                                if tmp.sortBy==opt { Image(systemName:"checkmark.circle.fill").foregroundColor(.blue) }
                            }
                        }
                    }
                }
                Section(L("filter_rating")) {
                    VStack(spacing:10) {
                        HStack { StarRatingView(rating:tmp.minRating,size:18,color:.yellow); Spacer(); Text(String(format:"%.1f+",tmp.minRating)).font(.system(size:16,weight:.bold)) }
                        Slider(value:$tmp.minRating,in:0...5,step:0.5).tint(.yellow)
                    }.padding(.vertical,4)
                }
                Section("Platform") {
                    ForEach(Platform.allCases,id:\.self) { p in
                        Button { if tmp.selectedPlatforms.contains(p.rawValue) { tmp.selectedPlatforms.remove(p.rawValue) } else { tmp.selectedPlatforms.insert(p.rawValue) } } label: {
                            HStack { Label(p.rawValue,systemImage:p.icon).foregroundColor(.primary); Spacer()
                                if tmp.selectedPlatforms.contains(p.rawValue) { Image(systemName:"checkmark.circle.fill").foregroundColor(.blue) }
                            }
                        }
                    }
                }
            }
            .navigationTitle(L("filter_title")).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading) { Button(L("filter_reset")) { tmp.reset() }.foregroundColor(.red) }
                ToolbarItem(placement:.navigationBarTrailing) { Button(L("filter_apply")) { filter=tmp; dismiss() }.fontWeight(.bold) }
            }
        }
    }
}

// MARK: - Detail
struct DetailView: View {
    let tool:DevTool
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    @State private var animated = false
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators:false) {
                VStack(spacing:0) {
                    ZStack(alignment:.bottomLeading) {
                        LinearGradient(colors:tool.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing).frame(height:205)
                        Circle().fill(.white.opacity(0.06)).frame(width:170).offset(x:150,y:-40)
                        VStack(alignment:.leading,spacing:14) {
                            ZStack {
                                RoundedRectangle(cornerRadius:18,style:.continuous).fill(.white.opacity(0.2)).frame(width:64,height:64)
                                Image(systemName:tool.category.icon).font(.system(size:26)).foregroundColor(.white)
                            }
                            .scaleEffect(animated ? 1:0.4).animation(.spring(response:0.5,dampingFraction:0.7).delay(0.1),value:animated)
                            VStack(alignment:.leading,spacing:6) {
                                Text(tool.name).font(.system(size:24,weight:.black)).foregroundColor(.white)
                                HStack(spacing:10) {
                                    HStack(spacing:4) {
                                        StarRatingView(rating:tool.rating,size:12,color:.yellow)
                                        Text(tool.formattedRating).font(.system(size:13,weight:.bold)).foregroundColor(.white)
                                        Text("(\(tool.ratingCount.formattedWithCommas))").font(.system(size:11)).foregroundColor(.white.opacity(0.7))
                                    }
                                    HStack(spacing:3) {
                                        Image(systemName:"arrow.up.right").font(.system(size:10))
                                        Text(tool.weeklyGrowth.percentFormatted).font(.system(size:12,weight:.bold))
                                    }.foregroundColor(.green).padding(.horizontal,8).padding(.vertical,3).background(.white.opacity(0.15)).clipShape(Capsule())
                                }
                            }
                            .opacity(animated ? 1:0).offset(y:animated ? 0:18)
                            .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.2),value:animated)
                        }.padding(22)
                    }
                    
                    VStack(spacing:14) {
                        VStack(alignment:.leading,spacing:10) {
                            Label("About",systemImage:"text.alignleft").font(.system(size:15,weight:.bold)).foregroundColor(tool.category.gradient.first ?? .blue)
                            Text(tool.localizedDescription(for:appState.selectedLanguage)).font(.system(size:14)).foregroundColor(.secondary).lineSpacing(3)
                        }.padding(14).cardStyle()
                        
                        HStack(spacing:12) {
                            MStat(value:tool.formattedRating,label:L("detail_rating"),icon:"star.fill",color:.yellow)
                            if tool.githubStars != nil { MStat(value:tool.formattedStars,label:"GitHub",icon:"star.fill",color:.orange) }
                            MStat(value:tool.weeklyGrowth.percentFormatted,label:L("weekly_growth"),icon:"arrow.up.right",color:.green)
                        }
                        
                        VStack(spacing:0) {
                            DRow(icon:"creditcard.fill",label:L("detail_pricing"),value:tool.pricing.displayText,color:tool.pricing.color)
                            Divider().padding(.leading,44)
                            DRow(icon:"tag.fill",label:L("detail_version"),value:tool.version,color:.blue)
                            Divider().padding(.leading,44)
                            DRow(icon:"calendar",label:L("detail_last_updated"),value:tool.lastUpdated.formatted(date:.abbreviated,time:.omitted),color:.secondary)
                            Divider().padding(.leading,44)
                            DRow(icon:tool.source.icon,label:L("detail_source"),value:tool.source.rawValue,color:tool.source.color)
                        }.cardStyle()
                        
                        VStack(alignment:.leading,spacing:12) {
                            Label(L("detail_platforms"),systemImage:"laptopcomputer.and.iphone").font(.system(size:15,weight:.bold)).foregroundColor(tool.category.gradient.first ?? .blue)
                            LazyVGrid(columns:[GridItem(.adaptive(minimum:85))],spacing:8) {
                                ForEach(tool.platforms,id:\.rawValue) { p in
                                    HStack(spacing:5) { Image(systemName:p.icon).font(.system(size:11)); Text(p.rawValue).font(.system(size:11,weight:.medium)) }
                                        .foregroundColor(.primary).padding(.horizontal,10).padding(.vertical,7).frame(maxWidth:.infinity)
                                        .background(Color(.tertiarySystemBackground)).cornerRadius(10)
                                }
                            }
                        }.padding(14).cardStyle()
                        
                        VStack(alignment:.leading,spacing:12) {
                            Label(L("detail_tags"),systemImage:"tag.fill").font(.system(size:15,weight:.bold)).foregroundColor(tool.category.gradient.first ?? .blue)
                            LazyVGrid(columns:[GridItem(.adaptive(minimum:70))],spacing:8) {
                                ForEach(tool.tags,id:\.self) { tag in
                                    Text(tag).font(.system(size:11,weight:.medium)).padding(.horizontal,10).padding(.vertical,6)
                                        .background(Color(.tertiarySystemBackground)).clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color(.separator),lineWidth:0.5))
                                }
                            }
                        }.padding(14).cardStyle()
                        
                        VStack(spacing:10) {
                            if let url = URL(string:tool.websiteURL) {
                                Link(destination:url) {
                                    HStack { Image(systemName:"globe"); Text(L("detail_open_website")).font(.system(size:15,weight:.bold)) }
                                        .foregroundColor(.white).frame(maxWidth:.infinity).frame(height:52)
                                        .background(LinearGradient(colors:tool.category.gradient,startPoint:.leading,endPoint:.trailing))
                                        .clipShape(RoundedRectangle(cornerRadius:16))
                                        .shadow(color:(tool.category.gradient.first ?? .blue).opacity(0.3),radius:10,y:4)
                                }
                            }
                            if let gh = tool.githubURL, let url = URL(string:gh) {
                                Link(destination:url) {
                                    HStack { Image(systemName:"chevron.left.forwardslash.chevron.right"); Text(L("detail_github")).font(.system(size:15,weight:.bold)) }
                                        .foregroundColor(.primary).frame(maxWidth:.infinity).frame(height:52)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius:16))
                                        .overlay(RoundedRectangle(cornerRadius:16).stroke(Color(.separator),lineWidth:1))
                                }
                            }
                        }
                        Color.clear.frame(height:20)
                    }
                    .padding(.horizontal,16).padding(.top,16)
                    .opacity(animated ? 1:0).offset(y:animated ? 0:20)
                    .animation(.spring(response:0.5,dampingFraction:0.8).delay(0.25),value:animated)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.navigationBarTrailing) {
                    Button { HapticFeedback.medium(); ts.toggleFavorite(tool) } label: {
                        Image(systemName:ts.isFavorite(tool) ? "heart.fill":"heart")
                            .foregroundColor(ts.isFavorite(tool) ? .red:.primary)
                    }
                }
            }
        }
        .onAppear { withAnimation(.spring(response:0.5,dampingFraction:0.8).delay(0.1)) { animated=true } }
    }
}

struct MStat: View {
    let value:String; let label:String; let icon:String; let color:Color
    var body: some View {
        VStack(spacing:6) {
            Image(systemName:icon).font(.system(size:18)).foregroundColor(color)
            Text(value).font(.system(size:17,weight:.bold))
            Text(label).font(.system(size:10,weight:.medium)).foregroundColor(.secondary)
        }.frame(maxWidth:.infinity).padding(.vertical,14).cardStyle()
    }
}
struct DRow: View {
    let icon:String; let label:String; let value:String; let color:Color
    var body: some View {
        HStack(spacing:12) {
            Image(systemName:icon).font(.system(size:15)).foregroundColor(color).frame(width:30)
            Text(label).font(.system(size:14)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size:14,weight:.semibold))
        }.padding(13)
    }
}

// MARK: - Trending
struct TrendingView: View {
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    @State private var sel:DevTool? = nil
    @State private var animated = false
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators:false) {
                VStack(spacing:16) {
                    HStack(spacing:12) {
                        TStat(value:ts.trending.first.map{String(format:"+%.0f%%",$0.weeklyGrowth)} ?? "-",label:"Top Growth",color:.green)
                        TStat(value:"\(ts.tools.count)+",label:"Total Tools",color:.blue)
                        TStat(value:"\(ts.trending.filter{$0.weeklyGrowth>20}.count)",label:"Hot 🔥",color:.orange)
                    }.padding(.horizontal,16)
                    ScrollView(.horizontal,showsIndicators:false) {
                        HStack(spacing:10) {
                            ForEach(ts.trending.prefix(6)) { t in
                                VStack(spacing:8) {
                                    ZStack {
                                        Circle().fill(LinearGradient(colors:t.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:46,height:46)
                                        Image(systemName:t.category.icon).font(.system(size:19)).foregroundColor(.white)
                                    }
                                    Text(t.name).font(.system(size:11,weight:.bold)).lineLimit(1)
                                    HStack(spacing:2) { Image(systemName:"arrow.up.right").font(.system(size:9)); Text(t.weeklyGrowth.percentFormatted).font(.system(size:11,weight:.bold)) }.foregroundColor(.green)
                                }.padding(.horizontal,12).padding(.vertical,12).cardStyle(cornerRadius:14).onTapGesture { HapticFeedback.light(); sel=t }
                            }
                        }.padding(.horizontal,16)
                    }
                    LazyVStack(spacing:10) {
                        ForEach(ts.trending.indices,id:\.self) { i in
                            let t = ts.trending[i]
                            HStack(spacing:12) {
                                Text(i < 3 ? ["🥇","🥈","🥉"][i]:"#\(i+1)").font(i < 3 ? .system(size:20):.system(size:13,weight:.bold)).frame(width:34)
                                ZStack {
                                    RoundedRectangle(cornerRadius:12,style:.continuous)
                                        .fill(LinearGradient(colors:t.category.gradient,startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:44,height:44)
                                    Image(systemName:t.category.icon).font(.system(size:18)).foregroundColor(.white)
                                }
                                VStack(alignment:.leading,spacing:3) {
                                    Text(t.name).font(.system(size:14,weight:.bold))
                                    HStack(spacing:5) {
                                        Image(systemName:"star.fill").font(.system(size:9)).foregroundColor(.yellow)
                                        Text(t.formattedRating).font(.system(size:11)).foregroundColor(.secondary)
                                        Text("·").foregroundColor(.secondary)
                                        Text(t.category.localizedName).font(.system(size:11)).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment:.trailing,spacing:1) {
                                    HStack(spacing:2) { Image(systemName:"arrow.up.right").font(.system(size:11)); Text(t.weeklyGrowth.percentFormatted).font(.system(size:13,weight:.bold)) }.foregroundColor(.green)
                                    Text(L("weekly_growth")).font(.system(size:9)).foregroundColor(.secondary)
                                }
                            }.padding(13).cardStyle()
                                .opacity(animated ? 1:0).offset(x:animated ? 0:-30)
                                .animation(.spring(response:0.45,dampingFraction:0.8).delay(Double(i)*0.05),value:animated)
                                .onTapGesture { HapticFeedback.light(); sel=t }
                        }
                    }.padding(.horizontal,16)
                    Color.clear.frame(height:80)
                }.padding(.top,8)
            }
            .navigationTitle(L("nav_trending")).navigationBarTitleDisplayMode(.large)
        }
        .sheet(item:$sel) { DetailView(tool:$0) }
        .onAppear { withAnimation(.spring(response:0.5,dampingFraction:0.8).delay(0.1)) { animated=true } }
    }
}
struct TStat: View {
    let value:String; let label:String; let color:Color
    var body: some View {
        VStack(spacing:4) {
            Text(value).font(.system(size:19,weight:.black,design:.rounded)).foregroundColor(color)
            Text(label).font(.system(size:11,weight:.medium)).foregroundColor(.secondary)
        }.frame(maxWidth:.infinity).padding(.vertical,14).cardStyle()
    }
}

// MARK: - Favorites
struct FavoritesView: View {
    @EnvironmentObject var ts:ToolsService
    @EnvironmentObject var appState:AppState
    @State private var sel:DevTool? = nil
    var body: some View {
        NavigationStack {
            Group {
                if ts.favoriteTools.isEmpty {
                    VStack(spacing:18) {
                        ZStack { Circle().fill(Color.red.opacity(0.1)).frame(width:90,height:90); Image(systemName:"heart.slash.fill").font(.system(size:38)).foregroundColor(.red.opacity(0.5)) }
                        Text(L("favorites_empty")).font(.system(size:20,weight:.bold))
                        Text(L("favorites_empty_desc")).font(.system(size:14)).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal,40)
                    }.frame(maxWidth:.infinity,maxHeight:.infinity)
                } else {
                    ScrollView(showsIndicators:false) {
                        LazyVStack(spacing:12) {
                            ForEach(ts.favoriteTools) { t in
                                LCard(tool:t).onTapGesture { HapticFeedback.light(); sel=t }
                                    .swipeActions(edge:.trailing) {
                                        Button(role:.destructive) { HapticFeedback.medium(); ts.toggleFavorite(t) } label: { Label("Remove",systemImage:"heart.slash.fill") }
                                    }
                            }
                        }.padding(.horizontal,16).padding(.top,8)
                        Color.clear.frame(height:90)
                    }
                }
            }
            .navigationTitle(L("favorites_title")).navigationBarTitleDisplayMode(.large)
        }
        .sheet(item:$sel) { DetailView(tool:$0) }
    }
}

// MARK: - Settings
struct SettingsView: View {
    @EnvironmentObject var appState:AppState
    @EnvironmentObject var userTracker:UserTracker
    var body: some View {
        NavigationStack {
            List {
                Section { ForEach(AppLanguage.allCases) { lang in
                    Button { HapticFeedback.light(); appState.setLanguage(lang) } label: {
                        HStack {
                            Text(lang.flag).font(.system(size:22))
                            Text(lang.displayName).font(.system(size:15,weight:.medium)).foregroundColor(.primary)
                            Spacer()
                            if appState.selectedLanguage==lang { Image(systemName:"checkmark.circle.fill").foregroundColor(.blue) }
                        }
                    }
                }} header: { Label(L("settings_language"),systemImage:"globe") }
                
                Section { Toggle(isOn:Binding(get:{appState.isDarkMode},set:{_ in appState.toggleDarkMode()})) {
                    HStack { Image(systemName:appState.isDarkMode ? "moon.fill":"sun.max.fill").foregroundColor(appState.isDarkMode ? .purple:.yellow); Text(L("settings_dark_mode")).foregroundColor(.primary) }
                }} header: { Label(L("settings_theme"),systemImage:"paintpalette") }
                
                Section {
                    HStack { Label(L("settings_user_count"),systemImage:"person.3.fill"); Spacer(); Text("\(userTracker.totalUsers.formattedWithCommas)").font(.system(size:14,weight:.bold)).foregroundColor(.blue) }
                    HStack { Label(L("settings_user_id"),systemImage:"person.badge.key.fill"); Spacer(); Text(String(userTracker.userId.prefix(8))+"...").font(.system(size:12,weight:.medium,design:.monospaced)).foregroundColor(.secondary) }
                    HStack { Label(L("home_last_visit"),systemImage:"clock.fill"); Spacer(); Text(userTracker.formattedLastVisit(for:appState.selectedLanguage)).font(.system(size:11)).foregroundColor(.secondary) }
                } header: { Label("Statistics",systemImage:"chart.bar.fill") }
                
                Section {
                    HStack { Label(L("settings_version"),systemImage:"info.circle.fill"); Spacer(); Text("1.0.0").foregroundColor(.secondary) }
                } header: { Label(L("settings_about"),systemImage:"info.circle") }
            }
            .navigationTitle(L("settings_title")).navigationBarTitleDisplayMode(.large)
        }
    }
}

