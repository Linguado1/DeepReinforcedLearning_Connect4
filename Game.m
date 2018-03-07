classdef Game < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentPlayer
        otherPlayer
        gameState
        actionSpace
        piecesPlayer1
        piecesPlayer2
        grid_shape
        input_shape
        name
        state_size
        action_size
    end
    
    methods
        
        function self = Game()
            self.currentPlayer = 1;
            self.otherPlayer = 2;
            self.gameState = GameState();
            self.actionSpace = zeros(1,42);
            self.piecesPlayer1 = 'X';
            self.piecesPlayer2 = 'O';
            self.grid_shape = [6 7];
            self.input_shape = [6 7 2];
            self.name = 'Connect4';
            self.state_size = length(self.gameState.binary);
            self.action_size = length(self.actionSpace);
        end
        
        function gameState = reset(self)
            self.currentPlayer = 1;
            self.otherPlayer = 2;
            self.gameState = GameState();
            gameState = self.gameState;
        end
        
        function [next_state, winner, value, done] = step(self, action)
           [next_state, winner, value, done] = self.gameState.takeAction(action);
           self.gameState = next_state;
           
           oldPlayer = self.currentPlayer;
           self.currentPlayer = self.otherPlayer;
           self.otherPlayer = oldPlayer;
        end
        
        function identities = Identities(self, state, actionValues)
            identities = [{state},{actionValues}];
            
            flipBoard = reshape(flip(reshape(state.board,[7 6])',2)',1,42);
            flipAV = reshape(flip(reshape(actionValues,[7 6])',2)',1,42);
            
            flipState = GameState(flipBoard, state.playerTurn);
            if ~strcmp(state.id, flipState.id)
                identities(2,1) = {flipState};
                identities(2,2) = {flipAV};
            end
        end
        
    end
    
end

