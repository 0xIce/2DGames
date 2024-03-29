/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import SpriteKit

class GameScene: SKScene {
  var player = Player()
  var background: SKTileMapNode!
  var bugsNode = SKNode()
  var obstaclesTileMap: SKTileMapNode?
  var firebugCount = 0
  var bugsprayTileMap: SKTileMapNode?
  var hud = HUD()
  var timeLimit: Int = 10
  var elapsedTime: Int = 0
  var startTime: Int?
  var gameState: GameState = .initial {
    didSet {
      hud.updateGameState(from: oldValue, to: gameState)
    }
  }
  var currentLevel = 1
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    background = childNode(withName: "background") as? SKTileMapNode
    obstaclesTileMap = childNode(withName: "obstacles") as? SKTileMapNode
    if let timeLimit = userData?.object(forKey: "timeLimit") as? Int {
      self.timeLimit = timeLimit
    }
    
    // 1
    let savedGameState = aDecoder.decodeInteger( forKey: "Scene.gameState")
    if let gameState = GameState(rawValue: savedGameState),
      gameState == .pause {
      self.gameState = gameState
      firebugCount = aDecoder.decodeInteger( forKey: "Scene.firebugCount")
      elapsedTime = aDecoder.decodeInteger( forKey: "Scene.elapsedTime")
      currentLevel = aDecoder.decodeInteger( forKey: "Scene.currentLevel")
      // 2
      player = childNode(withName: "Player") as! Player
      hud = camera!.childNode(withName: "HUD") as! HUD
      bugsNode = childNode(withName: "Bugs")!
      bugsprayTileMap = childNode(withName: "Bugspray") as? SKTileMapNode
  }
    
    addObservers()
  }
  
  override func didMove(to view: SKView) {
    if gameState == .initial {
      addChild(player)
      setupPhysicsWorld()
      
      //    let bug = Bug()
      //    bug.position = CGPoint(x: 60, y: 0)
      //    addChild(bug)
      createBugs()
      setupObstaclePhysics()
      if firebugCount > 0 {
        createBugspray(quantity: firebugCount + 10)
      }
      setupHud()
      gameState = .start
    }
    setupCamera()
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    if gameState != .play {
      isPaused = true
      return
    }
    if !player.hasBugspray {
      updateBugspray()
    }
    advanceBreakableTile(locateAt: player.position)
    updateHud(currentTime: currentTime)
    checkEndGame()
  }
  
  func transitionToLevel(level: Int) {
    guard let nextScene = SKScene(fileNamed: "Level\(level)") as? GameScene else {
      fatalError("can not found Level\(level)")
    }
    nextScene.currentLevel = level
    view?.presentScene(nextScene, transition: SKTransition.flipVertical(withDuration: 0.5))
  }
  
  func checkEndGame() {
    if bugsNode.children.count <= 0 {
      print("YOU WIN!!!")
      player.physicsBody?.linearDamping = 1
      gameState = .win
    } else if timeLimit - elapsedTime <= 0 {
      print("YOU LOST:(")
      player.physicsBody?.linearDamping = 1
      gameState = .lose
    }
  }
  
  private func setupCamera() {
    guard let camera = camera,
      let view = view else {
      return
    }
    
    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
    // 1
    let xInset = min(view.bounds.width / 2 * camera.xScale, background.frame.width / 2)
    let yInset = min(view.bounds.height / 2 * camera.yScale, background.frame.height / 2)
    
    // 2
    let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
    
    // 3
    let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
    let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    edgeConstraint.referenceNode = background
    
    // 4
    camera.constraints = [playerConstraint, edgeConstraint]
  }
  
  private func setupPhysicsWorld() {
    background.physicsBody = SKPhysicsBody(edgeLoopFrom: background.frame)
    background.physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsWorld.contactDelegate = self
  }
}

// MARK: - Helper
extension GameScene {
  func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
    return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
  }
  
  func tileCoordicates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
    let column = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    return (column, row)
  }
  
  func createBugs() {
    guard let bugsMap = childNode(withName: "bugs") as? SKTileMapNode else {
      return
    }
    for row in 0..<bugsMap.numberOfRows {
      for column in 0..<bugsMap.numberOfColumns {
        guard let tile = tile(in: bugsMap, at: (column, row)) else { continue }
        //        let bug = Bug()
        let bug: Bug
        if tile.userData?.object(forKey: "firebug") != nil {
          bug = Firebug()
          firebugCount += 1
        } else {
          bug = Bug()
        }
        bug.position = bugsMap.centerOfTile(atColumn: column, row: row)
        bugsNode.addChild(bug)
        bug.moveBug()
      }
    }
    
    bugsNode.name = "Bugs"
    addChild(bugsNode)
    bugsMap.removeFromParent()
  }
  
  func remove(bug: Bug) {
    bug.removeFromParent()
    background.addChild(bug)
    bug.die()
    hud.updateBugCount(count: bugsNode.children.count)
  }
  
  func setupObstaclePhysics() {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    /**
    // 1
    var physicsBodies = [SKPhysicsBody]()
    // 2
    for row in 0..<obstaclesTileMap.numberOfRows {
      for column in 0..<obstaclesTileMap.numberOfColumns {
        guard let tile = tile(in: obstaclesTileMap, at: (column, row)) else { continue }
        // 3
        let center = obstaclesTileMap.centerOfTile(atColumn: column, row: row)
        let body = SKPhysicsBody(rectangleOf: tile.size, center: center)
        physicsBodies.append(body)
      }
    }
    // 4
    obstaclesTileMap.physicsBody = SKPhysicsBody(bodies: physicsBodies)
    obstaclesTileMap.physicsBody?.isDynamic = false
    obstaclesTileMap.physicsBody?.friction = 0
   */
    
    for row in 0..<obstaclesTileMap.numberOfRows {
      for column in 0..<obstaclesTileMap.numberOfColumns {
        guard let tile = tile(in: obstaclesTileMap, at: (column, row)) else { continue }
        guard tile.userData?.object(forKey: "obstacle") != nil else { continue }
        
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Breakable
        node.position = obstaclesTileMap.centerOfTile(atColumn: column, row: row)
        
        obstaclesTileMap.addChild(node)
      }
    }
  }
  
  func createBugspray(quantity: Int) {
    // 1
    let tile = SKTileDefinition(texture: SKTexture(pixelImageNamed: "bugspray"))
    // 2
    let tilerule = SKTileGroupRule(adjacency: SKTileAdjacencyMask.adjacencyAll,
                                   tileDefinitions: [tile])
    // 3
    let tilegroup = SKTileGroup(rules: [tilerule])
    // 4
    let tileset = SKTileSet(tileGroups: [tilegroup])
    // 5
    let columns = background.numberOfColumns
    let rows = background.numberOfRows
    bugsprayTileMap = SKTileMapNode(tileSet: tileset,
                                    columns: columns,
                                    rows: rows,
                                    tileSize: tile.size)
    // 6
    for _ in 0...quantity {
      let column = Int.random(min: 0, max: columns - 1)
      let row = Int.random(min: 0, max: rows - 1)
      bugsprayTileMap?.setTileGroup(tilegroup, forColumn: column, row: row)
    }
    
    // 7
    bugsprayTileMap?.name = "Bugspray"
    addChild(bugsprayTileMap!)
  }
  
  func updateBugspray() {
    guard let bugsprayTileMap = bugsprayTileMap else { return }
    let (column, row) = tileCoordicates(in: bugsprayTileMap, at: player.position)
    if tile(in: bugsprayTileMap, at: (column, row)) != nil {
      bugsprayTileMap.setTileGroup(nil, forColumn: column, row: row)
      player.hasBugspray = true
    }
  }
  
  private func tileGroupForName(tileSet: SKTileSet, name: String) -> SKTileGroup? {
    let tileGroup = tileSet.tileGroups.filter { $0.name == name }.first
    return tileGroup
  }
  
  private func advanceBreakableTile(locateAt nodePosition: CGPoint) {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    // 1
    let (column, row) = tileCoordicates(in: obstaclesTileMap, at: nodePosition)
    // 2
    let obstacle = tile(in: obstaclesTileMap, at: (column, row))
    // 3
    guard let nextTileGroupName = obstacle?.userData?.object(forKey: "breakable") as? String else {
      return
    }
    // 4
    if let nextTileGroup = tileGroupForName(tileSet: obstaclesTileMap.tileSet, name: nextTileGroupName) {
      obstaclesTileMap.setTileGroup(nextTileGroup, forColumn: column, row: row)
    }
    
  }
  
  private func setupHud() {
    camera?.addChild(hud)
//    hud.add(message: "Howdy", position: .zero)
    hud.addTimer(time: timeLimit)
    hud.addBugCount(count: bugsNode.children.count )
  }
  
  func updateHud(currentTime: TimeInterval) {
    if let startTime = startTime {
      elapsedTime = Int(currentTime) - startTime
    } else {
      startTime = Int(currentTime) - elapsedTime
    }
    hud.updateTimer(time: timeLimit - elapsedTime)
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
    switch other.categoryBitMask {
    case PhysicsCategory.Bug:
      if let bug = other.node as? Bug {
        remove(bug: bug)
      }
    case PhysicsCategory.Firebug where player.hasBugspray:
      if let firebug = other.node as? Firebug {
        remove(bug: firebug)
        player.hasBugspray = false
      }
    case PhysicsCategory.Breakable:
      if let obstacleNode = other.node {
        advanceBreakableTile(locateAt: obstacleNode.position)
        obstacleNode.removeFromParent()
      }
    default:
      break
    }
    
    if let physicsBody = player.physicsBody {
      if physicsBody.velocity.length() > 0 {
        player.checkDirection()
      }
    }
  }
}

// MARK: - touches
extension GameScene {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    switch gameState {
    case .start:
      gameState = .play
      isPaused = false
      startTime = nil
      elapsedTime = 0
    case .play:
      player.move(target: touch.location(in: self))
    case .win:
      transitionToLevel(level: currentLevel + 1)
    case .lose:
      transitionToLevel(level: 1)
    case .reload:
      // 1
      if let touchedNode = atPoint(touch.location(in: self)) as? SKLabelNode {
        // 2
        if touchedNode.name == HUDMessages.yes {
          isPaused = false
          startTime = nil
          gameState = .play
          // 3
        } else if touchedNode.name == HUDMessages.no {
          transitionToLevel(level: 1)
        }
      }
    default:
      break
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    player.move(target: touch.location(in: self))
  }
}

// MARK: - Notifications
extension GameScene {
  func applicationDidBecomeActive() {
    print("* applicationDidBecomeActive")
    if gameState == .pause {
      gameState = .reload
    }
  }
  
  func applicationWillResignActive() {
    print("* applicationWillResignActive")
    if gameState != .lose {
      gameState = .pause
    }
  }
  
  func applicationDidEnterBackground() {
    print("* applicationDidEnterBackground")
    if gameState != .lose {
      saveGame()
    }
  }
  
  func addObservers() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
      self?.applicationDidBecomeActive()
    }
    
    notificationCenter.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
      self?.applicationWillResignActive()
    }
    
    notificationCenter.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] _ in
      self?.applicationDidEnterBackground()
    }
    
  }
}

// MARK: - Saving Games
extension GameScene {
  func saveGame() {
    let fileManager = FileManager.default
    guard let libDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
    let saveUrl = libDirectory.appendingPathComponent("SavedGames")
    do {
      try fileManager.createDirectory(atPath: saveUrl.path, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      fatalError("Failed to create directory: \(error.debugDescription)")
    }
    let fileUrl = saveUrl.appendingPathComponent("saved-game")
    print("* Saving: \(fileUrl.path)")
    NSKeyedArchiver.archiveRootObject(self, toFile: fileUrl.path)
  }
  
  override func encode(with aCoder: NSCoder) {
    aCoder.encode(firebugCount, forKey: "Scene.firebugCount")
    aCoder.encode(elapsedTime, forKey: "Scene.elapsedTime")
    aCoder.encode(gameState.rawValue, forKey: "Scene.gameState")
    aCoder.encode(currentLevel, forKey: "Scene.currentLevel")
    super.encode(with: aCoder)
  }
  
  class func loadGame() -> SKScene? {
    print("* loading game")
    var scene: SKScene?
    // 1
    let fileManager = FileManager.default
    guard let directory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
      return nil
    }
    // 2
    let url = directory.appendingPathComponent("SavedGames/saved-game")
    // 3
    if FileManager.default.fileExists(atPath: url.path) {
      scene = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? GameScene
      _ = try? fileManager.removeItem(at: url)
    }
    return scene
  }
}
