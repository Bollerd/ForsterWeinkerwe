import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct CreditsElement: Codable {
    let text: String
    let link: String
}

typealias CreditsRemote = [CreditsElement]

struct KerweLocationElement: Codable {
    let name: String
    let latitude, longitude: Double
    let opening, homepage, description, systemName: String
    let imageColor: ImageColor
}

enum ImageColor: String, Codable {
    case infoColor = "infoColor"
    case mealsColor = "mealsColor"
    case restaurantColor = "restaurantColor"
    case standColor = "standColor"
}

typealias KerweLoctionRemote = [KerweLocationElement]

struct AppTextElement: Codable {
    let startPage: String
    let creditsHeader: String
    let homepageForst: String
    let welcomeHeader: String
    let appMainTitle: String
    let appSubTitle: String
    let appDate: String
}

typealias AppTextRemote = AppTextElement

struct ScheduleElement: Codable {
    let overviewJSON: OverviewJSON
    
    enum CodingKeys: String, CodingKey {
        case overviewJSON = "OverviewJSON"
    }
}

struct OverviewJSON: Codable {
    let date, headline: String
    let rowsJSON: [RowsJSON]
}

struct RowsJSON: Codable {
    let overviewRowJSON: OverviewRowJSON
    
    enum CodingKeys: String, CodingKey {
        case overviewRowJSON = "OverviewRowJSON"
    }
}

struct OverviewRowJSON: Codable {
    let showImage: Bool
    let systemName, text: String
}

typealias ScheduleRemote = [ScheduleElement]

class DataModel: ObservableObject {
    private let enableRemoteLoading = true
    private let remoteHost = "https://ios.dbweb.info/apps/"
    @Published var dateString = ""
   // @Published var dateStringTest = ""
    @Published var annotations:[KerweLocation] = 
    [
        KerweLocation(name: "Zum Schockelgaul", coordinate: CLLocationCoordinate2D(latitude: 49.428064, longitude: 8.188584), opening: "Do-Mo 17:00", homepage: "www.zum-schockelgaul.de", description: "Cordon bleu. Pfälzer Spezialitäten. Forster Weine.",image: Image(systemName: "1.square.fill"),imageColor: restaurantColor)
    ]
    
    @Published var overviewData:[Overview] = [
        Overview(date: "Donnerstag 3. August 2023", headline: "", rows: [OverviewRow(showImage: true, image: Image(systemName: "5.square.fill"), text: "ab 17:30 | Aufschlag Tennisclub Forst")])
    ]
    
    @Published var todayData:[Overview] = [
        Overview(date: "Donnerstag 3. August 2023", headline: "", rows: [OverviewRow(showImage: true, image: Image(systemName: "5.square.fill"), text: "ab 17:30 | Aufschlag Tennisclub Forst")])
    ]
    
    @Published var creditsData:[Credits] = [Credits(text: "Weingut Acham-Magin", link: "https://www.acham-magin.de")
    ]
    
    @Published var appText = Texte(startPage: "", creditsHeader: "", homepageForst: "https://www.forst-pfalz.de", welcomeHeader: "", appMainTitle: "", appSubTitle: "", appDate: "")
    
    public var foundAny: Bool {
        get {
            if todayData.count > 0 {
                return true
            } else {
                return false
            }
        }
    }
    
    init() {
        getTodayDate()
        Task {
            do {
                guard let fileUrlTexte = Bundle.main.url(forResource: "kerwetexte", withExtension: "json") else {
                    return
                }
                guard let fileUrlCredits = Bundle.main.url(forResource: "credits", withExtension: "json") else {
                    return
                }
                guard let fileUrlAnnotations = Bundle.main.url(forResource: "kerwelocations", withExtension: "json") else {
                    return
                }
                guard let fileUrlSchedule = Bundle.main.url(forResource: "schedule", withExtension: "json") else {
                    return
                }
                let contentTexte = try String(contentsOf: fileUrlTexte)
                let contentCredits = try String(contentsOf: fileUrlCredits)
                let contentAnnotations = try String(contentsOf: fileUrlAnnotations)
                let contentSchedule = try String(contentsOf: fileUrlSchedule)
                
                let onlineAppText:AppTextElement = try JSONDecoder().decode(AppTextRemote.self, from: Data(contentTexte.utf8))
                let onlineCredits:[CreditsElement] = try JSONDecoder().decode(CreditsRemote.self, from: Data(contentCredits.utf8))
                let onlineLocations:[KerweLocationElement] = try JSONDecoder().decode(KerweLoctionRemote.self, from: Data(contentAnnotations.utf8))
                let onlineSchedule:[ScheduleElement] = try JSONDecoder().decode(ScheduleRemote.self, from: Data(contentSchedule.utf8))
                
                DispatchQueue.main.async {
                    self.appText = Texte(startPage: onlineAppText.startPage, creditsHeader: onlineAppText.creditsHeader, homepageForst: onlineAppText.homepageForst, welcomeHeader: onlineAppText.welcomeHeader, appMainTitle: onlineAppText.appMainTitle,appSubTitle: onlineAppText.appSubTitle,appDate: onlineAppText.appDate)
                    self.creditsData.removeAll()
                    onlineCredits.forEach { onlineCredit in
                        self.creditsData.append(Credits(text: onlineCredit.text, link: onlineCredit.link))
                    }
                    self.annotations.removeAll()
                    onlineLocations.forEach { location in
                        var imageColor = self.getColor(colorName: location.imageColor)
                        self.annotations.append(KerweLocation(name: location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), opening: location.opening, homepage: location.homepage, description: location.description,image: Image(systemName: location.systemName),imageColor: imageColor))
                    }
                    self.overviewData.removeAll()
                    onlineSchedule.forEach { day in
                        var rows = [OverviewRow]()
                        day.overviewJSON.rowsJSON.forEach { row in
                            rows.append(OverviewRow(showImage: row.overviewRowJSON.showImage, image: Image(systemName: row.overviewRowJSON.systemName), text: row.overviewRowJSON.text))
                        }
                        self.overviewData.append(Overview(date: day.overviewJSON.date, headline: day.overviewJSON.headline, rows: rows))
                    }
                }
                getToday()
            } catch {
                print(error)
            }    
        }
        
        if enableRemoteLoading == true {
            Task {
                await loadCredits()
                await loadTexte()
                await loadSchedules()
                await loadKerweLocations()
            }    
        }
    }
    
    // get the date of today in formatted way
    func getTodayDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "cccc d. MMMM yyyy"
        let date = dateFormatter.string(from: Date())
        dateString = "\(date)"
        /*
        let dateFormatterTest = DateFormatter()
        dateFormatterTest.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatterTest.date(from: "2023-08-02")
        print(date2)
        
        let date3 = dateFormatter.string(from: date2!)
        print(date3)
        dateStringTest = "\(date2)"
        testDate()
         */
    }
  /*  
    func testDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = "2023-01-16"
        let date = dateFormatter.date(from: dateString)
        print(date) // Optional(2023-01-16 00:10:00 +0000)
    }
    */
    
    // get the overview data for the today view
    func getToday() {
        getTodayDate()
        todayData.removeAll(keepingCapacity: false)
        overviewData.forEach { day in
            if (day.date == dateString) {
                todayData.append(day)    
            }
        }
    }
    
    func loadCredits() async {
        let url = URL(string: "\(remoteHost)credits.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            let onlineCredits:[CreditsElement] = try JSONDecoder().decode(CreditsRemote.self, from: data)
            
            DispatchQueue.main.async {
                self.creditsData.removeAll()
                onlineCredits.forEach { onlineCredit in
                    self.creditsData.append(Credits(text: onlineCredit.text, link: onlineCredit.link))
                }
            }
        }
        catch {
            print(error)
        }
    }
    
     func loadTexte() async {
        let url = URL(string: "\(remoteHost)kerwetexte.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            let onlineAppText:AppTextElement = try JSONDecoder().decode(AppTextElement.self, from: data)
            
            DispatchQueue.main.async {
                self.appText = Texte(startPage: onlineAppText.startPage, creditsHeader: onlineAppText.creditsHeader, homepageForst: onlineAppText.homepageForst, welcomeHeader: onlineAppText.welcomeHeader, appMainTitle: onlineAppText.appMainTitle,appSubTitle: onlineAppText.appSubTitle,appDate: onlineAppText.appDate)
            }
        }
        catch {
            print("run into error")
            print(error)
        }
    }
    
     func loadKerweLocations() async  {
        let url = URL(string: "\(remoteHost)kerwelocations.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            let onlineLocations:[KerweLocationElement] = try JSONDecoder().decode(KerweLoctionRemote.self, from: data)
            
            DispatchQueue.main.async {
                self.annotations.removeAll()
                onlineLocations.forEach { location in
                    var imageColor = self.getColor(colorName: location.imageColor)
                    self.annotations.append(KerweLocation(name: location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), opening: location.opening, homepage: location.homepage, description: location.description,image: Image(systemName: location.systemName),imageColor: imageColor))
                }
            }            
        }
        catch {
            print("run into error")
            print(error)
        }
    }
    
     func loadSchedules() async {
        let url = URL(string: "\(remoteHost)schedule.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            let onlineSchedule:[ScheduleElement] = try JSONDecoder().decode(ScheduleRemote.self, from: data)
            
            DispatchQueue.main.async {
                self.overviewData.removeAll()
                onlineSchedule.forEach { day in
                    var rows = [OverviewRow]()
                    day.overviewJSON.rowsJSON.forEach { row in
                        rows.append(OverviewRow(showImage: row.overviewRowJSON.showImage, image: Image(systemName: row.overviewRowJSON.systemName), text: row.overviewRowJSON.text))
                    }
                    self.overviewData.append(Overview(date: day.overviewJSON.date, headline: day.overviewJSON.headline, rows: rows))
                }
            }            
        }
        catch {
            print("run into error")
            print(error)
        }
    }
    
    func getColor(colorName: ImageColor) -> Color {
        var imageColor = headerColor
        
        switch colorName {
        case .infoColor:
            imageColor = infoColor
        case .mealsColor:
            imageColor = mealsColor
        case .restaurantColor:
            imageColor = restaurantColor
        case .standColor:
            imageColor = standColor
        }
        return imageColor
    }
}
