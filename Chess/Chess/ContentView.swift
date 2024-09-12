//
//  ContentView.swift
//  Chess
//
//  Created by Ammad Gulazr on 03/09/2024.
//

import SwiftUI

enum pieceType{
    case King, Queen, Rook, Bishop, Knight, Pawn
}
enum pieceColor{
    case white, black
    
}
extension pieceColor {
    var opponent: pieceColor {
        return self == .white ? .black : .white
    }
}

struct chessPiece {
    var type : pieceType
    var color : pieceColor
    var position : Int
    var hasMoved: Bool = false
}
struct chessBoard {
    var pieces : [chessPiece]
    init() {
        self.pieces = []
        setUpBoard()
    }
    
    mutating func setUpBoard(){
        
//          Blacks
        for i in 8..<16{
            
            pieces.append(chessPiece(type: .Pawn, color: .black, position: i))
        }
        
        pieces.append(chessPiece(type: .Rook, color: .black, position: 0))
        pieces.append(chessPiece(type: .Rook, color: .black, position: 7))
        pieces.append(chessPiece(type: .Knight, color: .black, position: 1))
        pieces.append(chessPiece(type: .Knight, color: .black, position: 6))
        pieces.append(chessPiece(type: .Bishop, color: .black, position: 2))
        pieces.append(chessPiece(type: .Bishop, color: .black, position: 5))
        pieces.append(chessPiece(type: .King, color: .black, position: 3))
        pieces.append(chessPiece(type: .Queen, color: .black, position: 4))
//          Whites
        for i in 48..<56 {
            pieces.append(chessPiece(type: .Pawn, color: .white, position: i))
        }
        pieces.append(chessPiece(type: .Rook, color: .white, position: 56))
        pieces.append(chessPiece(type: .Rook, color: .white, position: 63))
        pieces.append(chessPiece(type: .Knight, color: .white, position: 57))
        pieces.append(chessPiece(type: .Knight, color: .white, position: 62))
        pieces.append(chessPiece(type: .Bishop, color: .white, position: 58))
        pieces.append(chessPiece(type: .Bishop, color: .white, position: 61))
        pieces.append(chessPiece(type: .King, color: .white, position: 59))
        pieces.append(chessPiece(type: .Queen, color: .white, position: 60))
    }
    
}
var opponentTargets: Set<Int> = []
//var friendsTargets: Set<Int> = []
var kingPosition: Int = 0
var KingIsInDanger: Bool = false
var friendsTargets: Set<Int> = []


struct ContentView: View {
    
    
    
    
    @State private var ChessBoard = chessBoard()
    @State private var selectedPiece: chessPiece?
    @State private var allowedMoves: [Int] = []
    @State private var currentPlayer: pieceColor = .white // Assuming white starts first

    
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 8)
        
        ZStack(){
            
            Image("RedBg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                            
        VStack(spacing: 30){
//            Timer Lable
        HStack{
            Text("00:00")
            .frame(maxWidth: UIScreen.main.bounds.width - 80)
            .font(.system(size: 50))
            .fontWeight(.bold)
            .foregroundColor( Color(red: 242 / 255.0, green: 188 / 255.0, blue: 36 / 255.0))
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .stroke(( Color(red: 242 / 255.0, green: 188 / 255.0, blue: 36 / 255.0)) , lineWidth: 2)
                    )
        }
        .frame(maxWidth: .infinity)
//            Player Lable
        HStack{
            Text("Player: \(currentPlayer == .white ? "White" : "Black")")
                .frame(maxWidth: UIScreen.main.bounds.width - 80)
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor( Color(red: 242 / 255.0, green: 188 / 255.0, blue: 36 / 255.0))
        }
        .frame(maxWidth: .infinity)
//            ChessBoard
        ZStack(){
            Image("BoardBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .shadow(color: .black.opacity(0.7), radius: 20, x: 0, y: 1) // Apply shadow here
            HStack{
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<64) { index in
                        ZStack {
                            
                                if (index / 8 + index % 8) % 2 == 0 {
                                    Image("WhiteCell") // Background image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .shadow(color: .white.opacity(0.2), radius:15, x: 0, y: 0)
                                } else {
                                    Image("BrownCell")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .shadow(color: .white.opacity(0.2), radius:15, x: 0, y: 0)
                                }
                            
                            // Highlight King Danger
                                            if KingIsInDanger && kingPosition == index {
                                                Rectangle()
                                                    .fill(Color.red.opacity(0.7)) // Use red to indicate danger
                                                    .frame(width: (UIScreen.main.bounds.width - 5 ) / 8, height: (UIScreen.main.bounds.width - 20) / 8)
                                            }
                            
                                // Add index number for debugging purposes
                                    Text("\(index)")
                                        .font(.title)
                                        .foregroundColor(.red)
                            
                          
                            
                            
                            
//                                Placing Pieces at board
                            if let piece = ChessBoard.pieces.first(where: { $0.position == index }) {
                                Image("\(piece.color == .white ? "White" : "Black")\(piece.type)")
                                    .resizable()
                                    .frame(width: 25, height: 40)
                                    .shadow(color: .black.opacity(1), radius: 2, x: 2, y: -1)
                                    .onTapGesture {
                                        print("\(piece.type)")
                                        selectedPiece = piece
                                        allowedMoves = validMoves(for: piece , CalledFromPlayer: true)
                                    }
                                                    
                                    }
                            
                            if allowedMoves.contains(index) {
                                    Rectangle()
                                        .fill(Color.green.opacity(0.5))
                                        .frame(width: (UIScreen.main.bounds.width - 5 ) / 8, height: (UIScreen.main.bounds.width - 20) / 8)
                                        .onTapGesture {
                                            print("tapped")
                                            if let selectedPiece = selectedPiece {
                                                movePiece(to: index, piece: selectedPiece)
                                            }
                                        }
                                }
                            
                           
                            
                            
                                        }
                                        .frame(width: (UIScreen.main.bounds.width - 5 ) / 8, height: (UIScreen.main.bounds.width - 20) / 8)
                    }
                        }.padding(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 430)
                HStack{
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
            }
        }.ignoresSafeArea(.all)
    }
    
    func movePiece(to index: Int, piece: chessPiece) {
        
        
        // Check if the piece belongs to the current player
            guard piece.color == currentPlayer else {
                print("It's not your turn!")
                return
            }
        
        // Remove any captured piece
        if let capturedIndex = ChessBoard.pieces.firstIndex(where: { $0.position == index }) {
            ChessBoard.pieces.remove(at: capturedIndex)
        }
        
        // Update the piece's position
        if let pieceIndex = ChessBoard.pieces.firstIndex(where: { $0.position == piece.position }) {
            ChessBoard.pieces[pieceIndex].position = index
        }
        
        // Switch turn to the other player
            currentPlayer = currentPlayer == .white ? .black : .white
//        calculateOpponentTargets for next turn
        calculateOpponentTargets(for: currentPlayer)
        print("\(currentPlayer)\(opponentTargets)")
       //       		 calculateFriendsTargets(for: currentPlayer)
        
        for ChessPiece in ChessBoard.pieces where ChessPiece.color == currentPlayer {
            
            if ChessPiece.type == .King {
                
                kingPosition = ChessPiece.position
                print("King Position \(kingPosition)")
            }
            
            
        }
        
        print("Condition : \(opponentTargets.contains(kingPosition))")
        
        if opponentTargets.contains(kingPosition) {
            KingIsInDanger = true
            print("King is in danger ")
            
        }else{
            KingIsInDanger = false
        }
        
        

        // Clear selection and allowed moves after the move
        selectedPiece = nil
        allowedMoves = []
    }

    func pawnAndKingTargets(for piece: chessPiece) -> [Int] {
        var targets: [Int] = []
        
        let direction = piece.color == .white ? -8 : 8  // White moves up, black moves down
        
       
        
        switch piece.type {
            
            
        case .Pawn:
            // Capture diagonally
            let diagonalLeft = piece.position + direction - 1
            let diagonalRight = piece.position + direction + 1
            
            // Ensure capture doesn't wrap around the board
            if isValidPosition(diagonalLeft) && (piece.position % 8) > 0 {
              
                    targets.append(diagonalLeft)
               
            }
            
            if isValidPosition(diagonalRight) && (piece.position % 8) < 7 {
             
                    targets.append(diagonalRight)
            }
            
            
        case .King :
            // Current position of the King
            let currentPosition = piece.position
            
            // Calculate current row and column from the current position
            let currentRow = currentPosition / 8
            let currentCol = currentPosition % 8

            // All possible moves for a King (1 cell in all directions)
            let kingMoves = [
                (currentRow + 1, currentCol),     // Down
                (currentRow - 1, currentCol),     // Up
                (currentRow, currentCol + 1),     // Right
                (currentRow, currentCol - 1),     // Left
                (currentRow + 1, currentCol + 1), // Down-right
                (currentRow + 1, currentCol - 1), // Down-left
                (currentRow - 1, currentCol + 1), // Up-right
                (currentRow - 1, currentCol - 1)  // Up-left
            ]
            for (newRow, newCol) in kingMoves {
                // Check if the move is within board bounds
                if newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                    let newPosition = newRow * 8 + newCol
                    targets.append(newPosition) // Capture the opponent's piece
                        
                  
                }
            }
            // Handle other pieces if needed
            default:
                break
        }
        
      
        
        return targets
    }
    func validMoves(for piece: chessPiece , CalledFromPlayer : Bool) -> [Int] {
        
        
        
        
        var moves: [Int] = []

//        If called from player dont allow the player to play with out his turn
        if CalledFromPlayer == true {
            // Only return moves for the current player's piece
                guard piece.color == currentPlayer else {
                    print("CalledFromPlayer is : \(CalledFromPlayer)")
                    return []
                }
        }
        
        
        let direction = piece.color == .white ? -8 : 8  // White moves up, black moves down
        let currentRow = piece.position / 8
//        let currentCol = piece.position % 8
        
        
        
        switch piece.type {


        case .Pawn:
            // Forward move
            let forwardMove = piece.position + direction
            if isValidPosition(forwardMove) && ChessBoard.pieces.first(where: { $0.position == forwardMove }) == nil {
                moves.append(forwardMove)
            }

            // Initial two-step move (check no piece is in the way)
            if (piece.color == .white && currentRow == 6) || (piece.color == .black && currentRow == 1) {
                let oneStepMove = piece.position + direction
                let twoStepMove = piece.position + (2 * direction)
                if isValidPosition(twoStepMove),
                   ChessBoard.pieces.first(where: { $0.position == oneStepMove }) == nil,  // Ensure no piece in the way
                   ChessBoard.pieces.first(where: { $0.position == twoStepMove }) == nil {
                    moves.append(twoStepMove)
                }
            }

            // Capture diagonally
            let diagonalLeft = piece.position + direction - 1
            let diagonalRight = piece.position + direction + 1
            
            // Ensure capture doesn't wrap around the board
            if isValidPosition(diagonalLeft) && (piece.position % 8) > 0 {
                if ChessBoard.pieces.first(where: { $0.position == diagonalLeft && $0.color != piece.color }) != nil {
                    moves.append(diagonalLeft)
                }
            }

            if isValidPosition(diagonalRight) && (piece.position % 8) < 7 {
                if ChessBoard.pieces.first(where: { $0.position == diagonalRight && $0.color != piece.color }) != nil {
                    moves.append(diagonalRight)
                }
            }

            
            
        case .Rook:
                // Rook can move vertically and horizontally
                
                // Check upward direction
                var up = piece.position - 8
                while up >= 0, ChessBoard.pieces.first(where: { $0.position == up }) == nil {
                    moves.append(up)
                    up -= 8
                }
                // If there's an enemy piece in the upward direction, capture it
            if ChessBoard.pieces.first(where: { $0.position == up && $0.color != piece.color }) != nil {
                    moves.append(up)
                }
                
                // Check downward direction
                var down = piece.position + 8
                while down < 64, ChessBoard.pieces.first(where: { $0.position == down }) == nil {
                    moves.append(down)
                    down += 8
                }
                // Capture enemy piece downward
            if ChessBoard.pieces.first(where: { $0.position == down && $0.color != piece.color }) != nil {
                    moves.append(down)
                }
                
                // Check leftward direction
                var left = piece.position - 1
                while left >= 0, piece.position / 8 == left / 8, ChessBoard.pieces.first(where: { $0.position == left }) == nil {
                    moves.append(left)
                    left -= 1
                }
                // Capture enemy piece left
                if piece.position / 8 == left / 8, let enemyPiece = ChessBoard.pieces.first(where: { $0.position == left && $0.color != piece.color }) {
                    moves.append(left)
                }
                
                // Check rightward direction
                var right = piece.position + 1
                while right < 64, piece.position / 8 == right / 8, ChessBoard.pieces.first(where: { $0.position == right }) == nil {
                    moves.append(right)
                    right += 1
                }
                // Capture enemy piece right
                if piece.position / 8 == right / 8, let enemyPiece = ChessBoard.pieces.first(where: { $0.position == right && $0.color != piece.color }) {
                    moves.append(right)
                }
            
            
        case .Knight:
                let currentRow = piece.position / 8
                let currentCol = piece.position % 8
                
                // All possible knight moves
                let knightMoves = [
                    (currentRow + 2, currentCol + 1), (currentRow + 2, currentCol - 1),
                    (currentRow - 2, currentCol + 1), (currentRow - 2, currentCol - 1),
                    (currentRow + 1, currentCol + 2), (currentRow + 1, currentCol - 2),
                    (currentRow - 1, currentCol + 2), (currentRow - 1, currentCol - 2)
                ]
                
                for (newRow, newCol) in knightMoves {
                    if newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                        let newPosition = newRow * 8 + newCol
                        if let targetPiece = ChessBoard.pieces.first(where: { $0.position == newPosition }) {
                            if targetPiece.color != piece.color {
                                // Capture opponent's piece
                                moves.append(newPosition)
                            }
                        } else {
                            // Empty square, valid move
                            moves.append(newPosition)
                        }
                    }
                }
            
            
        case .Bishop:
                let directions = [
                    (1, 1),   // Down-right
                    (1, -1),  // Down-left
                    (-1, 1),  // Up-right
                    (-1, -1)  // Up-left
                ]
                
                let currentRow = piece.position / 8
                let currentCol = piece.position % 8
                
                for (rowDelta, colDelta) in directions {
                    var newRow = currentRow + rowDelta
                    var newCol = currentCol + colDelta
                    
                    while newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                        let newPosition = newRow * 8 + newCol
                        if let targetPiece = ChessBoard.pieces.first(where: { $0.position == newPosition }) {
                            if targetPiece.color != piece.color {
                                // Capture opponent's piece
                                moves.append(newPosition)
                            }
                            // Stop if there's a piece (either capture or block)
                            break
                        } else {
                            // Empty square, valid move
                            moves.append(newPosition)
                        }
                        // Continue moving in the same direction
                        newRow += rowDelta
                        newCol += colDelta
                    }
                }

            
        case .Queen:
                // Combine rook and bishop logic for the queen

                // Rook-like movements (vertical and horizontal)
                let rookDirections = [
                    (1, 0),  // Down
                    (-1, 0), // Up
                    (0, 1),  // Right
                    (0, -1)  // Left
                ]
                
                // Bishop-like movements (diagonals)
                let bishopDirections = [
                    (1, 1),   // Down-right
                    (1, -1),  // Down-left
                    (-1, 1),  // Up-right
                    (-1, -1)  // Up-left
                ]
                
                let currentRow = piece.position / 8
                let currentCol = piece.position % 8

                // Handle rook-like movements
                for (rowDelta, colDelta) in rookDirections {
                    var newRow = currentRow + rowDelta
                    var newCol = currentCol + colDelta
                    
                    while newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                        let newPosition = newRow * 8 + newCol
                        if let targetPiece = ChessBoard.pieces.first(where: { $0.position == newPosition }) {
                            if targetPiece.color != piece.color {
                                // Capture opponent's piece
                                moves.append(newPosition)
                            }
                            // Stop if there's a piece (either capture or block)
                            break
                        } else {
                            // Empty square, valid move
                            moves.append(newPosition)
                        }
                        // Continue moving in the same direction
                        newRow += rowDelta
                        newCol += colDelta
                    }
                }
                // Handle bishop-like movements
                for (rowDelta, colDelta) in bishopDirections {
                    var newRow = currentRow + rowDelta
                    var newCol = currentCol + colDelta
                    
                    while newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                        let newPosition = newRow * 8 + newCol
                        if let targetPiece = ChessBoard.pieces.first(where: { $0.position == newPosition }) {
                            if targetPiece.color != piece.color {
                                // Capture opponent's piece
                                moves.append(newPosition)
                            }
                            // Stop if there's a piece (either capture or block)
                            break
                        } else {
                            // Empty square, valid move
                            moves.append(newPosition)
                        }
                        // Continue moving in the same direction
                        newRow += rowDelta
                        newCol += colDelta
                    }
                }
            
        case .King:
            // Current position of the King
            let currentPosition = piece.position
            
            // Calculate current row and column from the current position
            let currentRow = currentPosition / 8
            let currentCol = currentPosition % 8

            // All possible moves for a King (1 cell in all directions)
            let kingMoves = [
                (currentRow + 1, currentCol),     // Down
                (currentRow - 1, currentCol),     // Up
                (currentRow, currentCol + 1),     // Right
                (currentRow, currentCol - 1),     // Left
                (currentRow + 1, currentCol + 1), // Down-right
                (currentRow + 1, currentCol - 1), // Down-left
                (currentRow - 1, currentCol + 1), // Up-right
                (currentRow - 1, currentCol - 1)  // Up-left
            ]

            // Remove the king temporarily from the board
            if let kingIndex = ChessBoard.pieces.firstIndex(where: { $0.position == currentPosition && $0.type == .King }) {
                let king = ChessBoard.pieces.remove(at: kingIndex)

                // Calculate opponent targets without the king on the board
                calculateOpponentTargets(for: currentPlayer)

                // Loop through all possible king moves
                for (newRow, newCol) in kingMoves {
                    // Check if the move is within board bounds
                    if newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                        let newPosition = newRow * 8 + newCol
                        
                        // Check if the cell is occupied by a friendly piece
                        if ChessBoard.pieces.first(where: { $0.position == newPosition && $0.color == piece.color }) != nil {
                            continue // Skip if there's a friendly piece
                        }
                        
                        // Check if the cell is occupied by an opponent's piece (capture move)
                        let isCaptureMove = ChessBoard.pieces.contains { $0.position == newPosition && $0.color != piece.color }

                        // Only add the move if it's not targeted by any opponent
                        if !opponentTargets.contains(newPosition) {
                            moves.append(newPosition) // Add the valid move or capture
                        }
                    }
                }

                // Restore the king back to the board
                ChessBoard.pieces.insert(king, at: kingIndex)
            }

            
            
            
            
            
            
        }
        
        return moves
        
    }

    func isValidPosition(_ position: Int) -> Bool {
        return position >= 0 && position < 64
    }
    
    func calculateOpponentTargets(for currentPlayerColor: pieceColor) {
        opponentTargets.removeAll()  // Clear the previous targets

        for opponentPiece in ChessBoard.pieces where opponentPiece.color != currentPlayerColor {
            
            
            let targets: Set<Int>

            if opponentPiece.type == .King || opponentPiece.type == .Pawn {
                // Convert the array result to a set before adding to opponentTargets
                targets = Set(pawnAndKingTargets(for: opponentPiece))
            } else {
                targets = Set(validMoves(for: opponentPiece, CalledFromPlayer: false))
            }

            opponentTargets.formUnion(targets)
            
        }
    }
    
    
    
    
    func calculateFriendsTargets(for currentPlayerColor: pieceColor) {
        opponentTargets.removeAll()  // Clear the previous targets
        for friendPiece in ChessBoard.pieces where friendPiece.color == currentPlayerColor {
            let targets: Set <Int>

            if friendPiece.type == .King || friendPiece.type == .Pawn {
//                 Convert the array result to a set before adding to opponentTargets
                targets = Set(pawnAndKingTargets(for: friendPiece))
            } else {
                targets = Set(validMoves(for: friendPiece, CalledFromPlayer: false))
            }
            friendsTargets.formUnion(targets)
        }
    }



   
}

#Preview {
    ContentView()
}


