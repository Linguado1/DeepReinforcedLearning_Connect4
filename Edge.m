classdef Edge
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        inNode
        outNode
        playerTurn
        action
        stats_N = 0
        stats_W = 0
        stats_Q = 0
        stats_P
    end
    
    methods
        
        function self = Edge(inNode, outNode, prior, action)
            
            self.id = [inNode.state.id '_' outNode.state.id];
            self.inNode = inNode;
            self.outNode = outNode;
            self.playerTurn = inNode.state.playerTurn;
            self.action = action;
            self.stats_P = prior;
            
        end
        
    end
    
end

