classdef GameState < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        board
        piecesPlayer1
        piecesPlayer2
        winners
        playerTurn
        nextTurn
        binary
        id
        allowedActions
        isEndGame
        winner
        value
        inputToModel
    end
    
    methods (Access  = private)
        
        function binary = getBinary(self)
            
            currentplayer_position = zeros(size(self.board));
            currentplayer_position(self.board == self.playerTurn) = 1;
            
            otherplayer_position = zeros(size(self.board));
            otherplayer_position(self.board == self.nextTurn) = 1;
            
            binary = [currentplayer_position otherplayer_position];
            
        end
        
        function id = convertStateToId(self)
            
            player1_position = zeros(size(self.board));
            player1_position(self.board == 1) = 1;
            
            otherplayer_position = zeros(size(self.board));
            otherplayer_position(self.board == 2) = 1;
            
            id1 = sprintf('%d',player1_position);
            id2 = sprintf('%d',otherplayer_position);
            
            dec1 = bin2dec(id1);
            hex1 = dec2hex(dec1);
            dec2 = bin2dec(id2);
            hex2 = dec2hex(dec2);
            
            id = sprintf('id%s',[hex1 hex2]);
        end
        
        function allowedActions = getAllowedActions(self)
            
%             allowedActions = zeros(1,7);
%             j=0;
%             
%             for i = (6:-1:0)
%                 for k = (length(self.board)-i):-7:1
%                     if k > length(self.board)-7
%                         if self.board(k) == 0
%                             allowedActions(i+1) = k;
%                             j=j+1;
%                         end
%                     else
%                         if (self.board(k) == 0) && (self.board(k+7) ~= 0)
%                             allowedActions(i+1) = k;
%                             j=j+1;
%                         end
%                     end
%                 end
%             end
%             allowedActions = flip(allowedActions(1:j));

            allowedActions = [];
            for i = 1:length(self.board)
                if i > (length(self.board) - 7)
                    if self.board(i)==0
                        allowedActions = [allowedActions i];
                    end
                else
                    if (self.board(i) == 0) && (self.board(i+7) ~= 0)
                        allowedActions = [allowedActions i];                            
                    end
                end
            end
        end
        
        function [isEndGame,winner] = checkForEndGame(self)
            
            isEndGame = false;
            winner = 0;
            
            n_pieces = sum(self.board ~= 0);
            if n_pieces == 42
                isEndGame = true;
            end
            
            for k = 1:size(self.winners,1)
                v = self.board(self.winners(k,:));
                if sum(v == self.nextTurn) == 4
                    isEndGame = true;
                    winner = self.nextTurn;
                    return
                end
            end
        end
        
    end
    
    methods
        
        function self = GameState(varargin)
            
            if isempty(varargin)
                board=zeros(1,42);
                playerTurn=1;
            elseif length(varargin) == 1
                board=varargin{1};
                playerTurn=1;
            elseif length(varargin) == 2
                board=varargin{1};
                playerTurn=varargin{2};
            elseif length(varargin) > 2
                logger.error('playMatches','Too many arguments.');
            end
            
            self.board = board;
            self.playerTurn = playerTurn;
            if playerTurn == 1
                self.nextTurn = 2;
            else
                self.nextTurn = 1;
            end
            self.piecesPlayer1 = 'X';
            self.piecesPlayer2 = 'O';
            
            self.winners = [...
            [1,2,3,4];...
            [2,3,4,5];...
            [3,4,5,6];...
            [4,5,6,7];...
            [8,9,10,11];...
            [9,10,11,12];...
            [10,11,12,13];...
            [11,12,13,14];...
            [15,16,17,18];...
            [16,17,18,19];...
            [17,18,19,20];...
            [18,19,20,21];...
            [22,23,24,25];...
            [23,24,25,26];...
            [24,25,26,27];...
            [25,26,27,28];...
            [29,30,31,32];...
            [30,31,32,33];...
            [31,32,33,34];...
            [32,33,34,35];...
            [36,37,38,39];...
            [37,38,39,40];...
            [38,39,40,41];...
            [39,40,41,42];...
            
            [1,8,15,22];...
            [8,15,22,29];...
            [15,22,29,36];...
            [2,9,16,23];...
            [9,16,23,30];...
            [16,23,30,37];...
            [3,10,17,24];...
            [10,17,24,31];...
            [17,24,31,38];...
            [4,11,18,25];...
            [11,18,25,32];...
            [18,25,32,39];...
            [5,12,19,26];...
            [12,19,26,33];...
            [19,26,33,40];...
            [6,13,20,27];...
            [13,20,27,34];...
            [20,27,34,41];...
            [7,14,21,28];...
            [14,21,28,35];...
            [21,28,35,42];...
            
            [4,10,16,22];...
            [5,11,17,23];...
            [11,17,23,29];...
            [6,12,18,24];...
            [12,18,24,30];...
            [18,24,30,36];...
            [7,13,19,25];...
            [13,19,25,31];...
            [19,25,31,37];...
            [14,20,26,32];...
            [20,26,32,38];...
            [21,27,33,39];...
            
            [4,12,20,28];...
            [3,11,19,27];...
            [11,19,27,35];...
            [2,10,18,26];...
            [10,18,26,34];...
            [18,26,34,42];...
            [1,9,17,25];...
            [9,17,25,33];...
            [17,25,33,41];...
            [8,16,24,32];...
            [16,24,32,40];...
            [15,23,31,39]
			];
            
            self.binary = self.getBinary();
            self.id = self.convertStateToId();
            self.allowedActions = self.getAllowedActions();
            [self.isEndGame,self.winner] = self.checkForEndGame();
            
        end
        
        function [newState, winner, value, done] = takeAction(self, action)
            
            newBoard = self.board;
            newBoard(action) = self.playerTurn;
            
            newState = GameState(newBoard, self.nextTurn);
            
            winner = 0;
            value = 0;
            done = 0;
            
            if newState.isEndGame
                winner = newState.winner;
                done = true;
                if winner == self.playerTurn
                    value = 1;
                elseif winner == self.nextTurn
                    value = -1;
                end
            end
            
        end
        
        function render_info(self,func,logger)
            x = repmat('-',1,42);
            x(self.board==1) = self.piecesPlayer1;
            x(self.board==2) = self.piecesPlayer2;
            y = reshape(x,[7 6])';
            logger.info(func,'---------------------');
            for r = 1:6
                s = [];
                for c = 1:7
                    s = [s sprintf(' %c ',y(r,c))];
                end
                logger.info(func,s);
            end
            logger.info(func,'---------------------');
        end
        
        function render_debug(self,func,logger)
            x = repmat('-',1,42);
            x(self.board==1) = self.piecesPlayer1;
            x(self.board==2) = self.piecesPlayer2;
            y = reshape(x,[7 6])';
            logger.debug(func,'---------------------');
            for r = 1:6
                s = [];
                for c = 1:7
                    s = [s sprintf(' %c ',y(r,c))];
                end
                logger.debug(func,s);
            end
            logger.debug(func,'---------------------');
        end
        
        function render_trace(self,func,logger)
            x = repmat('-',1,42);
            x(self.board==1) = self.piecesPlayer1;
            x(self.board==2) = self.piecesPlayer2;
            y = reshape(x,[7 6])';
            logger.trace(func,'---------------------');
            for r = 1:6
                s = [];
                for c = 1:7
                    s = [s sprintf(' %c ',y(r,c))];
                end
                logger.trace(func,s);
            end
            logger.trace(func,'---------------------');
        end
        
    end
    
end

