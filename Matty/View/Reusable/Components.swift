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
    private let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
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
