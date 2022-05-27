import SwiftUI

class InterestCell: UICollectionViewCell {
    
    static let id = "Interest"
    lazy private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(text: String, selected: Bool) {
        label.text = text
        if selected {
            backgroundColor = .blue
            layer.borderWidth = 0
            label.textColor = .white
            label.font = label.font.withWeight(.regular)
        } else {
            backgroundColor = .white
            layer.borderWidth = 1
            label.textColor = .black
            label.font = label.font.withWeight(.light)
        }
    }
    
    func setup(with interest: SelectableInterest) {
        setup(text: interest.value.name, selected: interest.selected)
    }
}

struct SelectableInterest {
    var selected = false
    let value: Interest
}

struct InterestCollection: UIViewRepresentable {
    
    @Binding var interests: [SelectableInterest]
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.allowsMultipleSelection = true
        collection.dataSource = context.coordinator
        collection.delegate = context.coordinator
        collection.register(InterestCell.self, forCellWithReuseIdentifier: InterestCell.id)
        return collection
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(interests: $interests)
    }
    
    class Coordinator: NSObject {
        
        @Binding private var interests: [SelectableInterest]
        
        init(interests: Binding<[SelectableInterest]>) {
            self._interests = interests
            super.init()
        }
    }
}

extension InterestCollection.Coordinator: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestCell.id, for: indexPath) as! InterestCell
        cell.setup(with: interests[indexPath.row])
        return cell
    }
}

extension InterestCollection.Coordinator: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        $interests[indexPath.row].selected.wrappedValue.toggle()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        $interests[indexPath.row].selected.wrappedValue.toggle()
    }
}
