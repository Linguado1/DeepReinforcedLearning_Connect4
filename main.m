

env = Game();

Init_variables

logger = log4m.getLogger(loggerFile);
logger.setLogLevel(logger.OFF);
logger.setCommandWindowLevel(logger.INFO);

configFile = dir('config.mat');

if isempty(configFile)
    logger.info('config','Config file not found. Performing first configuration...');
    makeConfig
else
    load('config.mat');
end

load([pwd '\Model\' sprintf('Model_Connect4_v%.2d.mat',model_version)]);
load([pwd '\Memory\' sprintf('Memory_Connect4_v%.2d.mat',memory_version)]);

best_player = Agent('best_player', env.state_size, env.action_size, logger, mcts_simulations, cpuct, model);
current_player = Agent('current_player', env.state_size, env.action_size, logger, mcts_simulations, cpuct, blank_model);

iteration = 0;
iterationWithoutUpgrade = 0;

while model_version < runUntil_model_version
    
    iteration = iteration+1;
    iterationWithoutUpgrade = iterationWithoutUpgrade + 1;
    
    logger.info('iteration',sprintf('**** Iteration %d ****', iteration))
    [ ~, memory, ~ ] = playMatches(env, best_player, best_player, EPISODES, logger, turns_until_tau0, memory);
    
    if memory.iLT == memory.Memory_Size
        
        current_player.train(memory, batch_size);
        
        tryAgain = false;
        
        if mod(iteration,5) == 0
            memory_version = memory_version+1;
            save([pwd '\Memory\' sprintf('Memory_Connect4_v%.2d.mat',memory_version)], 'memory')
            save('config.mat','model_version','memory_version')
        end
        
        if iterationWithoutUpgrade >= 5
            tryAgain = true;
        end
        
        noUpgrade = true;
        tournament = 0;
        while noUpgrade
            
            tournament = tournament + 1;
            logger.info('tournament',sprintf('**** TOURNAMENT %d ****',tournament))
            [ scores, ~, sp_scores ] = playMatches(env, best_player, current_player, TOURNAMENT_EPISODES, logger, 0);
            logger.info('tournament',sprintf('Best player: %d\nDrawn: %d\nCurrent player: %d', scores.best_player, scores.drawn, scores.current_player))

            if scores.current_player > scores.best_player * SCORING_THRESHOLD
                model_version = model_version + 1;
                model = current_player.model;
                save([pwd '\Model\' sprintf('Model_Connect4_v%.2d.mat',model_version)], 'model', 'blank_model')
                save('config.mat','model_version','memory_version')
                best_player.model = current_player.model;
                logger.info('tournament',sprintf('New best version = %d',model_version))
                tryAgain = false;
                iterationWithoutUpgrade = 0;
            end
            
            if ~tryAgain
                noUpgrade = false;
            end
        
        end
        
    else
        logger.info('iteration',sprintf('Memory size = %d', memory.iLT))
    end
    
    
end