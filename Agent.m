classdef Agent < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        state_size
        action_size
        logger
        
        cpuct
        
        MCTS_simulations
        model
        
        mcts
        
        Epsilon = .2
        Alpha = .8
        
        train_overall_loss
        train_value_loss
        train_policy_loss
        val_overall_loss
        val_value_loss
        val_policy_loss
    end
    
    methods
        
        function self = Agent(name, state_size, action_size, logger, mcts_simulations, cpuct, model)
            self.name = name;
            self.state_size = state_size;
            self.action_size = action_size;
            self.logger = logger;
            
            self.cpuct = cpuct;
            
            self.MCTS_simulations = mcts_simulations;
            self.model = model;
            
            self.mcts = [];
            
            self.train_overall_loss = [];
            self.train_value_loss = [];
            self.train_policy_loss = [];
            self.val_overall_loss = [];
            self.val_value_loss = [];
            self.val_policy_loss = [];
            
        end
        
        function [action, pi, value, NN_value] = act(self, state, tau)
            
            if isempty(self.mcts) || ~isfield(self.mcts.tree,state.id)
                self.buildMCTS(state);
            else
                self.changeRootMCTS(state);
            end
            
            for sim = 1:self.MCTS_simulations
                self.logger.trace('simulate',sprintf('** SIMULATION %d **',sim));
                self.simulate();
            end
            
            % Get action values
            [pi, values] = self.getAV(1);
            
            % Pick the action
            [action, value] = self.chooseAction(pi, values, tau);
            
            [nextState, ~, ~, ~] = state.takeAction(action);
            
            NN_value = -self.get_preds(nextState);
            
            self.logger.trace('act',sprintf('ACTION VALUES...%s\n',pi))
            self.logger.trace('act',sprintf('CHOSEN ACTION...%s',action))
            self.logger.trace('act',sprintf('MCTS PERCEIVED VALUE...%s',value))
            self.logger.trace('act',sprintf('NN PERCEIVED VALUE...%s',NN_value))
            
        end
        
        function simulate(self)
            
            self.logger.trace('simulate',sprintf('ROOT NODE...%s', self.mcts.root.state.id));
            self.mcts.root.state.render_trace('simulate',self.logger);
            self.logger.trace('simulate',sprintf('CURRENT PLAYER...%d', self.mcts.root.state.playerTurn));
            
            % Move to leaf
            [leaf, winner, value, done, breadcrumbs] = self.mcts.moveToLeaf();
            leaf.state.render_trace('simulate',self.logger)
            
            % Evaluate leaf
            value = self.evaluateLeaf(leaf, winner, value, done);
            
            % Backfill
            self.mcts.backFill(leaf, value, breadcrumbs);
            
        end
        
        function value = evaluateLeaf(self, leaf, winner, value, done)
            
            self.logger.trace('evaluateLeaf','** EVALUATE START **');
            
            if done==0
                
                [value, probs, allowedActions] = self.get_preds(leaf.state);
                self.logger.trace('evaluateLeaf',sprintf('PREDICTED VALUE FOR %d: %.6f', leaf.playerTurn, value));
                
                probs = probs(allowedActions);
                
                for k = 1:length(allowedActions)   
                    [newState, ~, ~, ~] = leaf.state.takeAction(allowedActions(k));
                    if ~isfield(self.mcts.tree,newState.id)
                        node = Node(newState);
                        self.mcts.addNode(node);
                        self.logger.trace('evaluateLeaf',sprintf('added node...%s...p = %.6f',node.id,probs(k)));
                    else
                        node = self.mcts.tree.(newState.id);
                        self.logger.trace('evaluateLeaf',sprintf('existing node...%s...p = %.6f',node.id,probs(k)));
                    end
                    
                    edge = Edge(leaf, node, probs(k), allowedActions(k));
                    self.mcts.tree.(leaf.id).edges = [self.mcts.tree.(leaf.id).edges edge];
                    
                end
                
            else
                self.logger.trace('evaluateLeaf',sprintf('END OF GAME. WINNER = %d', winner));
                self.logger.trace('evaluateLeaf',sprintf('GAME VALUE FOR %d: %.6f', leaf.state.nextTurn, value));                
            end
            
        end
        
        
        function [pi, values] = getAV(self, e)
            
            edges = self.mcts.tree.(self.mcts.root.id).edges;
            pi = zeros(1, self.action_size);
            values = zeros(1, self.action_size);
            
            for k = 1:length(edges)
                pi(edges(k).action) = (edges(k).stats_N)^(1/e);
                values(edges(k).action) = edges(k).stats_Q;
            end
            
            pi = pi/sum(pi);
            
        end
            
        function [action, value] = chooseAction(self, pi, values, tau)
            
            if ~tau
                [~,action] = max(pi);
            else
                actions = 1:length(pi);
                action = actions(boolean(mnrnd(1, pi)));
            end
            
            value = values(action);            
            
        end
        
        function [value, probs, allowedActions] = get_preds(self, state)
            
%             allowedActions = state.allowedActions;
%             value = (rand() - .5) * 2;
%             odds = zeros(1,42);
%             odds(1,allowedActions) = rand(size(allowedActions));
%             probs = odds ./ sum(odds);
            
            inputToModel = self.model.convertToModelInput(state);

            value = self.model.NNValue.predict(inputToModel);
            logits = self.model.NNProb.predict(inputToModel);
            allowedActions = state.allowedActions;
            
            mask = true(size(logits));
            mask(allowedActions) = false;
            logits(mask) = -100;
            logits = min(logits,10);
            
            odds = exp(logits);
            probs = odds / sum(odds);

        end
        
        function train(self, memory, batch_size)
            
            self.logger.trace('train','**** RETRAINING MODEL ****');
            
            batch_size = min(batch_size, memory.iLT);
            
            sample_states = [];
            sample_targets = struct;
            sample_targets.Value = zeros(batch_size, 1);
            sample_targets.Prob = zeros(batch_size, self.model.output_dim-1);
            
            idx = randperm(memory.iLT,batch_size);
            m = memory.ltmemory(idx);
            
            for k = 1:length(m)
                sample_states = cat(4, sample_states, self.model.convertToModelInput(m(k).state));
                sample_targets.Value(k,:) = m(k).value;
                sample_targets.Prob(k,:) = m(k).AV;
            end
            
            [NNValue, NNProb, trainInfoValue, trainInfoProb] = self.model.train(sample_states, sample_targets);
            
            self.model.NNValue = NNValue;
            self.model.NNProb = NNProb;
            
            self.logger.trace('train','Training Loss for Value:');
            self.logger.trace('train',sprintf(' %.3f ',trainInfoValue.TrainingLoss));
            
            self.logger.trace('train','Training Loss for Prob:');
            self.logger.trace('train',sprintf(' %.3f ',trainInfoProb.TrainingLoss));
            
            
        end

        function buildMCTS(self, state)
            self.logger.trace('act',sprintf('**** BUILDING NEW MCTS TREE FOR AGENT %s ****',self.name));
            root = Node(state);
            self.mcts = MCTS(root, self.cpuct, self.logger, self.Epsilon, self.Alpha);
        end

        function changeRootMCTS(self, state)
            self.logger.trace('act',sprintf('**** CHANGING ROOT OF MCTS TREE TO %s FOR AGENT %s ****', state.id, self.name));
            self.mcts.root = self.mcts.tree.(state.id);
        end
        
    end
    
    
end

