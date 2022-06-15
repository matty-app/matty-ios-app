import SwiftUI

struct HeaderImage: View {
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
}

struct LargeTitle: View {
    
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle)
            .padding(.horizontal)
    }
}

struct InputField: View {
    
    private let title: String
    @Binding private var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        TextField(title, text: $text)
            .padding()
            .frame(height: 50)
            .background(.regularMaterial)
            .background(in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
    }
}

struct ActionButton: View {
    
    private let title: String
    private let disabled: Bool
    private let action: () -> Void
    
    init(_ title: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.blue)
                .foregroundColor(.white)
                .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}

struct FormActionButton: View {
    
    private let title: String
    private let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Section {
            Button(action: action) {
                Text(title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .listRowInsets(.zero)
        }
    }
}

extension EdgeInsets {
    
    static var zero: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

struct TextEdit: View {
    
    private let placeholder: String
    @Binding private var text: String
    
    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var hasPlaceholder: Bool {
        return text == placeholder
    }
    
    var body: some View {
        TextEditor(text: $text)
            .foregroundColor(hasPlaceholder ? .gray : .primary)
            .onAppear {
                if text.isEmpty {
                    text = placeholder
                }
            }
            .onTapGesture {
                if hasPlaceholder {
                    text = ""
                }
            }
    }
}

extension AnyTransition {
    
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

struct CloseButton: View {
    
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.black)
        }
    }
}

struct CancelButton: View {
    
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Cancel")
        }
    }
}

struct EventCard: View {
    
    private var event: Event
    private var action: () -> ()
    
    init(for event: Event, action: @escaping () -> ()) {
        self.event = event
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text("\(event.interest.emoji) \(event.interest.name)")
                            .font(.footnote)
                    }
                    Spacer()
                    TimeBadge(event.date)
                }
                Text(event.description)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 1)
                HStack(alignment: .top) {
                    Text(event.locationName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .underline()
                    Spacer()
                    Text(event.formattedDate)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}

struct TimeBadge: View {
    
    private var date: Date?
    
    init(_ date: Date?) {
        self.date = date
    }
    
    var body: some View {
        Text(timeUntil(date))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .font(.headline)
            .timeBadgeStyle(TimeBadge.Style.from(date))
            .clipShape(Capsule())
    }
    
    private func timeUntil(_ date: Date?) -> String {
        if let date = date {
            if date.secondsFromNow < 60 { return "1m" }
            
            let minutes = date.minutesFromNow
            if minutes < 60 { return "\(minutes)m" }
            
            let hours = date.hoursFromNow
            if hours < 24 { return "\(hours)h" }
            
            let years = date.yearsFromNow
            if years > 0 { return "\(years)y" }
            
            return "\(date.daysFromNow)d"
        } else {
            return "Now"
        }
    }
}

extension TimeBadge {
    
    class Style {
        
        static let now = Style(backgroundColor: .red, foregroundColor: .white)
        static let soon = Style(backgroundColor: .yellow, foregroundColor: .black)
        static let later = Style(backgroundColor: .green, foregroundColor: .black)
        
        let backgroundColor: Color
        let foregroundColor: Color
        
        private init(backgroundColor: Color, foregroundColor: Color) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
        }
        
        static func from(_ date: Date?) -> Style {
            if let date = date {
                if date.hoursFromNow < 24 {
                    return .soon
                } else {
                    return .later
                }
            } else {
                return .now
            }
        }
    }
}

extension View {
    
    func timeBadgeStyle(_ style: TimeBadge.Style) -> some View {
        self
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
    }
}
