import SwiftUI

class InterestCell: UICollectionViewCell {
    
    static let id = "Interest"
    lazy private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    func setup(text: String) {
        label.text = text
    }
    
    func toggleSelected() {
        if isSelected {
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
}

struct InterestCollection: UIViewRepresentable {
    
    @Binding var interests: [Interest]
    
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
        
        @Binding private var interests: [Interest]
        
        init(interests: Binding<[Interest]>) {
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
        cell.setup(text: interests[indexPath.row].name)
        return cell
    }
}

extension InterestCollection.Coordinator: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestCell
        cell.toggleSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestCell
        cell.toggleSelected()
    }
}

extension InterestCollection.Coordinator: UICollectionViewDelegateFlowLayout {
    
}
