%% Init variables

mcts_simulations = 200;
cpuct = 1;

batch_size = 1024;

turns_until_tau0 = 10;
EPISODES = 50;
TOURNAMENT_EPISODES = 20;

SCORING_THRESHOLD = 1.3;

runUntil_model_version = 50;

loggerFile = 'logger_Connect4_01.log';