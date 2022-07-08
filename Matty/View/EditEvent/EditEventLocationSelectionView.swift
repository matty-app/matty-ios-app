import SwiftUI
import MapKit

struct EditEventLocationSelectionView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject private var mapSearchService: MapSearchService
    @State private var address = ""
    @State private var locationName = ""
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var region: MKCoordinateRegion
    
    typealias CompletionHandler = (String, String, CLLocationCoordinate2D) -> ()
    
    private var locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    private var completionHandler: CompletionHandler
    
    init(coordinates: CLLocationCoordinate2D? = nil, completionHandler: @escaping CompletionHandler) {
        var center = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        if let coordinates = coordinates {
            center = coordinates
        }
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        _region = State(initialValue: region)
        self.mapSearchService = MapSearchService(region: region)
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        ZStack {
            MapView()
            MapPin()
            VStack {
                LocationTitle()
                Spacer()
                HStack {
                    BackButton()
                    Spacer()
                    MyLocationButton()
                }
                VStack {
                    SearchBar()
                    SearchResults()
                }
                .background(.white)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func MapView() -> some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true
        )
        .onChange(of: region) { newValue in
            locationName = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if newValue == region {
                    let location = CLLocation.from(region)
                    geocoder.reverseGeocodeLocation(location) { placemarks, error in
                        if let placemark = placemarks?.first {
                            locationName = placemark.shortAddress
                            address = placemark.address
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func MapPin() -> some View {
        VStack {
            Image(systemName: "mappin")
                .font(.system(size: 30))
                .foregroundColor(.red)
            Ellipse()
                .frame(width: 30, height: 15)
                .offset(x: 0, y: -15)
                .opacity(0.1)
        }
    }
    
    private func LocationTitle() -> some View {
        HStack {
            Text(locationName)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
    
    private func MapButton(image: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: image)
                .font(.system(size: 40))
                .symbolRenderingMode(.hierarchical)
                .shadow(radius: 5)
                .padding(5)
        }
    }
    
    private func BackButton() -> some View {
        MapButton(image: "arrowshape.turn.up.backward.circle.fill") {
            dismissView()
        }.foregroundColor(.gray)
    }
    
    private func MyLocationButton() -> some View {
        MapButton(image: "location.circle.fill") {
            locationManager.requestWhenInUseAuthorization()
            if let location = locationManager.location {
                region.center = location.coordinate
            }
        }
    }
    
    private func SearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Moscow, Butovo", text: $searchText)
                .onChange(of: searchText) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if newValue == searchText {
                            mapSearchService.request(searchText)
                        }
                    }
                }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    mapSearchService.reset()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            Button("Submit") {
                completionHandler(locationName, address, region.center)
                dismissView()
            }
        }
        .padding()
    }
    
    private func SearchResults() -> some View {
        LazyVStack {
            ForEach(mapSearchService.results.prefix(5), id: \.self) { item in
                Divider()
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .padding(.leading)
                    VStack {
                        Text(item.title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.subtitle)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onTapGesture {
                    searchText = item.title
                    mapSearchService.request(searchText)
                    mapSearchService.request(from: item) { region in
                        self.region = region
                    }
                }
            }
        }
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditEventLocationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditEventLocationSelectionView { _, _, _ in }
        }
    }
}
