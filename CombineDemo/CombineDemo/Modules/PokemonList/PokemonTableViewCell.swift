//
//  PokemonTableViewCell.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit
import Combine

class PokemonTableViewCell: UITableViewCell {
    lazy var imageLoader: ImageLoading = ImageLoader()
    lazy var cancellables: Set<AnyCancellable> = []

    private enum Constants {
        static let height: CGFloat = 100
        static let spacing: CGFloat = 8
    }

    lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.height / 2
        imageView.layer.borderWidth = 0.25
        imageView.layer.borderColor = UIColor.link.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        imageView?.image = nil
        imageLoader.cancelImageLoading()
    }

    private func setupViews() {
        backgroundColor = .systemBackground

        addSubview(pokemonImageView)
        addSubview(pokemonNameLabel)

        NSLayoutConstraint.activate([
            pokemonImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.spacing),
            pokemonImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spacing*2),
            pokemonImageView.heightAnchor.constraint(equalToConstant: Constants.height),
            pokemonImageView.widthAnchor.constraint(equalToConstant: Constants.height),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: Constants.spacing*2),
            pokemonNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pokemonNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(for pokemon: Pokemon.ApiResponse.Result) {
        pokemonNameLabel.text = pokemon.name.capitalized

        downloadImage(for: pokemon)
    }

    private func downloadImage(for pokemon: Pokemon.ApiResponse.Result) {
        guard let imageURL = pokemon.imageURL else { return }

        defer { imageLoader.loadImage(imageURL) }

        imageLoader
            .imageLoadingPublisher
            .sink { [weak self] in self?.pokemonImageView.image = $0 }
            .store(in: &cancellables)
    }
}

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension PokemonTableViewCell: Reusable {}

extension Pokemon.ApiResponse.Result {
    private enum Constants {
        static let imageURLPath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
    }

    var imageURL: URL? {
        guard let pokemonID = Int(url.lastPathComponent) else { return nil }

        let imageURLString = Constants.imageURLPath + "\(pokemonID).png"

        return URL(string: imageURLString)
    }
}
