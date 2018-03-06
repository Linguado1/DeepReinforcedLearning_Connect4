%% Init Memory
memory_version = 1;

memory_size = 30000;
memory = Memory(memory_size);

save([pwd '\Memory\' sprintf('Memory_Connect4_v%.2d.mat',memory_version)], 'memory')

%% Init Neural Network
model_version = 1;

nLayers = 4;
nFilters = 25;
filterSize = [3 3];
HIDDEN_CNN_LAYERS = repmat(struct('filters', nFilters, 'kernel_size', filterSize), nLayers, 1);
REG_CONST = 0.0001;
EPOCHS = 1;
LEARNING_RATE = 0.1;
MOMENTUM = 0.9;
verbose = 1;
BATCH_SIZE = 32;

model = Model(LEARNING_RATE, REG_CONST, EPOCHS, BATCH_SIZE, MOMENTUM, verbose, env.grid_shape, env.action_size+1, HIDDEN_CNN_LAYERS);

sample_state = cat(4,model.convertToModelInput(memory.ltmemory(1).state),model.convertToModelInput(memory.ltmemory(2).state));
sample_target.Value = [memory.ltmemory(1).value;memory.ltmemory(2).value];
sample_target.Prob = [memory.ltmemory(1).AV;memory.ltmemory(2).AV];

[NNValue, NNProb, trainInfoValue, trainInfoProb] = model.train(sample_state, sample_target);

model.NNValue = NNValue;
model.NNProb = NNProb;

blank_model = model;

save([pwd '\Model\' sprintf('Model_Connect4_v%.2d.mat',model_version)], 'model', 'blank_model')

%% Save config variales

save('config.mat','model_version','memory_version')