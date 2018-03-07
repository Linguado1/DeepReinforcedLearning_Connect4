function [ scores, memory, sp_scores ] = playMatches( env, player1, player2, EPISODES, logger, turns_until_tau0, varargin )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

    if isempty(varargin)
        memory=[];
        goes_first=0;
    elseif length(varargin) == 1
        memory=varargin{1};
        goes_first=0;
    elseif length(varargin) == 2
        memory=varargin{1};
        goes_first=varargin{2};
    elseif length(varargin) > 2
        logger.error('playMatches','Too many arguments.');
    end
    
    if strcmp(player1.name, player2.name)
        P1_name = [player1.name '_1'];
        P2_name = [player2.name '_2'];
    else
        P1_name = player1.name;
        P2_name = player2.name;
    end
    
    scores = struct(P1_name, 0, 'drawn', 0, P2_name, 0);
    sp_scores = struct('sp', 0, 'drawn', 0, 'nsp', 0);
    
    for e = 1:EPISODES
        
        logger.info('playMatches',sprintf('**** EPISODE %d OF %d ****', e, EPISODES));
        
        state = env.reset();
        
        done = 0;
        turn = 0;
        
        if goes_first == 0
            player1Starts = (randi(2)-1)*2-1;
        else
            player1Starts = goes_first;
        end
        
        if player1Starts == 1
            players(1) = struct('agent',player1,'name',P1_name);
            players(2) = struct('agent',player2,'name',P2_name);
            logger.debug('playMatches',sprintf('%s plays as X',P1_name));
        else
            players(2) = struct('agent',player1,'name',P1_name);
            players(1) = struct('agent',player2,'name',P2_name);
            logger.debug('playMatches',sprintf('%s plays as X',P2_name));
        end
        
        env.gameState.render_debug('playMatches',logger);
        
        while done == 0
            turn = turn+1;
            
            if turn < turns_until_tau0
                [action, pi, MCTS_value, NN_value] = players(state.playerTurn).agent.act(state, true);
            else
                [action, pi, MCTS_value, NN_value] = players(state.playerTurn).agent.act(state, false);
            end
            
            logger.trace('playMatches',sprintf('action: %d',action));
            render_pi(env.grid_shape, state, pi, MCTS_value, NN_value, logger);
            
            % Do the action
            % the value of the newState from the POV of the new playerTurn i.e. -1 if the previous player played a winning move
            [state, winner, done] = env.step(action);
            
            if ~isempty(memory)
                memory.commit_stmemory(env.Identities(state, pi));
            end
            
            env.gameState.render_debug('playMatches',logger)
            
            if done == 1
                
                if ~isempty(memory)
                    % If the game is finished, assign the values correctly to the game moves
                    for m = 1:memory.iST
                        if memory.stmemory(m).playerTurn == state.nextTurn
                            memory.stmemory(m).value = 1;
                        elseif memory.stmemory(m).playerTurn == state.playerTurn
                            memory.stmemory(m).value = -1;
                        else
                            memory.stmemory(m).value = 0;
                        end
                    end
                    
                    memory.commit_ltmemory();
                    logger.trace('playMatches',sprintf('Memory size = %d',memory.iLT))
                end
                
                if winner ~= 0
                    logger.debug('playMatches',sprintf('%s WINS!', players(winner).name));
                    scores.(players(winner).name) = scores.(players(winner).name) + 1;
                    if winner == 1
                        sp_scores.sp = sp_scores.sp + 1;
                    else
                        sp_scores.nsp = sp_scores.nsp + 1;
                    end                    
                else
                    logger.debug('playMatches','Draw...');
                    scores.drawn = scores.drawn + 1;
                    sp_scores.drawn = sp_scores.drawn + 1;
                end
                
            end
        end
        
        
    end

end

function render_pi(grid_shape, state, pi, MCTS_value, NN_value, logger)

    for r = 1:grid_shape(1)
        s = [];
        for c = 1:grid_shape(2)
            x = pi((r-1)*grid_shape(2) + c);
            if x == 0
                s = [s '---- , '];
            else
                s = [s sprintf('%.2f',x) ' , '];
            end
        end
        s = [s sprintf('\b\b\b')];
        logger.trace('playMatches',s);
    end
    logger.trace('playMatches',sprintf('MCTS perceived value for %s: %.2f', state.(sprintf('piecesPlayer%d',state.playerTurn)), MCTS_value))
    logger.trace('playMatches',sprintf('NN perceived value for %s: %.2f', state.(sprintf('piecesPlayer%d',state.playerTurn)), NN_value))
    logger.trace('playMatches','====================');

end

