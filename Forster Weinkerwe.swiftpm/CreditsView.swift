import SwiftUI

struct CreditsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Spacer().frame(width: 0, height: 10)
                    Text("Danksagung").font(headerFont).padding(.all, 20).foregroundColor(headerColor)
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
                Text(dataModel.appText.creditsHeader).font(introFont).padding(15)
                ForEach(dataModel.creditsData) { credit in
                    VStack {
                        Link("\(credit.text)", destination: URL(string: "\(credit.link)")!).buttonStyle(.borderedProminent).tint(forstColor)
                    }
                }
            }
            Spacer()
        }
    }
}
