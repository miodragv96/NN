%CALCULATEACCURACY 
%Calculates matching error between the output and the labelss

%   a = CALCULATEACCURACY(B,C) Calculates the accordance between B and C
%   and returns it as percentage

function[accuracy] =calculateAccuracy(calculatedResult, reference)

m=size(reference,2);


    if(size(reference,1)==1)
                correct = reference - round(calculatedResult); %When the output is the same a zero is at the column
                correct = sum(correct == 0); %count zeros
                accuracy=correct/m; %Calculate the accuracy in %
            else
                %Calculate the accuracy of the trainings set
                [~ , posOutput] = max(reference); %get the position of correct output
                [~ , posPrediction] = max(calculatedResult); %get the position of the prediction
                correct = posOutput - posPrediction; %When the output is the same a zero is at the column
                correct = sum(correct == 0); %count zeros
                accuracy=correct/m; %Calculate the accuracy in %
    end
        
end