import SwiftUI
import MapKit

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var locationInfo: KerweLocation
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Spacer().frame(width: 0, height: 10)
                    Text("\(locationInfo.name)").font(headerFont).padding(.all, 20).foregroundColor(headerColor)
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
            Text("\(locationInfo.opening)").font(timeFont)
            Text("\(locationInfo.description)").padding(.all, 20)
            if locationInfo.homepage != "" {
                Link("Webseite", destination: URL(string: "https://\(locationInfo.homepage)")!).buttonStyle(.borderedProminent).tint(forstColor)
            }
            Spacer()
        }
   }
}

struct InfoView_Previews: PreviewProvider {
    @State static var kerweLocation = defaultLocation
    
    static var previews: some View {
       InfoView(locationInfo: $kerweLocation)
    }
}
