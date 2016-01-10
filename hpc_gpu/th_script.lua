require 'nn'
require 'cunn'
require 'cutorch'

-- sample demo taken from https://github.com/soumith/cvpr2015/blob/master/Deep%20Learning%20with%20Torch.ipynb 

net = nn.Sequential()
net:add(nn.SpatialConvolution(1, 6, 5, 5)) -- 1 input image channel, 6 output channels, 5x5 convolution kernel
net:add(nn.SpatialMaxPooling(2,2,2,2))     -- A max-pooling operation that looks at 2x2 windows and finds the max.
net:add(nn.SpatialConvolution(6, 16, 5, 5))
net:add(nn.SpatialMaxPooling(2,2,2,2))
net:add(nn.View(16*5*5))                    -- reshapes from a 3D tensor of 16x5x5 into 1D tensor of 16*5*5
net:add(nn.Linear(16*5*5, 120))             -- fully connected layer (matrix multiplication between input and weights)
net:add(nn.Linear(120, 84))
net:add(nn.Linear(84, 10))                   -- 10 is the number of outputs of the network (in this case, 10 digits)
net:add(nn.LogSoftMax())                     -- converts the output to a log-probability. Useful for classification problems
net = net:cuda()

print('Lenet5\n' .. net:__tostring())

input = torch.rand(1,32,32)
input = input:cuda()
output = net:forward(input)
print(output)

net:zeroGradParameters() -- zero the internal gradient buffers of the network (will come to this later)
gradient = torch.rand(10)
gradient = gradient:cuda()
gradInput = net:backward(input, gradient)
print(#gradInput)

