classdef User
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        state_size
        action_size
        logger
    end
    
    methods
        
        function self = User(name, state_size, action_size, logger)
            self.name = name;
            self.state_size = state_size;
            self.action_size = action_size;
            self.logger = logger;
        end
        
        function [action, pi, value, NN_value] = act(self, state, ~)
            
            fprintf('Allowed actions:\n[')
            allowed = state.allowedActions;
            
            for k = 1:length(allowed)
                fprintf('%d,',allowed(k));
            end
            
            fprintf('\b]\n')
            
            actionOK = false;
            while ~actionOK
                action = input('Enter your chosen action: ');
                if sum(allowed == action) == 0
                    fprintf('Invalid action\n');
                else
                    actionOK = true;
                end
            end
            
            pi = zeros(1,self.action_size);
            pi(action) = 1;
            value = [];
            NN_value = [];
            
            self.logger.debug('act',sprintf('Action taken...%d',action));
        end
        
    end
    
end

