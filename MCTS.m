classdef MCTS < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
        tree = struct
        cpuct
        logger
        Epsilon
        Alpha
    end
    
    methods
        
        function self = MCTS(root, cpuct, logger, Epsilon, Alpha)
            self.root = root;
            self.cpuct = cpuct;
            self.addNode(root);
            self.logger = logger;
            self.Epsilon = Epsilon;
            self.Alpha = Alpha;
        end
        
        function [currentNode, winner, value, done, breadcrumbs] = moveToLeaf(self)
            
            self.logger.trace('moveToLeaf','**** MOVING TO LEAF ****');
            
            breadcrumbs = [];
            currentNode = self.tree.(self.root.id);
            playerTurn = currentNode.playerTurn;
            
            done = 0;
            value = 0;
            winner = 0;
            
            while ~currentNode.isLeaf()
                
                self.logger.trace('moveToLeaf',sprintf('PLAYER TURN...%d',currentNode.state.playerTurn));
                
                maxQU = -99999;
                
                if strcmp(currentNode.id, self.root.id)
                    epsilon = self.Epsilon;
                    nu = dirichlet(self.Alpha, length(currentNode.edges));
                else
                    epsilon = 0;
                    nu = zeros(1,length(currentNode.edges));
                end
                
                Nb = 0;
                for k = 1:length(currentNode.edges)
                    Nb = Nb + currentNode.edges(k).stats_N;
                end
                
                for k = 1:length(currentNode.edges)
                    
                    thisEdge = currentNode.edges(k);
                    thisAction = thisEdge.action;
                    
                    adjP = ((1-epsilon) * thisEdge.stats_P + epsilon * nu(k));
                    U = self.cpuct * adjP * sqrt(Nb) / (1 + thisEdge.stats_N);
                    N = thisEdge.stats_N;
                    P = thisEdge.stats_P;
                    W = thisEdge.stats_W;
                    Q = thisEdge.stats_Q;
                    NU = nu(k);
                    QU = Q+U;
                    
                    if isnan(P)
                        disp('NaN')
                    end
                    
                    self.logger.trace('moveToLeaf',sprintf('action: %d (%d)... N = %d, P = %.6f, nu = %.6f, adjP = %.6f, W = %.6f, Q = %.6f, U = %.6f, Q+U = %.6f',...
                        thisAction, mod(thisAction,7), N, P, NU, adjP, W, Q, U, QU));
                    
                    if QU > maxQU
                        maxQU = QU;
                        simulationAction = thisAction;
                        simulationEdge = thisEdge;
                    end
                    
                end
                
                self.logger.trace('moveToLeaf',sprintf('action with highest Q + U...%d', simulationAction));

                % value of the newState for the next player
                [~, winner, value, done] = currentNode.state.takeAction(simulationAction);

                currentNode = self.tree.(simulationEdge.outNode.id);
                currentNode.playerTurn = playerTurn;
                
                breadcrumbs = [breadcrumbs simulationEdge];
                  
                self.logger.trace('moveToLeaf',sprintf('DONE...%d',done));
                
            end
            
        end
        
        function backFill(self, leaf, value, breadcrumbs)
            
            self.logger.trace('backFill','**** DOING BACKFILL ****');
            
            currentPlayer = leaf.state.nextTurn;
            
            for k = 1:length(breadcrumbs)
                thisEdge = breadcrumbs(k);
                
                playerTurn = thisEdge.playerTurn;
                if playerTurn == currentPlayer
                    direction = 1;
                else
                    direction = -1;
                end

                % Encontra thisEdge na arvore
                for i = 1:length(self.tree.(thisEdge.inNode.id).edges)
                    if strcmp(self.tree.(thisEdge.inNode.id).edges(i).id, thisEdge.id)
                        break
                    end
                end
                
                self.tree.(thisEdge.inNode.id).edges(i).stats_N = self.tree.(thisEdge.inNode.id).edges(i).stats_N + 1;
                self.tree.(thisEdge.inNode.id).edges(i).stats_W = self.tree.(thisEdge.inNode.id).edges(i).stats_W + value * direction;
                self.tree.(thisEdge.inNode.id).edges(i).stats_Q = self.tree.(thisEdge.inNode.id).edges(i).stats_W /...
                    self.tree.(thisEdge.inNode.id).edges(i).stats_N;
                
                thisEdge = self.tree.(thisEdge.inNode.id).edges(i);
                self.logger.trace('backFill',sprintf('updating edge with value %.6f for player %d... N = %d, W = %.6f, Q = %.6f',...
                    value * direction, playerTurn, thisEdge.stats_N, thisEdge.stats_W, thisEdge.stats_Q));

                thisEdge.outNode.state.render_trace('backFill',self.logger);
                
            end
        end
        
%         function setEdges(self, leaf, breadcrumbs)
%             
%             self.root.breadcrumbs(1).outNode.breadcrumbs(2).outNode
%             
%         end
        
        function addNode(self, node)
            self.tree.(node.id) = node;
        end
        
    end
    
end

