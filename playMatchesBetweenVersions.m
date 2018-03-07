function [ scores, memory, sp_scores ] = playMatchesBetweenVersions( env, player1version, player2version, EPISODES, logger, turns_until_tau0, varargin )
%UNTITLED6 Summary of this function goes here
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
    
    
    if player1version == -1
        player1 = User('player1', env.state_size, env.action_size, logger);
    else
        load([pwd '\Model\' sprintf('Model_Connect4_v%.2d.mat',player1version)], 'model')
        player1 = Agent('player1', env.state_size, env.action_size, logger, 200, 1, model);
    end
    
    
    if player2version == -1
        player2 = User('player2', env.state_size, env.action_size, logger);
    else
        load([pwd '\Model\' sprintf('Model_Connect4_v%.2d.mat',player2version)], 'model')
        player2 = Agent('player2', env.state_size, env.action_size, logger, 200, 1, model);
    end

    [scores, memory, sp_scores] = playMatches(env, player1, player2, EPISODES, logger, turns_until_tau0, memory, goes_first);

end

