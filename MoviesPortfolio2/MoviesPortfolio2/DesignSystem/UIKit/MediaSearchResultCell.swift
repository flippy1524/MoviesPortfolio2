import MoviesCore
import UIKit

final class MediaSearchResultCell: UITableViewCell {
  static let reuseIdentifier = "MediaSearchResultCell"

  private let posterImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = AppMetrics.cornerRadius / 2
    imageView.backgroundColor = AppColors.cardBackground
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .headline)
    label.textColor = AppColors.primaryText
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let overviewLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = AppColors.secondaryText
    label.numberOfLines = 2
    label.lineBreakMode = .byTruncatingTail
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    return label
  }()

  private let kindLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .caption1)
    label.textColor = AppColors.secondaryText
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentHuggingPriority(.required, for: .vertical)
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private let favoriteButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  var onFavoriteTap: (() -> Void)?
  private var imageLoadTask: Task<Void, Never>?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageLoadTask?.cancel()
    imageLoadTask = nil
    posterImageView.image = nil
    titleLabel.text = nil
    overviewLabel.text = nil
    kindLabel.text = nil
    favoriteButton.isHidden = true
    onFavoriteTap = nil
  }

  func configure(with item: SearchResultDisplayModel) {
    titleLabel.text = item.title
    overviewLabel.text = item.overview
    kindLabel.text = item.kind == .movie ? "Movie" : "TV Series"

    let showsFavorite = item.kind == .movie
    favoriteButton.isHidden = !showsFavorite
    let symbol = item.isFavorite ? "heart.fill" : "heart"
    favoriteButton.setImage(UIImage(systemName: symbol), for: .normal)
    favoriteButton.tintColor = item.isFavorite ? AppColors.accent : AppColors.secondaryText
  }

  func setPosterImage(path: String?, layoutWidth: CGFloat, imageCache: ImageCache) {
    imageLoadTask?.cancel()
    posterImageView.image = nil

    guard let path else { return }

    let urls = ImageURLBuilder.posterURLs(path: path, layoutWidth: layoutWidth)
    imageLoadTask = Task { @MainActor in
      for await event in await imageCache.loadProgressively(
        lowResolutionURL: urls.low,
        highResolutionURL: urls.high
      ) {
        guard !Task.isCancelled else { return }
        if let image = UIImage(data: event.data) {
          posterImageView.image = image
        }
      }
    }
  }

  private func setup() {
    backgroundColor = AppColors.background
    selectionStyle = .default

    contentView.addSubview(posterImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(overviewLabel)
    contentView.addSubview(kindLabel)
    contentView.addSubview(favoriteButton)

    favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

    let posterSize = AppMetrics.searchPosterWidth

    NSLayoutConstraint.activate([
      posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
      posterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      posterImageView.widthAnchor.constraint(equalToConstant: posterSize),
      posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1 / AppMetrics.posterAspectRatio),

      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
      favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppSpacing.md),
      favoriteButton.widthAnchor.constraint(equalToConstant: 28),
      favoriteButton.heightAnchor.constraint(equalToConstant: 28),

      titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: AppSpacing.md),
      titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -AppSpacing.xs),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppSpacing.md),

      kindLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      kindLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      kindLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppSpacing.md),

      overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AppSpacing.xs),
      overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: kindLabel.topAnchor, constant: -AppSpacing.xs)
    ])
  }

  @objc
  private func favoriteTapped() {
    onFavoriteTap?()
  }
}
