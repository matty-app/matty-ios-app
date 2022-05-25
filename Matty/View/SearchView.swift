import SwiftUI

struct SearchView: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Category(name: "Online", width: 100, background: .yellow, foreground: .black)
                    Category(name: "Offline", width: 260, background: .yellow, foreground: .black)
                }
                HStack {
                    Category(name: "Soccer", width: 260, background: .green, foreground: .black)
                    Category(name: "Tennis", width: 100, background: .green, foreground: .black)
                }
                HStack {
                    Category(name: "CS:GO", width: 100, background: .cyan, foreground: .black)
                    Category(name: "Fortnite", width: 260, background: .cyan, foreground: .black)
                }
                Spacer()
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
        }
    }
    
    func Category(name: String, width: CGFloat, background: Color, foreground: Color) -> some View {
        Text(name)
            .frame(width: width, height: 100)
            .background(background)
            .foregroundColor(foreground)
            .font(.headline)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
