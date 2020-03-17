//
//  TetrisPresenter.swift
//
//  Created by Pedro Saldanha on 10/02/2020.
//  Copyright © 2020 Impossible. All rights reserved.
//

import UIKit
import Darwin

protocol TetrisPresenterToViewProtocol: class {
  func refreshMap(new map: [[TetrisMapCoordinate]])
  func playAnimation(for lines: [Int])
  func setNextPieces(for pieceArray: [Int])
  func setHoldPiece(to pieceIndex: Int)
  func updateUILevelAndScore(level: Int, score: Int)
  func updateHighScore(with score: Int)
  func updateCurrentTime(with text: String)
  func setInteractions(to state: Bool)
  func setPauseButtonLabel(to text: String)
  func setPauseButtonState(to isEnabled: Bool)
  func updateOverlay(isShowing: Bool, isPaused: Bool)
}

class TetrisMapCoordinate: Codable {
  var state: Int
  var color: TetrisColor

  init(_ state: Int, _ color: TetrisColor ) {
    self.state = state
    self.color = color
  }
}

class TetrisPiecePosition: Codable {
  var x: Int
  var y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
}

class TetrisPresenter {
  weak var view: TetrisPresenterToViewProtocol?

  private enum Direction {
    case left
    case right
    case down
  }

  private enum Speed {
    case paused
    case normal
    case fast
    case superFast
  }

  private final class TetrisPiece  {
    //Drawn horizontaly
    public class var patternI: [[[Int]]] { return [[[0, 0, 1],[0, 0, 1],[0, 0, 1],[0, 0, 1]],
                                                   [[0, 0, 0, 0],[0, 0, 0, 0],[1, 1, 1, 1]],
                                                   [[0, 0, 1],[0, 0, 1],[0, 0, 1], [0, 0, 1]],
                                                   [[0, 0, 0, 0],[1, 1, 1, 1]]]}

    public class var patternJ: [[[Int]]] { return [[[0, 1], [0, 1], [1, 1]],
                                                   [[0, 0, 0], [1, 1, 1], [0, 0, 1]],
                                                   [[0, 1, 1], [0, 1, 0], [0, 1, 0]],
                                                   [[1, 0, 0], [1, 1, 1]]]}

    public class var patternL: [[[Int]]] { return [[[1, 1], [0, 1], [0, 1]],
                                                   [[0, 0, 0], [1, 1, 1], [1, 0, 0]],
                                                   [[0, 1, 0], [0, 1, 0], [0, 1, 1]],
                                                   [[0, 0, 1], [1, 1, 1]]]}

    public class var patternO: [[[Int]]] { return [[[1, 1], [1, 1]],
                                                   [[1, 1], [1, 1]],
                                                   [[1, 1], [1, 1]],
                                                   [[1, 1], [1, 1]]]}

    public class var patternS: [[[Int]]] { return [[[0, 1], [1, 1], [1, 0]],
                                                   [[0, 0, 0], [1, 1, 0], [0, 1, 1]],
                                                   [[0, 0, 1], [0, 1, 1], [0, 1, 0]],
                                                   [[1, 1, 0], [0, 1, 1]]]}

    public class var patternT: [[[Int]]] { return [[[0, 1], [1, 1], [0, 1]],
                                                   [[0, 0, 0], [1, 1, 1], [0, 1, 0]],
                                                   [[0, 1, 0], [0, 1, 1], [0, 1, 0]],
                                                   [[0, 1, 0], [1, 1, 1]]]}

    public class var patternZ: [[[Int]]] { return [[[1, 0], [1, 1], [0, 1]],
                                                   [[0, 0, 0], [0, 1, 1], [1, 1, 0]],
                                                   [[0, 1, 0], [0, 1, 1], [0, 0, 1]],
                                                   [[0, 1, 1], [1, 1, 0]]]}
  }

  var currentRotationIndex: Int = 0

  fileprivate let allPieces = [(pattern: TetrisPiece.patternI, UIColor.tetris_color_1), (pattern: TetrisPiece.patternJ, UIColor.tetris_color_2), (pattern: TetrisPiece.patternL, UIColor.tetris_color_3), (pattern: TetrisPiece.patternO, UIColor.tetris_color_4), (pattern: TetrisPiece.patternS, UIColor.tetris_color_5), (pattern: TetrisPiece.patternT, UIColor.tetris_color_6), (pattern: TetrisPiece.patternZ, UIColor.tetris_color_7)]

  private let shadowColor = UIColor.tetrisLightGrey
  private var currentPiece: (pattern: [[[Int]]], color: UIColor)?
  private var currentPieceIndex: Int = -1
  private var heldPiece: (pattern: [[[Int]]], color: UIColor)?
  private var heldPieceIndex: Int = -1
  private var currentPiecePosition = TetrisPiecePosition(4, 0)
  private var predictedPiecePosition = TetrisPiecePosition(4, 0)
  private var startFingerLocation = CGPoint()
  private var tapStartTime: Double = 0
  private var swipingSuperFastToBottom: Bool = false
  private var isPanning: Bool = false
  private var isGameOver: Bool = false
  private var numberOfNextPieces: Int
  private var stackNextPieces = [(piece: (pattern: [[[Int]]], color: UIColor), index: Int)]()
  fileprivate var tetrisMap: [[TetrisMapCoordinate]]
  fileprivate var predictedTetrisMap: [[TetrisMapCoordinate]]

  private var totalScore: Int = 0
  private var currentLevel: Int = 0
  private var totalLinesBrokenSinceLastLevelUp: Int = 0

  var clockTimer = Timer()
  var gameTimer = Timer()
  let mapSizeX: Int
  let mapSizeY: Int
  var currentTimeInSeconds: Int = 0

  private var isPaused: Bool = false

  private var currentHighScore: Int = 0

  init(mapSizeX: Int, mapSizeY: Int, nextPieces: Int) {

    self.mapSizeX = mapSizeX
    self.mapSizeY = mapSizeY
    self.numberOfNextPieces = nextPieces
    self.predictedTetrisMap = Array(repeating: Array(repeating: TetrisMapCoordinate(0, TetrisColor(color: .white)), count: self.mapSizeY), count: self.mapSizeX)
    self.currentHighScore = UserDefaults.standard.integer(forKey: "tetrisHighScore")
    self.tetrisMap = Array(repeating: Array(repeating: TetrisMapCoordinate(0, TetrisColor(color: .white)), count: self.mapSizeY), count: self.mapSizeX)

    //Before user kills app (or app crashes :P) we store current game
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)

    view?.updateUILevelAndScore(level: self.currentLevel, score: self.totalScore)
    view?.updateHighScore(with: currentHighScore)
  }

  deinit {
    gameTimer.invalidate()
    clockTimer.invalidate()
  }

  @objc
  func applicationWillTerminate() {
    storeGame()
  }

  private func setTimeClock(to state: Bool) {
    if !state {
      clockTimer.invalidate()
    } else {
      clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.incrementTimeAndUpdateUI), userInfo: nil, repeats: true)
    }
  }

  @objc
  private func incrementTimeAndUpdateUI() {
    self.currentTimeInSeconds += 1
    updateTimeUI()
  }

  private func updateTimeUI() {
    var mins = self.currentTimeInSeconds / 60
    let secs = self.currentTimeInSeconds % 60
    var hours = 0
    if mins >= 60 {
      hours = mins / 60
      mins = mins % 60
    }
    let timeformatter = NumberFormatter()
    timeformatter.minimumIntegerDigits = 2
    timeformatter.minimumFractionDigits = 0
    timeformatter.roundingMode = .down
    guard let hrsStr  = timeformatter.string(from: NSNumber(value: hours)),
          let minsStr = timeformatter.string(from: NSNumber(value: mins)),
          let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
        return
    }
    view?.updateCurrentTime(with: "\(hrsStr):\(minsStr):\(secsStr)")
  }

  private func setGameSpeed(speed: Speed) {
      // Scheduling timer to Call the function "update" with the interval based on speed
    gameTimer.invalidate()

    switch speed {
    case .normal:
      //Equation for increased speed (starts at 1 drop per second and reaches minimum of a drop every 0.15 seconds at level 80)
      let delayInMilliSeconds = (1000 * pow(Double(0.98), Double(self.currentLevel))).clamped(to: (150...1000))
      let delayInSeconds = delayInMilliSeconds / 1000
      gameTimer = Timer.scheduledTimer(timeInterval: delayInSeconds, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
      setTimeClock(to: true)
    case .fast:
      gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
      setTimeClock(to: true)
    case .superFast:
      gameTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
      setTimeClock(to: true)
    case .paused:
      setTimeClock(to: false)
    }
  }

  @objc
  private func update() {
    if !movePiece(to: Direction.down) {
      self.currentRotationIndex = 0

      //if it didn't remove completed lines we should instantiate a new piece
      if !removeLines() {
        setGameSpeed(speed: .normal)
        self.swipingSuperFastToBottom = false
        self.isPanning = false
        instantiateNewPiece()
      }
    }
  }

  @objc
  func togglePausedGameState() {
    self.isPaused = !self.isPaused
    self.setGameSpeed(speed: self.isPaused ? .paused : .normal)
    view?.setPauseButtonLabel(to: self.isPaused ? "PLAY" : "PAUSE")
    view?.setInteractions(to: !self.isPaused)
    if self.isPaused {
      self.swipingSuperFastToBottom = false
    }
    view?.updateOverlay(isShowing: self.isPaused, isPaused: true)
  }

  @discardableResult
  private func movePiece(to direction: Direction) -> Bool {

    guard canMove(to: direction) else {
      return false
    }

    clearPiece(fromPredictedMap: false)

    switch direction {
    case .left:
      currentPiecePosition = TetrisPiecePosition(currentPiecePosition.x - 1 ,currentPiecePosition.y)
    case .right:
      currentPiecePosition = TetrisPiecePosition(currentPiecePosition.x + 1 ,currentPiecePosition.y)
    case .down:
      currentPiecePosition = TetrisPiecePosition(currentPiecePosition.x ,currentPiecePosition.y + 1)
    }

    if let currentPiece = self.currentPiece, let adjustedPosition = adjustPaternPosition(pattern: currentPiece.pattern[currentRotationIndex], at: self.currentPiecePosition) {
      self.currentPiecePosition = adjustedPosition
    }
    self.insertCurrentPiece()

    return true
  }

  //MARK: Map modifications

  private func instantiateNewPiece() {
    self.currentRotationIndex = 0
    if stackNextPieces.count == 0 {
      for _ in (0...numberOfNextPieces - 1) {
        if let randomIndex = (0..<allPieces.count).randomElement() {
          let piece = allPieces[randomIndex]
          stackNextPieces.append((piece: piece, index: randomIndex))
        }
      }
    }

    let stackPiece = stackNextPieces.removeFirst()
    self.currentPiece = stackPiece.piece
    self.currentPieceIndex = stackPiece.index
    if let randomIndex = (0..<allPieces.count).randomElement() {
      let piece = allPieces[randomIndex]
      stackNextPieces.append((piece: piece, index: randomIndex))
    }
    let indexesOfNextPieces = stackNextPieces.map({ $0.index })
    view?.setNextPieces(for: indexesOfNextPieces)

    self.currentPiecePosition = TetrisPiecePosition(4, 0)

    if let myPattern = self.currentPiece?.pattern[currentRotationIndex], self.isGameOver(for: myPattern) {
      self.isGameOver = true
      handleGameOver()
      removeStoredGame()
    } else {
      self.insertCurrentPiece()
    }
  }

  private func insertCurrentPiece() {
    guard let currentPiece = self.currentPiece else {
      return
    }
    let pattern = currentPiece.pattern[currentRotationIndex]
    for (i, row) in pattern.enumerated() {
      for (j, value) in row.enumerated() where value == 1 {
        tetrisMap[Int(i) + currentPiecePosition.x][Int(j) + currentPiecePosition.y] = TetrisMapCoordinate(value, TetrisColor(color: currentPiece.color))
      }
    }
    updateShadowPiece()
    view?.refreshMap(new: tetrisMap)
  }

  private func updateShadowPiece() {
    guard let currentPiece = self.currentPiece else {
      return
    }
    let pattern = currentPiece.pattern[currentRotationIndex]
    //clear all the shadows (represented in the map by -1)
    for (i, row) in tetrisMap.enumerated() {
      for (j, value) in row.enumerated() where value.state == -1 {
        tetrisMap[i][j] = TetrisMapCoordinate(0, TetrisColor(color: UIColor.clear))
      }
    }

    var numberTimesDown = 0
    while canMove(to: .down, numberOfTimes: numberTimesDown) {
      numberTimesDown += 1
    }
    numberTimesDown -= 1

    if numberTimesDown > 0 {
      let shadowPosition = TetrisPiecePosition(self.currentPiecePosition.x, self.currentPiecePosition.y + numberTimesDown)
      //We should insert shadow in this new position
      for (i, row) in pattern.enumerated() {
        for (j, value) in row.enumerated() where value == 1 {
          if tetrisMap[Int(i) + shadowPosition.x][Int(j) + shadowPosition.y].state == 0 {
            tetrisMap[Int(i) + shadowPosition.x][Int(j) + shadowPosition.y] = TetrisMapCoordinate(-1, TetrisColor(color: shadowColor))
          }
        }
      }
    }
  }

  private func clearPiece(fromPredictedMap: Bool) {
    // Clear piece from map before updating position and refreshing
    guard let currentPiece = self.currentPiece else {
      return
    }

    let pattern = currentPiece.pattern[currentRotationIndex]
    for (i, row) in pattern.enumerated() {
      for (j, value) in row.enumerated() where value == 1 {
        if (0...mapSizeX - 1).contains(Int(i) + currentPiecePosition.x) &&
          (0...mapSizeY - 1).contains(Int(j) + currentPiecePosition.y) {
          if fromPredictedMap {
            self.predictedTetrisMap[Int(i) + currentPiecePosition.x][Int(j) + currentPiecePosition.y] = TetrisMapCoordinate(0, TetrisColor(color: UIColor.clear))
          } else {
            self.tetrisMap[Int(i) + currentPiecePosition.x][Int(j) + currentPiecePosition.y] = TetrisMapCoordinate(0, TetrisColor(color: UIColor.clear))
          }
        }
      }
    }
    if !fromPredictedMap {
      view?.refreshMap(new: tetrisMap)
    }
  }

  private func removeLines() -> Bool {
    var countOf1OnEachLine: [Int] = Array(repeating: 0, count: self.mapSizeY)
    for (_, row) in tetrisMap.enumerated() {
      for (j, value) in row.enumerated() where value.state == 1 {
        countOf1OnEachLine[j] += 1
      }
    }
    var lineIndexesToRemove = [Int]()
    for (i, lineCount) in countOf1OnEachLine.enumerated() where lineCount == self.mapSizeX {
      lineIndexesToRemove.append(i)
    }
    if lineIndexesToRemove.count > 0 {
      view?.playAnimation(for: lineIndexesToRemove)
      removeLines(with: lineIndexesToRemove)
      return true
    }
    return false
  }

  private func removeLines(with lineIndexes: [Int]) {
    for index in lineIndexes where index > 0 {
      for i in (0 ... mapSizeX - 1) {
        for j in (0 ... index - 1) {
          tetrisMap[i][index - j] = tetrisMap[i][index - j - 1]
        }
      }
    }
    updateScore(numberOfLines: lineIndexes.count)
    view?.updateUILevelAndScore(level: self.currentLevel, score: self.totalScore)
    view?.refreshMap(new: tetrisMap)
  }

  private func updateScore(numberOfLines: Int) {
    self.totalLinesBrokenSinceLastLevelUp += numberOfLines

    if totalLinesBrokenSinceLastLevelUp >= 10 {
      self.totalLinesBrokenSinceLastLevelUp = totalLinesBrokenSinceLastLevelUp - 10
      self.currentLevel += 1
    }
    switch numberOfLines {
    case 1:
      self.totalScore += 40 * (self.currentLevel + 1)
      break
    case 2:
      self.totalScore += 100 * (self.currentLevel + 1)
      break
    case 3:
      self.totalScore += 300 * (self.currentLevel + 1)
      break
    case 4:
      self.totalScore += 1200 * (self.currentLevel + 1)
      break
    default:
      print("Incorrect number of lines. Gonna ignore this one!")
    }
    checkNewHighscore()
  }

  private func checkNewHighscore() {
    if self.totalScore > self.currentHighScore {
      self.currentHighScore = self.totalScore
      UserDefaults.standard.set(self.currentHighScore, forKey: "tetrisHighScore")
      view?.updateHighScore(with: self.currentHighScore)
    }
  }

  private func isGameOver(for pattern: [[Int]]) -> Bool {
    for (i, row) in pattern.enumerated() {
      for (j, value) in row.enumerated() where value == 1 {
        if tetrisMap[Int(i) + currentPiecePosition.x][Int(j) + currentPiecePosition.y].state == 1 {
          return true
        }
      }
    }
    return false
  }

  private func handleGameOver() {
    self.setGameSpeed(speed: .paused)
    self.swipingSuperFastToBottom = false
    view?.setPauseButtonState(to: false)
    view?.setInteractions(to: false)
    view?.updateOverlay(isShowing: true, isPaused: false)
  }

  @objc
  func holdPiece() {
    if heldPiece == nil {
      clearPiece(fromPredictedMap: false)
      self.heldPiece = self.currentPiece
      self.heldPieceIndex = self.currentPieceIndex
      view?.setHoldPiece(to: self.heldPieceIndex)
      //Before inserting piece, we should set piece to the initial rotation
      self.currentRotationIndex = 0

      instantiateNewPiece()
    } else {
      //Should check if held piece can pit in that position of the board!
      //If it can fit we should replace heldPiece with currentPiece
      self.predictedTetrisMap = self.tetrisMap
      self.predictedPiecePosition = self.currentPiecePosition
      clearPiece(fromPredictedMap: true)

      guard let heldPiece = self.heldPiece else {
        return
      }
      if let adjustedPosition = adjustPaternPosition(pattern: heldPiece.pattern[0], at: self.predictedPiecePosition) {
        self.predictedPiecePosition = adjustedPosition
      }
      if canPieceFitPosition(for: heldPiece, at: self.predictedPiecePosition, rotationIndex: 0, usePredictedTetrisMap: true) {
        //clear current piece
        clearPiece(fromPredictedMap: false)

        //Predicted position has been successfully checked on tetris map.
        //We should update new current position before piece insertion
        self.currentPiecePosition = self.predictedPiecePosition
        //Switch indexes
        let currentPieceIndex = self.currentPieceIndex
        self.currentPieceIndex = heldPieceIndex
        self.heldPieceIndex = currentPieceIndex
        //Switch pieces
        let myCurrentPiece = self.currentPiece
        self.currentPiece = self.heldPiece
        self.heldPiece = myCurrentPiece
        //Before inserting piece, we should set piece to the initial rotation
        self.currentRotationIndex = 0
        //Insert piece in map
        insertCurrentPiece()
        //Draw again:
        view?.refreshMap(new: self.tetrisMap)
        //Refresh heldPiece UI
        view?.setHoldPiece(to: self.heldPieceIndex)
      }
    }
  }

  @objc
  func restartGame() {
    self.isGameOver = false
    self.currentPiece = nil
    self.currentPiecePosition = TetrisPiecePosition(4, 0)
    self.heldPiece = nil
    self.currentPieceIndex = -1
    self.predictedPiecePosition = TetrisPiecePosition(4, 0)
    self.isPanning = false
    self.stackNextPieces.removeAll()
    self.isPaused = false
    self.tetrisMap = Array(repeating: Array(repeating: TetrisMapCoordinate(0, TetrisColor(color: .white)), count: self.mapSizeY), count: self.mapSizeX)
    self.predictedTetrisMap = Array(repeating: Array(repeating: TetrisMapCoordinate(0, TetrisColor(color: .white)), count: self.mapSizeY), count: self.mapSizeX)
    self.swipingSuperFastToBottom = false
    self.currentLevel = 0
    self.totalScore = 0
    self.currentTimeInSeconds = 0
    incrementTimeAndUpdateUI()
    view?.refreshMap(new: tetrisMap)
    view?.updateUILevelAndScore(level: self.currentLevel, score: self.totalScore)
    view?.setNextPieces(for: [-1, -1, -1, -1])
    view?.setHoldPiece(to: -1)
    view?.setPauseButtonLabel(to: "PAUSE")
    view?.setPauseButtonState(to: true)
    view?.setInteractions(to: true)
    view?.updateOverlay(isShowing: false, isPaused: false)
    self.setGameSpeed(speed: .normal)
  }

  //MARK: Tetris logic

  private func canMove(to direction: Direction, numberOfTimes: Int = 1) -> Bool {
    guard let currentPiece = self.currentPiece else {
      return false
    }
    self.predictedTetrisMap = self.tetrisMap
    clearPiece(fromPredictedMap: true)

    switch direction {
    case .left:
      predictedPiecePosition = TetrisPiecePosition(currentPiecePosition.x - numberOfTimes, currentPiecePosition.y)
    case .right:
      predictedPiecePosition = TetrisPiecePosition(currentPiecePosition.x + numberOfTimes, currentPiecePosition.y)
    case .down:
      predictedPiecePosition = TetrisPiecePosition(currentPiecePosition.x, currentPiecePosition.y + numberOfTimes)
    }

    if let currentPiece = self.currentPiece, let adjustedPosition = adjustPaternPosition(pattern: currentPiece.pattern[currentRotationIndex], at: self.predictedPiecePosition) {
      self.predictedPiecePosition = adjustedPosition
    }

    return canPieceFitPosition(for: currentPiece, at: predictedPiecePosition, usePredictedTetrisMap: true)
  }

  private func canPieceFitPosition(for piece: (pattern: [[[Int]]], color: UIColor), at position: TetrisPiecePosition, rotationIndex: Int? = nil, usePredictedTetrisMap: Bool) -> Bool {
    var pattern = [[Int]]()
    if let myIndex = rotationIndex {
      pattern = piece.pattern[myIndex]
    } else {
      pattern = piece.pattern[currentRotationIndex]
    }

    let mapToConsider = usePredictedTetrisMap ? self.predictedTetrisMap : self.tetrisMap
    for (i, row) in pattern.enumerated() {
      for (j, value) in row.enumerated() where value == 1 {
        let posX = Int(i) + position.x
        let posY = Int(j) + position.y
        if  !(0...mapSizeX - 1).contains(posX) ||
            !(0...mapSizeY - 1).contains(posY) ||
            (mapToConsider[posX][posY].state == 1 && value == 1) {
          return false
        }
      }
    }
    return true
  }

  //Sometimes when user rotates or moves a piece to a new position, it goes out of the map
  //In this case we need to shift the piece position (dx, dy) to place the entire piece inside the map
  private func adjustPaternPosition( pattern: [[Int]], at position: TetrisPiecePosition) -> TetrisPiecePosition? {
    var needsMoveX: Int = 0
    var needsMoveY: Int = 0
    for (i, row) in pattern.enumerated() {
      for (j, value) in row.enumerated() where value == 1 {
        let posX = Int(i) + position.x
        let posY = Int(j) + position.y
        if posX < 0 && needsMoveX < -posX {
          needsMoveX = -posX
        } else if posX > mapSizeX - 1 && needsMoveX > mapSizeX - 1 - posX {
          needsMoveX = mapSizeX - 1 - posX
        }

        if posY < 0 && needsMoveY < -posY {
          needsMoveY = -posY
        } else if posX > mapSizeY - 1 && needsMoveY < mapSizeY - 1 - posY {
          needsMoveY = mapSizeY - 1 - posY
        }
      }
    }

    if needsMoveX != 0 || needsMoveY != 0 {
      return TetrisPiecePosition(position.x + needsMoveX, position.y + needsMoveY)
    }
    return nil
  }
  //MARK: Input handlers

  @objc
  func swipeHandler(sender: UISwipeGestureRecognizer) {
    if sender.state == .ended {
      setGameSpeed(speed: .superFast)
      self.totalScore += 2 * (self.currentLevel + 1)
      view?.updateUILevelAndScore(level: self.currentLevel, score: self.totalScore)
      checkNewHighscore()
      self.swipingSuperFastToBottom = true
    }
  }

  @objc
  func tapHandler(sender: UITapGestureRecognizer) {
    if self.isPanning {
      return
    }
    if sender.state == .began {
      self.tapStartTime = Date().millisecondsSince1970
    }
    else if sender.state == .ended, Date().millisecondsSince1970 - self.tapStartTime < 300 {
      guard let currentPiece = currentPiece else {
        return
      }
      var predictedRotationIndex = self.currentRotationIndex + 1
      if predictedRotationIndex > 3 {
        predictedRotationIndex = 0
      }
      clearPiece(fromPredictedMap: false)

      if let currentPiece = self.currentPiece, let adjustedPosition = adjustPaternPosition(pattern: currentPiece.pattern[predictedRotationIndex], at: self.currentPiecePosition) {
        self.currentPiecePosition = adjustedPosition
      }

      if canPieceFitPosition(for: currentPiece, at: currentPiecePosition, rotationIndex: predictedRotationIndex, usePredictedTetrisMap: false) {
        self.currentRotationIndex = predictedRotationIndex
      }
      self.insertCurrentPiece()
    }
  }

  @objc
  func longTap(sender: UITapGestureRecognizer) {
    if sender.state == .began {
      setGameSpeed(speed: .fast)
    } else if sender.state == .ended {
      setGameSpeed(speed: .normal)
    }
  }

  @objc
  func pannedFinger(sender: UITapGestureRecognizer) {
    if swipingSuperFastToBottom {
      return
    }
    switch sender.state {
    case .began:
      self.isPanning = true
      self.startFingerLocation = sender.location(in: sender.view)
    case .changed:
      guard let tapView = sender.view else { return }
      let currentLocation = sender.location(in: sender.view)
      let dx = currentLocation.x - self.startFingerLocation.x

      if dx > tapView.frame.width / 12 {
        self.startFingerLocation = sender.location(in: sender.view)
        movePiece(to: .right)
      }
      else if dx < -tapView.frame.width / 12 {
        self.startFingerLocation = sender.location(in: sender.view)
        movePiece(to: .left)
      }
    case .ended:
      self.isPanning = false
      break
    default:
      break
    }
  }

  //MARK: Game saving methods

  func storeGame() {
    //No point in saving game if it has already ended
    if !isGameOver {
      //Current piece must be removed from tetris map before saving current map
      clearPiece(fromPredictedMap: false)

      UserDefaults.standard.set(currentPieceIndex, forKey: "currentPieceIndex")
      UserDefaults.standard.set(currentTimeInSeconds, forKey: "currentTimeInSeconds")
      UserDefaults.standard.set(heldPieceIndex, forKey: "heldPieceIndex")
      UserDefaults.standard.set(try? PropertyListEncoder().encode(tetrisMap), forKey: "tetrisMap")
      UserDefaults.standard.set(totalScore, forKey: "totalScore")
      UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
      UserDefaults.standard.set(totalLinesBrokenSinceLastLevelUp, forKey: "totalLinesBrokenSinceLastLevelUp")
      UserDefaults.standard.set(try? PropertyListEncoder().encode(currentPiecePosition), forKey: "currentPiecePosition")
      let nextPiecesIndexes = stackNextPieces.map({ $0.index })
      UserDefaults.standard.set(nextPiecesIndexes, forKey: "stackNextPieces")
    } else {
      //We must remove the game that was saved before game over
      removeStoredGame()
    }
  }

  func loadGame() {
    if let currentPieceIndex = UserDefaults.standard.object(forKey: "currentPieceIndex") as? Int,
      let heldPieceIndex = UserDefaults.standard.object(forKey: "heldPieceIndex") as? Int,
      let tetrisData = UserDefaults.standard.value(forKey: "tetrisMap") as? Data,
      let tetrisMap = try? PropertyListDecoder().decode([[TetrisMapCoordinate]].self, from: tetrisData),
      let totalScore = UserDefaults.standard.object(forKey: "totalScore") as? Int,
      let currentLevel = UserDefaults.standard.object(forKey: "currentLevel") as? Int,
      let totalLinesBrokenSinceLastLevelUp = UserDefaults.standard.object(forKey: "totalLinesBrokenSinceLastLevelUp") as? Int,
      let dataPiecePos = UserDefaults.standard.value(forKey: "currentPiecePosition") as? Data,
      let currentPiecePosition = try? PropertyListDecoder().decode(TetrisPiecePosition.self, from: dataPiecePos),
      let stackNextPieces = UserDefaults.standard.object(forKey: "stackNextPieces") as? [Int],
      let currentTimeInSeconds = UserDefaults.standard.object(forKey: "currentTimeInSeconds") as? Int {

      self.currentPiece = allPieces[currentPieceIndex]
      self.currentPieceIndex = currentPieceIndex
      self.currentTimeInSeconds = currentTimeInSeconds

      if heldPieceIndex >= 0 {
        self.heldPiece = allPieces[heldPieceIndex]
      }
      self.heldPieceIndex = heldPieceIndex

      self.tetrisMap = tetrisMap
      self.totalScore = totalScore
      self.currentLevel = currentLevel
      self.totalLinesBrokenSinceLastLevelUp = totalLinesBrokenSinceLastLevelUp
      self.currentPiecePosition = currentPiecePosition

      for i in stackNextPieces {
        self.stackNextPieces.append((piece: allPieces[i], index: i))
      }

      view?.setHoldPiece(to: self.heldPieceIndex)
      let indexesOfNextPieces = self.stackNextPieces.map({ $0.index })
      view?.setNextPieces(for: indexesOfNextPieces)
      view?.updateUILevelAndScore(level: self.currentLevel, score: self.totalScore)

      //Since this is done initially and isPaused is false, this line will put game in paused mode
      togglePausedGameState()

      updateTimeUI()

      //Inserting the current piece forces a map refresh.
      //We do this so the player can see the current map bellow the overlay
      insertCurrentPiece()
    } else {
      setGameSpeed(speed: .normal)
    }
  }

  private func removeStoredGame() {
    UserDefaults.standard.removeObject(forKey: "currentPieceIndex")
    UserDefaults.standard.removeObject(forKey: "heldPieceIndex")
    UserDefaults.standard.removeObject(forKey: "tetrisMap")
    UserDefaults.standard.removeObject(forKey: "totalScore")
    UserDefaults.standard.removeObject(forKey: "currentLevel")
    UserDefaults.standard.removeObject(forKey: "totalLinesBrokenSinceLastLevelUp")
    UserDefaults.standard.removeObject(forKey: "currentPiecePosition")
    UserDefaults.standard.removeObject(forKey: "stackNextPieces")
  }
}

class TetrisColor: Codable {

  private var _green: CGFloat = 0
  private var _blue: CGFloat = 0
  private var _red: CGFloat = 0
  private var alpha: CGFloat = 0

  init(color: UIColor) {
    color.getRed(&_red, green: &_green, blue: &_blue, alpha: &alpha)
  }

  var color:UIColor{
    get{
      return UIColor(red: _red, green: _green, blue: _blue, alpha: alpha)
    }
    set{
      newValue.getRed(&_red, green:&_green, blue: &_blue, alpha:&alpha)
    }
  }

  var cgColor:CGColor{
    get{
      return color.cgColor
    }
    set{
      UIColor(cgColor: newValue).getRed(&_red, green:&_green, blue: &_blue, alpha:&alpha)
    }
  }
}
