//
//  Tetris.swift
//
//  Created by Pedro Saldanha on 07/02/2020.
//  Copyright © 2020 Impossible. All rights reserved.
//

import UIKit
import Lottie
import AudioToolbox

typealias Action = () -> Void

class TetrisViewController: UIViewController {

  //MARK: Auxiliar variables

  var presenter: TetrisPresenter?
  
  private final class NextPiece  {
    //Drawn horizontally
    public class var patternI: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
      return (pattern: [[1, 1, 1, 1]],
              offset: (x: 0, y: 1),
              color: UIColor.tetris_color_1)}

    public class var patternJ: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
      return (pattern: [[0, 0, 1],[1, 1, 1]],
              offset: (x: 0.5, y: 0.5),
              color: UIColor.tetris_color_2)}

    public class var patternL: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
      return (pattern: [[1, 0, 0],[1, 1, 1]],
              offset: (x: 0.5, y: 0.5),
              color: UIColor.tetris_color_3)}

    public class var patternO: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
      return (pattern: [[1, 1],[1, 1]],
              offset: (x: 1, y: 0.5),
              color: UIColor.tetris_color_4)}

    public class var patternS: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
    return (pattern: [[0, 1, 1],[1, 1, 0]],
            offset: (x: 0.5, y: 0.5),
            color: UIColor.tetris_color_5)}

    public class var patternT: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
       return (pattern: [[0, 1, 0],[1, 1, 1]],
               offset: (x: 0.5, y: 0.5),
               color: UIColor.tetris_color_6)}

    public class var patternZ: (pattern: [[Int]], offset: (x: CGFloat, y: CGFloat), color: UIColor) {
          return (pattern: [[1, 1, 0],[0, 1, 1]],
                  offset: (x: 0.5, y: 0.5),
                  color: UIColor.tetris_color_7)}
  }

  private let allNextPieces = [NextPiece.patternI, NextPiece.patternJ, NextPiece.patternL, NextPiece.patternO, NextPiece.patternS, NextPiece.patternT, NextPiece.patternZ]

  private var numberOfNextPieces: Int = 4
  private var nextPieceArray: [[UIView]]!
  private var holdPieceArray: [UIView]!

  private var maxX: CGFloat = 0
  private var maxY: CGFloat = 0
  private var pieceSize: CGFloat = 0
  private var pieceNextSize: CGFloat = 0
  private var mapStartPos: CGPoint = .zero

  private let mapSizeX = 10
  private let mapSizeY = 20

  private let borderInset: CGFloat = -2

  private var mapViews: [[(view: UIView, animation: AnimationView)]]!

  //MARK: UI

  private let background = UIView(frame: CGRect(origin: .zero, size: CGSize.currentWindowSize))

  private let closeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .clear
    button.contentMode = .scaleAspectFit
    button.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .tetrisLightBlueGrey
    button.isUserInteractionEnabled = true
    return button
  }()

  private let pauseButton: HighlightableButton = {
    let button = HighlightableButton()
    button.setTitleColor(.buttonColor, for: .normal)
    button.titleLabel?.font = .tetris24DynamicBold
    button.isEnabled = true
    button.setTitle("PAUSE", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let screenTapView: UIView = {
    let tapView = UIView()
    tapView.translatesAutoresizingMaskIntoConstraints = false
    tapView.isUserInteractionEnabled = true
    tapView.backgroundColor = .clear
    return tapView
  }()

  private let scoreLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let scoreCountLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let levelLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let levelCountLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let timeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let timeCountLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let holdLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .left
    label.sizeToFit()
    return label
  }()

  private let nextLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .tetris24DynamicBold
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let bestLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .tetris24DynamicBold
    label.textColor = .tetrisText
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let mapBorder: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 0
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 3
    return view
  }()

  private let mapOverlay: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
    view.isHidden = true
    return view
  }()

  private let pauseLineLeft: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 3
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  fileprivate let pauseLineRight: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 3
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let gameOverLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .tetris50DynamicBold
    label.textColor = UIColor.black
    label.numberOfLines = 0
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }()

  private let tryAgainLabel: PaddingLabel = {
    let label = PaddingLabel(top: 5, bottom: 5, left: 8, right: 8)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .tetris28DynamicBold
    label.textColor = UIColor.black
    label.numberOfLines = 0
    label.layer.masksToBounds = true
    label.textAlignment = .center
    label.sizeToFit()
    label.layer.borderWidth = 3
    label.layer.borderColor = UIColor.black.cgColor
    label.isUserInteractionEnabled = true
    return label
  }()

  private let nextPiecesBorder: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 0
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 3
    return view
  }()

  private let holdPiecesBorder: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 0
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 3
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    view.isUserInteractionEnabled = true
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)

    presenter = TetrisPresenter(mapSizeX: mapSizeX, mapSizeY: mapSizeY, nextPieces: numberOfNextPieces)
    presenter?.view = self

    setupVars()
    setupBackground()
    setupLabels()
    setupGestures()
    buildMap()
    buildMapOverlay()
    setupTapView()
    setupCloseButton()
    setupPauseButton()
    setupNextPieces()
    setupHoldPiece()

    setupConstraints()

    setupLabelSizes()

    presenter?.loadGame()
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.presenter?.storeGame()
    super.viewWillDisappear(animated)
  }

  @objc func appMovedToBackground() {
    presenter?.setGamePaused(true)
  }

  func setupLabelSizes() {
    scoreLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 6)
    scoreCountLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 5)
    levelLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 6)
    levelCountLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 5)
    timeLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 6)
    timeCountLabel.font = .boldSystemFont(ofSize: nextPiecesBorder.frame.width / 5)
  }

  func setupVars() {
    self.maxX = CGSize.currentWindowSize.width
    self.maxY = CGSize.currentWindowSize.height
    self.pieceSize = min((self.maxX * 0.7) / CGFloat(self.mapSizeX), (self.maxY * 0.8) / CGFloat(self.mapSizeY))
    self.mapStartPos = CGPoint(x: self.maxX * 0.02, y: self.maxY * 0.15)
  }

  func setupBackground() {
    view.addSubview(background)
    background.frame = view.frame
    background.setDiagonalGradient(startColor: .tetrisDarkBlue, endColor: .tetrisBlue)
  }

  func setupLabels() {
    scoreLabel.text = "SCORE:"
    view.addSubview(scoreLabel)
    scoreCountLabel.text = "0"
    view.addSubview(scoreCountLabel)
    levelLabel.text = "LEVEL:"
    view.addSubview(levelLabel)
    levelCountLabel.text = "0"
    view.addSubview(levelCountLabel)
    timeLabel.text = "TIME:"
    view.addSubview(timeLabel)
    timeCountLabel.text = "0:00:00"
    view.addSubview(timeCountLabel)
    nextLabel.text = "NEXT"
    view.addSubview(nextLabel)
    bestLabel.text = "BEST: \(UserDefaults.standard.integer(forKey: "tetrisHighScore"))"
    view.addSubview(bestLabel)
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -relativeWidth(10)),
      closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: relativeWidth(10)),
      closeButton.widthAnchor.constraint(equalToConstant: 54),
      closeButton.heightAnchor.constraint(equalToConstant: 54),

      pauseButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -relativeWidth(10)),
      pauseButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),

      scoreLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      scoreLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      scoreLabel.heightAnchor.constraint(equalToConstant: 20),
      scoreLabel.topAnchor.constraint(equalTo: nextPiecesBorder.bottomAnchor, constant: relativeHeight(6)),

      scoreCountLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      scoreCountLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      scoreCountLabel.heightAnchor.constraint(equalToConstant: 30),
      scoreCountLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: relativeHeight(4)),

      levelLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      levelLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      levelLabel.heightAnchor.constraint(equalToConstant: 20),
      levelLabel.topAnchor.constraint(equalTo: scoreCountLabel.bottomAnchor, constant: relativeHeight(6)),

      levelCountLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      levelCountLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      levelCountLabel.heightAnchor.constraint(equalToConstant: 30),
      levelCountLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: relativeHeight(4)),

      timeLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      timeLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      timeLabel.heightAnchor.constraint(equalToConstant: 20),
      timeLabel.topAnchor.constraint(equalTo: levelCountLabel.bottomAnchor, constant: relativeHeight(6)),

      timeCountLabel.leadingAnchor.constraint(equalTo: mapBorder.trailingAnchor),
      timeCountLabel.trailingAnchor.constraint(equalTo: nextPiecesBorder.trailingAnchor),
      timeCountLabel.heightAnchor.constraint(equalToConstant: 30),
      timeCountLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: relativeHeight(4)),

      nextLabel.bottomAnchor.constraint(equalTo: nextPiecesBorder.topAnchor, constant: -relativeHeight(5)),
      nextLabel.centerXAnchor.constraint(equalTo: nextPiecesBorder.centerXAnchor),

      bestLabel.bottomAnchor.constraint(equalTo: mapBorder.topAnchor, constant: -relativeHeight(5)),
      bestLabel.leadingAnchor.constraint(equalTo: mapBorder.leadingAnchor, constant: relativeWidth(5)),
    ])
  }

  func setupGestures() {
//    let swipeLeft = UISwipeGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.swipeHandler))
//    swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//    screenTapView.addGestureRecognizer(swipeLeft)
//
//    let swipeRight = UISwipeGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.swipeHandler))
//    swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//    screenTapView.addGestureRecognizer(swipeRight)
//
    let tapGesture = UILongPressGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.tapHandler))
    tapGesture.minimumPressDuration = 0.01
    screenTapView.addGestureRecognizer(tapGesture)

    let swipeDown = UISwipeGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.swipeHandler))
    swipeDown.direction = UISwipeGestureRecognizer.Direction.down
    swipeDown.delegate = self
    screenTapView.addGestureRecognizer(swipeDown)

    let panRecognizer = UIPanGestureRecognizer(target: self.presenter, action:  #selector(self.presenter?.pannedFinger))
    panRecognizer.delegate = self
    screenTapView.addGestureRecognizer(panRecognizer)

    let longTapGesture = UILongPressGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.longTap))
    longTapGesture.minimumPressDuration = 0.3
    longTapGesture.delegate = self
    screenTapView.addGestureRecognizer(longTapGesture)
  }

  func setupNextPieces() {
    self.nextPieceArray = Array(repeating: Array(repeating: UIView(), count: allNextPieces.count), count: numberOfNextPieces)

    let nextPieceGridHeight: Int = 3
    let gridIntervalBetweenPieces: CGFloat = 5
    //Takes into account insets on left and right on both borders of main tetris board and next pieces
    let mainTetrisBorderInsetTotal: CGFloat = borderInset * 4
    let marginsXAxis: CGFloat = 10
    var pieceNextSize = pieceSize * 0.8
    let nextPieceBorderWidth = pieceNextSize * 4 + mainTetrisBorderInsetTotal + marginsXAxis
    pieceNextSize -= marginsXAxis / 4
    let singleGridHeight = pieceNextSize * CGFloat(nextPieceGridHeight)
    var nextPiecesBorderHeight = singleGridHeight * CGFloat(numberOfNextPieces)
    nextPiecesBorderHeight += gridIntervalBetweenPieces * CGFloat(numberOfNextPieces - 1)

    nextPiecesBorder.frame = CGRect(x: mapStartPos.x + pieceSize * CGFloat(mapSizeX) + 5, y: mapStartPos.y, width: nextPieceBorderWidth, height: nextPiecesBorderHeight)
    nextPiecesBorder.frame = nextPiecesBorder.frame.insetBy(dx: borderInset, dy: borderInset)

    let startNextPosition = nextPiecesBorder.frame.origin

    for i in 0..<numberOfNextPieces {
      for j in 0..<allNextPieces.count {
        nextPieceArray[i][j] = UIView()
        nextPieceArray[i][j].sizeToFit()
        nextPieceArray[i][j].isHidden = true
        let pattern = allNextPieces[j].pattern
        let pieceOffset = allNextPieces[j].offset
        let pieceColor = allNextPieces[j].color
        let pieceStartPos = (posX: startNextPosition.x + pieceOffset.x * pieceNextSize - borderInset + (marginsXAxis / 2), posY: startNextPosition.y + pieceOffset.y * pieceNextSize + CGFloat(i) * (singleGridHeight + gridIntervalBetweenPieces) - borderInset)
        for k in 0..<pattern.count {
          for (l, value) in pattern[k].enumerated() where value == 1 {
            let piecePartFrame = CGRect(x: pieceStartPos.posX + CGFloat(l) * pieceNextSize, y: pieceStartPos.posY + CGFloat(k) * pieceNextSize, width: pieceNextSize, height: pieceNextSize)
            let piecePartView = UIView(frame: piecePartFrame)
            piecePartView.backgroundColor = pieceColor
            piecePartView.layer.borderWidth = relativeWidth(2)
            piecePartView.layer.borderColor = UIColor.black.cgColor
            piecePartView.layer.cornerRadius = pieceNextSize * 0.2

            piecePartView.layer.shadowOffset = .zero
            piecePartView.layer.shadowColor = UIColor.black.cgColor
            piecePartView.layer.shadowRadius = relativeWidth(2)
            piecePartView.layer.shadowOpacity = 1
            piecePartView.layer.shadowPath = UIBezierPath(roundedRect: piecePartView.bounds, cornerRadius: relativeWidth(pieceSize * 0.2)).cgPath
            nextPieceArray[i][j].addSubview(piecePartView)
          }
        }
        self.view.addSubview(nextPieceArray[i][j])
      }
    }
  }

  private func setupHoldPiece() {
    holdLabel.text = "HOLD"
    view.addSubview(holdLabel)

    let tapGesture = UITapGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.holdPiece))
    holdPiecesBorder.addGestureRecognizer(tapGesture)
    view.addSubview(holdPiecesBorder)

    NSLayoutConstraint.activate([
      holdLabel.bottomAnchor.constraint(equalTo: holdPiecesBorder.topAnchor, constant: -2),
      holdLabel.leadingAnchor.constraint(equalTo: holdPiecesBorder.leadingAnchor, constant: 2)
    ])

    self.holdPieceArray = Array(repeating: UIView(), count: allNextPieces.count)

    let nextPieceGridHeight: Int = 3
    //Takes into account insets on left and right on both borders of main tetris board and next pieces
    let mainTetrisBorderInsetTotal: CGFloat = borderInset * 4
    let marginsXAxis: CGFloat = 10
    var holdPieceSize = pieceSize * 0.8
    let holdPieceBorderWidth = holdPieceSize * 4 + mainTetrisBorderInsetTotal + marginsXAxis
    holdPieceSize -= marginsXAxis / 4
    let singleGridHeight = holdPieceSize * CGFloat(nextPieceGridHeight)

    holdPiecesBorder.frame = CGRect(x: mapStartPos.x + pieceSize * CGFloat(mapSizeX) + 5, y: mapStartPos.y + CGFloat(mapSizeY) * pieceSize - singleGridHeight, width: holdPieceBorderWidth, height: singleGridHeight)
    holdPiecesBorder.frame = holdPiecesBorder.frame.insetBy(dx: borderInset, dy: borderInset)

    let startNextPosition = holdPiecesBorder.frame.origin

    for i in 0..<allNextPieces.count {
      self.holdPieceArray[i] = UIView()
      self.holdPieceArray[i].sizeToFit()
      self.holdPieceArray[i].isHidden = true
      let pattern = allNextPieces[i].pattern
      let pieceOffset = allNextPieces[i].offset
      let pieceColor = allNextPieces[i].color
      let pieceStartPos = (posX: startNextPosition.x + pieceOffset.x * holdPieceSize - borderInset + (marginsXAxis / 2), posY: startNextPosition.y + pieceOffset.y * holdPieceSize - borderInset)
      for k in 0..<pattern.count {
        for (l, value) in pattern[k].enumerated() where value == 1 {
          let piecePartFrame = CGRect(x: pieceStartPos.posX + CGFloat(l) * holdPieceSize, y: pieceStartPos.posY + CGFloat(k) * holdPieceSize, width: holdPieceSize, height: holdPieceSize)
          let piecePartView = UIView(frame: piecePartFrame)
          piecePartView.backgroundColor = pieceColor
          piecePartView.layer.borderWidth = relativeWidth(2)
          piecePartView.layer.borderColor = UIColor.black.cgColor
          piecePartView.layer.cornerRadius = holdPieceSize * 0.2

          piecePartView.layer.shadowOffset = .zero
          piecePartView.layer.shadowColor = UIColor.black.cgColor
          piecePartView.layer.shadowRadius = relativeWidth(2)
          piecePartView.layer.shadowOpacity = 1
          piecePartView.layer.shadowPath = UIBezierPath(roundedRect: piecePartView.bounds, cornerRadius: relativeWidth(pieceSize * 0.2)).cgPath
          self.holdPieceArray[i].addSubview(piecePartView)
        }
      }
      self.view.addSubview(self.holdPieceArray[i])
    }
  }

  func buildMap() {
    mapBorder.frame = CGRect(x: mapStartPos.x, y: mapStartPos.y, width: pieceSize * CGFloat(mapSizeX), height: pieceSize * CGFloat(mapSizeY))
    mapBorder.frame = mapBorder.frame.insetBy(dx: borderInset, dy: borderInset)
    view.addSubview(mapBorder)

    view.addSubview(nextPiecesBorder)

    self.mapViews = Array(repeating: Array(repeating: (view: UIView(), animation: AnimationView()), count: mapSizeY), count: mapSizeX)
    for i in 0..<mapSizeX {
      for j in 0..<mapSizeY {
        let viewFrame = CGRect(x: mapStartPos.x + CGFloat(i) * pieceSize, y: mapStartPos.y + CGFloat(j) * pieceSize, width: pieceSize, height: pieceSize)
        self.mapViews[i][j].view = UIView(frame: viewFrame)
        self.mapViews[i][j].view.backgroundColor = UIColor.white
        self.mapViews[i][j].view.layer.borderWidth = relativeWidth(2)
        self.mapViews[i][j].view.isHidden = true
        self.mapViews[i][j].view.layer.borderColor = UIColor.black.cgColor
        self.mapViews[i][j].view.layer.cornerRadius = pieceSize * 0.2

        self.mapViews[i][j].view.layer.shadowOffset = .zero
        self.mapViews[i][j].view.layer.shadowColor = UIColor.black.cgColor
        self.mapViews[i][j].view.layer.shadowRadius = relativeWidth(2)
        self.mapViews[i][j].view.layer.shadowOpacity = 1
        self.mapViews[i][j].view.layer.shadowPath = UIBezierPath(roundedRect: self.mapViews[i][j].view.bounds, cornerRadius: relativeWidth(pieceSize * 0.2)).cgPath
        self.view.addSubview(self.mapViews[i][j].view)
      }
    }
    for i in 0..<mapSizeX {
      for j in 0..<mapSizeY {
        let animationFrame = CGRect(x: mapStartPos.x - 120 + CGFloat(i) * pieceSize + (pieceSize / 2), y: mapStartPos.y - 35 + CGFloat(j) * pieceSize + (pieceSize / 2), width: 240, height: 70)
        self.mapViews[i][j].animation = AnimationView(name: "hearts-animation")
        self.mapViews[i][j].animation.contentMode = .scaleAspectFit
        self.mapViews[i][j].animation.frame = animationFrame

        self.view.addSubview(self.mapViews[i][j].animation)
      }
    }
  }

  private func buildMapOverlay() {
    let pauseLineWidth: CGFloat = mapBorder.frame.width * 0.15
    let pauseLineHeight: CGFloat = mapBorder.frame.height * 0.30
    let distanceBetweenLines: CGFloat = mapBorder.frame.height * 0.02
    mapOverlay.frame = CGRect(x: mapStartPos.x, y: mapStartPos.y, width: pieceSize * CGFloat(mapSizeX), height: pieceSize * CGFloat(mapSizeY))
    view.addSubview(mapOverlay)
    mapOverlay.addSubview(pauseLineLeft)
    mapOverlay.addSubview(pauseLineRight)

    pauseLineLeft.layer.cornerRadius = pauseLineWidth / 2
    pauseLineRight.layer.cornerRadius = pauseLineWidth / 2

    gameOverLabel.text = "GAME\nOVER"
    mapOverlay.addSubview(gameOverLabel)

    tryAgainLabel.text = "TRY AGAIN"
    let tapGesture = UITapGestureRecognizer(target: self.presenter, action: #selector(self.presenter?.restartGame))
    tryAgainLabel.addGestureRecognizer(tapGesture)
    mapOverlay.addSubview(tryAgainLabel)
    NSLayoutConstraint.activate([
      pauseLineLeft.centerYAnchor.constraint(equalTo: mapOverlay.centerYAnchor),
      pauseLineLeft.centerXAnchor.constraint(equalTo: mapOverlay.centerXAnchor, constant: -distanceBetweenLines / 2 - pauseLineWidth / 2),
      pauseLineLeft.widthAnchor.constraint(equalToConstant: pauseLineWidth),
      pauseLineLeft.heightAnchor.constraint(equalToConstant: pauseLineHeight),

      pauseLineRight.centerYAnchor.constraint(equalTo: mapOverlay.centerYAnchor),
      pauseLineRight.centerXAnchor.constraint(equalTo: mapOverlay.centerXAnchor, constant: distanceBetweenLines / 2 + pauseLineWidth / 2),
      pauseLineRight.widthAnchor.constraint(equalToConstant: pauseLineWidth),
      pauseLineRight.heightAnchor.constraint(equalToConstant: pauseLineHeight),

      gameOverLabel.leadingAnchor.constraint(equalTo: mapOverlay.leadingAnchor),
      gameOverLabel.trailingAnchor.constraint(equalTo: mapOverlay.trailingAnchor),
      gameOverLabel.centerYAnchor.constraint(equalTo: mapOverlay.centerYAnchor, constant: -relativeHeight(50)),

      tryAgainLabel.centerXAnchor.constraint(equalTo: gameOverLabel.centerXAnchor),
      tryAgainLabel.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: relativeHeight(15))
    ])
  }

  private func playAnimationOn(i: Int, j: Int) {
    let fillKeypath = AnimationKeypath(keypath: "**.Fill 1.Color")
    if let color = self.mapViews[i][j].view.backgroundColor {
      let heartColor = ColorValueProvider(color.toColorLottie())
      self.mapViews[i][j].animation.setValueProvider(heartColor, keypath: fillKeypath)
    }
    self.mapViews[i][j].animation.loopMode = .playOnce
    self.mapViews[i][j].animation.play()

    AudioServicesPlaySystemSound(VibrationType.pop.rawValue)
  }

  func setupTapView() {
    screenTapView.frame = view.frame
    view.addSubview(screenTapView)
  }

  private func setupCloseButton() {
    closeButton.addTarget(self, action: #selector(self.closeTetris), for: .touchUpInside)
    closeButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
    view.addSubview(closeButton)
  }

  private func setupPauseButton() {
    pauseButton.addTarget(self.presenter, action: #selector(self.presenter?.togglePausedGameState), for: .touchUpInside)
    view.addSubview(pauseButton)
  }

  @objc
  func closeTetris() {
    self.navigationController?.popFade(navBarHidden: false)
  }
}

extension TetrisViewController: TetrisPresenterToViewProtocol {
  func setPauseButtonState(to isEnabled: Bool) {
    self.pauseButton.isEnabled = isEnabled
    self.pauseButton.alpha = isEnabled ? 1 : 0.1
  }

  func updateOverlay(isShowing: Bool, isPaused: Bool) {
    self.mapOverlay.isHidden = !isShowing
    if isShowing {
      pauseLineLeft.isHidden = !isPaused
      pauseLineRight.isHidden = !isPaused
      gameOverLabel.isHidden = isPaused
      tryAgainLabel.isHidden = isPaused
    }
  }


  func setPauseButtonLabel(to text: String) {
    pauseButton.setTitle(text, for: .normal)
  }

  func setInteractions(to state: Bool) {
    self.screenTapView.isUserInteractionEnabled = state
    self.holdPiecesBorder.isUserInteractionEnabled = state
  }

  func updateCurrentTime(with text: String) {
    self.timeCountLabel.text = text
  }

  func updateHighScore(with score: Int) {
    self.bestLabel.text = "BEST: \(score)"
  }

  func updateUILevelAndScore(level: Int, score: Int) {
    self.levelCountLabel.text = String(level)
    self.scoreCountLabel.text = String(score)
  }

  func setNextPieces(for pieceArray: [Int]) {
    for i in (0...pieceArray.count - 1) {
      for j in (0 ... allNextPieces.count - 1) {
        let shouldHidePiece = j != pieceArray[i]
        nextPieceArray[i][j].isHidden = shouldHidePiece
      }
    }
  }

  func setHoldPiece(to pieceIndex: Int) {
    for i in (0 ... allNextPieces.count - 1) {
      let shouldHidePiece = i != pieceIndex
      holdPieceArray[i].isHidden = shouldHidePiece
    }
  }

  func playAnimation(for lines: [Int]) {
    for index in lines {
      for i in (0 ... mapSizeX - 1) {
        playAnimationOn(i: i, j: index)
      }
    }
  }

  func refreshMap(new map: [[TetrisMapCoordinate]]) {
    for i in 0..<map.count {
      for j in 0..<map[i].count {
        self.mapViews[i][j].view.isHidden = map[i][j].state == 0

        self.mapViews[i][j].view.layer.borderColor = UIColor.black.withAlphaComponent(map[i][j].state == -1 ? 0.3 : 1).cgColor
        self.mapViews[i][j].view.backgroundColor = map[i][j].color.color.withAlphaComponent(map[i][j].state == -1 ? 0.2 : 1)
        self.mapViews[i][j].view.layer.shadowColor = UIColor.black.withAlphaComponent(map[i][j].state == -1 ? 0.2 : 1).cgColor
      }
    }
  }
}

extension TetrisViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
