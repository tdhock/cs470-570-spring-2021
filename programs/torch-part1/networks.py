import torch
class FullyConnected(torch.nn.Module):
    def __init__(self, input_size=784, h1=300, h2=100, output_size=10):
        super().__init__() 
        self.layer_1 = torch.nn.Linear(input_size, h1)
        self.layer_2 = torch.nn.Linear(h1, h2)
        self.layer_3 = torch.nn.Linear(h2, output_size)
    def forward(self, x):
        x = torch.flatten(x, start_dim=1)
        x = F.relu(self.layer_1(x))
        x = F.relu(self.layer_2(x))
        x = self.layer_3(x)
        return x
    
class LeNet(torch.nn.Module):
    def __init__(self):
      super().__init__()
      self.conv1 = torch.nn.Conv2d(in_channels=1, out_channels= 6, kernel_size=5)
      self.conv2 = torch.nn.Conv2d(6, 16, 5)
      self.fc1 = torch.nn.Linear(4*4*16, 120)
      self.fc2 = torch.nn.Linear(120, 84)
      self.output = torch.nn.Linear(84, 10)
    def forward(self, x):
      x = F.relu(self.conv1(x))
      # use x.shape to check the current size
      # print (x.shape)
      x = F.max_pool2d(x, 2, 2)
      x = F.relu(self.conv2(x))
      x = F.max_pool2d(x, 2, 2)
      x = x.view(-1, 4*4*16)
      x = F.relu(self.fc1(x))
      x = F.relu(self.fc2(x))
      x = self.output(x)
      return x

  
