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
        HStack{
            Text("Player: \(currentPlayer == .white ? "White" : "Black")")
                .frame(maxWidth: UIScreen.main.bounds.width - 80)
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor( Color(red: 242 / 255.0, green: 188 / 255.0, blue: 36 / 255.0))
        }
        .frame(maxWidth: .infinity)
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
                            
                            
                            
                            
                            
                                if let piece = ChessBoard.pieces.first(where: { $0.position == index }) {
                                Image("\(piece.color == .white ? "White" : "Black")\(piece.type)")
                                    .resizable()
                                    .frame(width: 25, height: 40)
                                    .shadow(color: .black.opacity(1), radius: 2, x: 2, y: -1)
                                    .onTapGesture {
                                        print("\(piece.type)")
                                        selectedPiece = piece
                                        allowedMoves = validMoves(for: piece)
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
                .background(.yellow)
                   
                
                
                    
            
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
        
        
        // Clear selection and allowed moves after the move
        selectedPiece = nil
        allowedMoves = []
    }


    
    
    func validMoves(for piece: chessPiece) -> [Int] {
        var moves: [Int] = []
        
        
        // Only return moves for the current player's piece
            guard piece.color == currentPlayer else {
                return []
            }
        
        
        switch piece.type {
        case .Pawn:
            let direction = piece.color == .white ? -8 : 8  // White moves up, black moves down
            let currentRow = piece.position / 8
            let currentCol = piece.position % 8
            
            // Forward move
            let forwardMove = piece.position + direction
            if ChessBoard.pieces.first(where: { $0.position == forwardMove }) == nil {
                moves.append(forwardMove)
            }
            
            // Initial two-step move
            if (piece.color == .white && currentRow == 6) || (piece.color == .black && currentRow == 1) {
                let twoStepMove = piece.position + (2 * direction)
                if ChessBoard.pieces.first(where: { $0.position == twoStepMove }) == nil {
                    moves.append(twoStepMove)
                }
            }
            
            // Capture diagonally
            let diagonalLeft = piece.position + direction - 1
            let diagonalRight = piece.position + direction + 1
            
            if currentCol > 0, let leftCapture = ChessBoard.pieces.first(where: { $0.position == diagonalLeft && $0.color != piece.color }) {
                moves.append(diagonalLeft)
            }
            
            if currentCol < 7, let rightCapture = ChessBoard.pieces.first(where: { $0.position == diagonalRight && $0.color != piece.color }) {
                moves.append(diagonalRight)
            }
            
        // Handle other pieces if needed
        default:
            break
        }
        
        return moves
    }


   
}

#Preview {
    ContentView()
}
