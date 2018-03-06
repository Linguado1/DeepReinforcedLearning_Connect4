classdef Memory < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Memory_Size
        ltmemory
        stmemory
        iST = 0
        iLT = 0
    end
    
    methods
        
        function self = Memory(Memory_Size)
            self.Memory_Size = Memory_Size;
            self.clear_ltmemory();
            self.clear_stmemory();
        end
        
        function commit_stmemory(self, identities) 
            for i = 1:size(identities,1)
                item = struct('board', identities{i,1}.board,...
                    'state', identities{i,1},...
                    'id', identities{i,1}.id,...
                    'AV', identities{i,2},...
                    'value', 0,...
                    'playerTurn', identities{i,1}.playerTurn);
                self.STappend(item);
                self.iST = min(self.iST + 1, self.Memory_Size);
            end
        end
        
        function commit_ltmemory(self)
            for k = 1:self.iST
                self.LTappend(self.stmemory(k));
                self.iLT = min(self.iLT + 1, self.Memory_Size);
            end
            self.clear_stmemory();
        end
        
        function STappend(self, item)
            self.stmemory(2:end) = self.stmemory(1:end-1);
            self.stmemory(1) = item;
        end
        
        function LTappend(self, item)
            self.ltmemory(2:end) = self.ltmemory(1:end-1);
            self.ltmemory(1) = item;
        end
        
        function clear_stmemory(self)
            clearState = GameState();
            item = struct('board', clearState.board,...
                'state', clearState,...
                'id', clearState.id,...
                'AV', clearState.board,...
                'value', 0,...
                'playerTurn', clearState.playerTurn);
            
            self.stmemory = repmat(item,self.Memory_Size,1);
            self.iST = 0;
        end
        
        function clear_ltmemory(self)
            clearState = GameState();
            item = struct('board', clearState.board,...
                'state', clearState,...
                'id', clearState.id,...
                'AV', clearState.board,...
                'value', 0,...
                'playerTurn', clearState.playerTurn);
            
            self.ltmemory = repmat(item,self.Memory_Size,1);
            self.iLT = 0;
        end
        
    end
    
end

