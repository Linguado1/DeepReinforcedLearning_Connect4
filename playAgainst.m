env = Game();

versionPlayer1 = -1; %-1 for human player
versionPlayer2 = -1; %-1 for human player

nGames = 1;

logger = log4m.getLogger();
logger.setLogLevel(logger.OFF);
logger.setCommandWindowLevel(logger.DEBUG);

[ scores, ~, sp_scores ] = playMatchesBetweenVersions( env, versionPlayer1, versionPlayer2, nGames, logger, 0 );

logger.info('tournament',sprintf('Player 1: %d\nDrawn: %d\nPlayer 2: %d', scores.player1, scores.drawn, scores.player2))