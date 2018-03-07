classdef Model < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        input_dim
        output_dim
        hidden_layers
        num_layers
        layersValue
        layersProb
        opts
        NNValue
        NNProb
    end
    
    methods
        
        function self = Model(learning_rate, reg_const, epochs, batch_size, momentum, verbose, input_dim, output_dim, hidden_layers)

            self.input_dim = input_dim;
            self.output_dim = output_dim;
            self.hidden_layers = hidden_layers;
            self.num_layers = length(hidden_layers);
            [self.layersValue,self.layersProb]= self.build_layers();
            self.opts = trainingOptions('sgdm',...
                'LearnRateDropFactor',learning_rate,...
                'L2Regularization', reg_const,...
                'MaxEpochs', epochs,...
                'MiniBatchSize', batch_size,...
                'Momentum', momentum,...
                'Verbose', verbose);
        end
        
        function [layersValue, layersProb]  = build_layers(self)
            
            baseLayers = imageInputLayer([self.input_dim(1) self.input_dim(2) 3]);
            
            for k = 1:self.num_layers
                baseLayers = [baseLayers convolution2dLayer(...
                    self.hidden_layers(k).kernel_size,...
                    self.hidden_layers(k).filters,...
                    'Padding', 'same')];
                baseLayers = [baseLayers batchNormalizationLayer()];
                baseLayers = [baseLayers leakyReluLayer];
            end
            
            baseLayers = [baseLayers maxPooling2dLayer(1,'Stride',1)];
            
            layersValue = [baseLayers fullyConnectedLayer(32)];
            layersValue = [layersValue fullyConnectedLayer(1)];
            layersValue = [layersValue regressionLayer()];
            
            layersProb = [baseLayers fullyConnectedLayer(210)];
            layersProb = [layersProb fullyConnectedLayer((self.input_dim(1) * self.input_dim(2)))];
            layersProb = [layersProb regressionLayer()];
            
        end
        
        function [NNValue, NNProb, trainInfoValue, trainInfoProb] = train(self, input, output)
            
            [NNValue, trainInfoValue] = trainNetwork(input, output.Value, self.layersValue, self.opts);
            [NNProb, trainInfoProb] = trainNetwork(input, output.Prob, self.layersProb, self.opts);
            
        end
        
        function inputToModel = convertToModelInput(self, state)
            
            inputToModel_1 = reshape(state.binary(1:(self.input_dim(1) * self.input_dim(2))), self.input_dim(2), self.input_dim(1))';
            inputToModel_2 = reshape(state.binary((1+(self.input_dim(1) * self.input_dim(2))):end), self.input_dim(2), self.input_dim(1))';
            
%             inputToModel_3 = ones(1,(self.input_dim(1) * self.input_dim(2)));
%             inputToModel_3(state.binary(1:(self.input_dim(1) * self.input_dim(2))) == 1) = 0;
%             inputToModel_3(state.binary((1+(self.input_dim(1) * self.input_dim(2))):end) == 1) = 0;
%             inputToModel_3 = reshape(inputToModel_3, self.input_dim(2), self.input_dim(1))';            
            
            inputToModel_3 = zeros(1,(self.input_dim(1) * self.input_dim(2)));
            inputToModel_3(state.allowedActions) = 1;
            inputToModel_3 = reshape(inputToModel_3, self.input_dim(2), self.input_dim(1))';

            inputToModel = zeros(self.input_dim(1), self.input_dim(2), 3);
            inputToModel(:,:,1) = inputToModel_1;
            inputToModel(:,:,2) = inputToModel_2;
            inputToModel(:,:,3) = inputToModel_3;
            
        end
        
    end
    
end

