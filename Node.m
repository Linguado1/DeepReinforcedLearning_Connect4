classdef Node
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        state
        playerTurn
        id
        edges = [];
    end
    
    methods
        
        function self = Node(state)
            self.state = state;
            self.playerTurn = state.playerTurn;
            self.id = state.id;
        end
        
        function bool = isLeaf(self)
            bool = isempty(self.edges);
        end
        
    end
    
end

