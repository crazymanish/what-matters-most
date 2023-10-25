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

    func configure(for pokemon: Pokemon.ApiResponse.Info, pokemonColor: UIColor? = nil) {
        downloadImage(pokemon.imageURL)

        pokemonNameLabel.text = pokemon.capitalizedName
        pokemonImageView.backgroundColor = pokemonColor?.withAlphaComponent(0.1) ?? .systemBackground
    }

    private func downloadImage(_ imageURL: URL?) {
        guard let imageURL else { return }

        defer { imageLoader.loadImage(imageURL) }

        imageLoader
            .downloadedImagePublisher
            .assign(to: \.image, on: pokemonImageView)
            .store(in: &cancellables)
    }
}
