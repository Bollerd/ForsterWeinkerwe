import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var dataModel: DataModel
    
    @State private var updateView = false
    var region: Binding<MKCoordinateRegion>? {
        guard let location = locationManager.location else {
            return MKCoordinateRegion.forstRegion().getBinding()
        }
        
        var region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        
        if regionInitiated == false {
            initialLocation = region
            regionInitiated = true
        } else {
            region = initialLocation
        }
        return region.getBinding()
    }
    //(49.4252820, 8.1892102)
    var regionForst: Binding<MKCoordinateRegion>? {
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.4252820, longitude:  8.1892102), latitudinalMeters: 400, longitudinalMeters: 400)
        
        if regionInitiated == false {
            initialLocation = region
            regionInitiated = true
        } else {
            region = initialLocation
        }
        return region.getBinding()
    }
    
    @State private var presentSheet = false
    @State private var presentOverview = false
    @State private var presentToday = false
    @State private var presentCredits = false
    @State private var kerweLocationTapped = defaultLocation
    @State private var initialInfoDisplayed = true
    
    var regionUsed:  Binding<MKCoordinateRegion>? {
        get {
            guard let location = locationManager.location else {
                return MKCoordinateRegion.forstRegion().getBinding()
            }
            //   print(location.coordinate)
            if location.coordinate.latitude >= 49.418 && location.coordinate.latitude <= 49.434 && location.coordinate.longitude >= 8.18 && location.coordinate.longitude <= 8.2 {
                return region    
            } else {
                return regionForst
            }
        }
    }
    
    //  @State var annotationWrapper: [KerweLocation]
    
    var body: some View {
        if let region = regionUsed {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text(dataModel.appText.appMainTitle).foregroundColor(headerColor).font(headerFont).padding(.top, 10)
                        Text(dataModel.appText.appSubTitle).foregroundColor(headerColor)
                        Text(dataModel.appText.appDate).font(.caption2).foregroundColor(headerColor).padding(.bottom, 10)
                    }
                    Spacer()
                }.background(forstColor)
                ZStack {
                    Map(coordinateRegion: region,showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: dataModel.annotations) {
                        kerweLocation in MapAnnotation(coordinate: kerweLocation.coordinate) {
                            kerweLocation.image
                                .foregroundColor(kerweLocation.imageColor)
                                .font(.title2)
                                .onTapGesture {
                                    kerweLocationTapped = kerweLocation
                                    presentSheet.toggle()
                                }
                        }
                    }.sheet(isPresented: $presentSheet) {
                        InfoView(locationInfo: $kerweLocationTapped).environmentObject(dataModel) .presentationDetents([.medium, .large])
                    }.sheet(isPresented: $presentOverview) {
                        ScheduleView().environmentObject(dataModel).presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
                    }.sheet(isPresented: $presentCredits) {
                        CreditsView().environmentObject(dataModel).presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
                    }.sheet(isPresented: $presentToday) {
                        TodayView().environmentObject(dataModel).presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
                    }.sheet(isPresented: $initialInfoDisplayed) {
                        StartView().environmentObject(dataModel).presentationDetents([.medium, .large]).presentationDragIndicator(.visible).presentationDragIndicator(.visible)
                    }
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                Spacer()
                                Button("Heute") { 
                                    presentToday.toggle()
                                }.buttonStyle(.borderedProminent).tint(forstColor)    
                            }.padding(.horizontal)
                        HStack {
                            Spacer()
                            Button("Programmübersicht") { 
                                presentOverview.toggle()
                            }.buttonStyle(.borderedProminent).tint(forstColor)
                            Button {
                                presentCredits.toggle()
                            } label: { 
                                Image(systemName: "quote.bubble")
                            }.buttonStyle(.borderedProminent).tint(forstColor)
                            Button {
                                regionInitiated = false
                            } label: { 
                                Image(systemName: "paperplane")
                            }.buttonStyle(.borderedProminent).tint(forstColor)
                        }.padding(.horizontal)
                            
                        }
                    }.padding()                            
                }
            }.onAppear {
              //   print("this is onappear")
            }
        } else {
            Text("Keine Region ermittelt")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
