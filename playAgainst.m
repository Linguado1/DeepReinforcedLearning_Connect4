env = Game();

versionPlayer1 = -1; %-1 for human player
versionPlayer2 = 10; %-1 for human player

nGames = 10;

logger = log4m.getLogger();
logger.setLogLevel(logger.OFF);
logger.setCommandWindowLevel(logger.DEBUG);

[ scores, ~, sp_scores ] = playMatchesBetweenVersions( env, versionPlayer1, versionPlayer2, nGames, logger, 0 );

logger.info('tournament',sprintf('Player 1: %d', scores.player1))
logger.info('tournament',sprintf('Drawn: %d', scores.drawn))
logger.info('tournament',sprintf('Player 2: %d', scores.player2))