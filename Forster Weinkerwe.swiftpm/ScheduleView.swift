import SwiftUI

struct ScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Spacer().frame(width: 0, height: 10)
                    Text("Programmübersicht").font(headerFont).padding(.all, 20).foregroundColor(headerColor)
                }
                Spacer()
                if displayCloseButton == true {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle.fill").font(.title)
                            .foregroundColor(.white)
                    }).padding()
                }
            }.background(forstColor)  
            ScrollView {
                ForEach(dataModel.overviewData) { day in
                    VStack {
                        HStack {
                            Text("\(day.date)").font(.title2).padding(.bottom, 8)
                        }
                        if day.headline != "" {
                            HStack {
                                Text("\(day.headline)").fontWeight(.bold)
                            }    
                        }
                        ForEach(day.rows) { row in
                            HStack {
                                if row.showImage == true {
                                    row.image
                                }
                                Text("\(row.text)")
                            }    
                        }
                        Spacer().frame(height: 10)
                    }
                }
            }
            Spacer()
        }
    }
}
