% SIGMOIDA - Compute sigmoid function.
%   J = SIGMOID(z) computes the sigmoid of z.
%  

function g = sigmoid(z)
g = 1.0 ./ (1.0 + exp(-z));
end
