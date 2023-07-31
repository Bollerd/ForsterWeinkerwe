import SwiftUI

struct TodayView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Spacer().frame(width: 0, height: 10)
                    Text("Heute").font(headerFont).padding(.all, 20).foregroundColor(headerColor)
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
       //     Text("\(dataModel.foundAny)" as String)
            //Text("\(dataModel.dateString)" as String)
            //Text("\(dataModel.dateStringTest)" as String)
            if (dataModel.foundAny == true) {
                ScrollView {
                    ForEach(dataModel.todayData) { day in
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
            } else {
                Text("Heute kein Weinfest")
            }
            Spacer()
        }.onAppear(perform: {
            dataModel.getToday()
        })
    }
}
