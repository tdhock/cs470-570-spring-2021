import os
import numpy
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from urllib.request import urlretrieve

def to_torch(s):
    a = s.to_numpy()
    return torch.from_numpy(a.reshape(a.shape[0],1).astype(numpy.float32))    

class Net(nn.Module):

    def __init__(self):
        super(Net, self).__init__()
        self.hidden = nn.Linear(1, 50)
        self.out = nn.Linear(50, 1)

    def forward(self, x):
        x = F.relu(self.hidden(x))
        x = F.relu(self.out(x))
        return x

criterion = nn.MSELoss()
n_folds = 5
data_dict = {}
for pattern in "sin", "linear", "quadratic":
    f = "data_%s.csv" % pattern
    if not os.path.exists(f):
        u = "https://raw.githubusercontent.com/tdhock/2020-yiqi-summer-school/master/" + f
        urlretrieve(u, f)
    df = pandas.read_csv(f)
    nrow = df.shape[0]
    numpy.random.seed(123)
    df["fold"] = numpy.repeat(
        numpy.arange(n_folds),
        nrow/n_folds)
    numpy.random.shuffle(df["fold"])
    df["fold"].value_counts()
    valid_fold = 0
    by_set = df.set_index(numpy.where(df["fold"] == valid_fold, "valid", "train"))
    tensors = {}
    for s in "valid", "train":
        set_data = {}
        for xy in "x", "y":
            set_data[xy] = to_torch(by_set.loc[s, xy])
        tensors[s] = set_data
    net = Net()
    optimizer = optim.SGD(net.parameters(), lr=0.02)

    for epoch in range(100):
        loss_dict = {"epoch":epoch, "pattern":pattern}
        for s in "train", "valid":
            pred = net(tensors[s]["x"])
            loss = criterion(pred, tensors[s]["y"])
            loss_dict[s] = loss
            if s is "train": 
                optimizer.zero_grad()   # zero the gradient buffers
                loss.backward()
                optimizer.step()    # Does the update
        print("pattern=%(pattern)s epoch=%(epoch)d train=%(train)f valid=%(valid)f" % loss_dict)
