import SwiftUI

struct StartView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Spacer().frame(width: 0, height: 10)
                    Text(dataModel.appText.welcomeHeader).font(headerFont).padding(.all, 20).foregroundColor(headerColor)
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
            }
            .background(forstColor)  
            VStack {
                Text(dataModel.appText.startPage).font(introFont).padding(15)
                Link("Homepage Forst", destination: URL(string: dataModel.appText.homepageForst)!).buttonStyle(.borderedProminent).tint(forstColor)
            }
            Spacer()
        }
    }
}
