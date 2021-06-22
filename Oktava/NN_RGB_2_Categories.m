
%===============================DeSCRIPTion================================
%
%   This script trains a network to categorize pixels into two categories:
%   "color" and "other".
%   The network has only one output neuron but two categories.
%   If the output is bigger or equal 0.5 the pixel belongs to the 
%   category "color". 

%   If the output is lower the pixel belongs to the category "other".
%   By default all white pixels in the label picture belong to the
%   category "color".
%   In the second channel of the label picture they have the value 255.
%   All other pixel belong to the category "other".
%
%   For the training process we have two images.
%   One with which you want to train and a second image that contains the
%   labels (our expected output).
%   Each pixel with its corresponding label is a sample for training.
%   This means if you train your network with a picture that has x * y
%   pixels - our dataset for training has x times y samples.
%
%
%==========================================================================

clear; clc; close all;

fprintf('Starting Script \n')

%=============== Constants Definition =================

epochs = 1600;   %Number of epochs
alpha = 0.00001; %Learning rate for training

width=1600; %Width of the picture 
height=900; %Heigth of the picture 

color1=[255;255;255];   %Output color for the category "color"
color0=[0;0;0];         %Output color for the category "other"

%always use the same random numbers for reproducibility
rand ("seed", 123456);

%=============== Prepare Input Data =================
fprintf('Reading and Preparing Training Data \n')


%Image we want to use for training
inputPicture = imread('tablaRumenka.png');

%Image with the labels corresponding to our inputPicture
labelPicture = imread('tablaRumenka_train.png');

%our loaded pictures before training
imshow(inputPicture);
figure();
imshow(labelPicture);


%Preparing the data for the training
inputPicture = cast(inputPicture,'double'); %Needs to be casted from uint to double

%Creating a matrix with the dimensions of the picture for the later label vector

%Instead of 0 fill the matrix with 0.01 because the sigmoid function will
%never reach 0
labels = zeros(height,width) + 0.01;



%In the second channel of the labelPicture all pixel with a value of 255
%(white pixel in the picture) belongs to the category "color"
%Where the value is 255 insert 0.99 in the labels matrix

%0.99 -> because the sigmoid function never reaches 1
%If you read a black and white picture in octave the white pixel have a value of 1
labels(labelPicture(:,:,2)>0)=0.99;

%Reshape the pictures to tables for the training process
labels = reshape(labels,[],1);   % One column (because of one output neuron)
inputPicture = reshape(inputPicture,[],3); %Three columns (because three neurons in the input layer)


%Print out debug info
numCategoryOne=(sum(labels==0.99)*100)/(width*height);
fprintf('Statistics:\n');
fprintf(' - Category 1: %2.2f %%\n',numCategoryOne);
fprintf(' - Background: %2.2f %%\n',100-numCategoryOne);

% Scale the input from [0;255] to [0;1] because of the sigmoid function
% Only for input values between [-4;4] the sigmoid function shows significant
% differences in the output.
inputPicture = inputPicture/255;



%=============== Generate Network =================
fprintf('Generate Network \n')

%Define the network structure as a vector
%[3 3 1] means input layer with 3 neurons, one hidden layer has 3 neurons
% and that output layer has 1 neuron
% 
%i.e. [3 5 6 2] means :
%   - Input layer has three neurons
%   - Two hidden layers: one with 5 and second with 6 neurons and the second six neurons
%   - The output layer has 2 neurons

networkStructure = [3 3 1];

%Create the Network
network = generateNetwork(networkStructure);

%=============== Training =================
fprintf('Start Training \n')

%Train the network.
%The small alpha is required to get a working results.
%Bigger alpha works only with fewer pixels per pictures
[trainedNetwork,costLog,accuracyLog]=trainNetwork(inputPicture,labels,network,'epochs',epochs, 'alpha',alpha);

%Accuracy log does not work if the number of output neurons != number of categories
%figure();
%plot(accuracyLog);

%Plot the cost log from training
figCostLog=figure();
plot(costLog);
ylabel('loss');
xlabel('epochs');

fprintf('Training Done\n')

%=============== Prediction =================
fprintf('Using Trained Network for Test Prediction\n')

%Use the trained network on the inputPicture to see results
predOutput = networkPrediction(inputPicture, trainedNetwork);


%Round the values to get a 0 or 1
predOutput = round(predOutput');


%reshape predOutput to the dimensions of a picture
predOutput = reshape(predOutput,height,width);


%Create empty picture for the final result
predictionPicture = zeros(height,width,3);


%Add colors to the prediction imgae based on the results of the network
for i=1:height
    for j=1:width
        if(predOutput(i,j)==1)
            predictionPicture(i,j,:)=color1;
        else
            predictionPicture(i,j,:)=color0;
        end
    end
end

%Cast back from double to unit
predictionPicture = cast(predictionPicture,'uint8');

figure();
imshow(predictionPicture);



%=============== Generate Results =================
fprintf('Results \n')

%Remove the last line from the first matrix because that would be weights for
%connections that go to the bias in the hidden layer.

nnParams = trainedNetwork;
nnParams{1} = nnParams{1}(1:end-1,:); %Ignore Last Column

fprintf('\nWeight Matrix from the Input to the Hidden Layer\n')
disp(nnParams{1});
fprintf('Weight Matrix from the Hidden to the Output Layer\n')
disp(nnParams{2});

save('NN_RGB_2_Categories_config.mat','trainedNetwork','networkStructure','nnParams');

%saveas(figCostLog,'NN_RGB_2_Categories_Cost_Log.png','png');
%imwrite(predictionPicture,'NN_RGB_2_Categories_Predicted_Picture','png');

fprintf('\nFinished Script\n')