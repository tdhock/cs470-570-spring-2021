import os
import numpy
import torch
import pandas
from torch.utils.tensorboard import SummaryWriter
from urllib.request import urlretrieve

writer_dict = {}
for s in "subtrain", 'validation':
    writer_dict[s] = SummaryWriter("runs/"+s)

def to_torch(s):
    a = s.to_numpy()
    return torch.from_numpy(a.reshape(a.shape[0],1).astype(numpy.float32))    

class Net(torch.nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        n_hidden = 20
        self.act = torch.nn.Sigmoid()
        self.hidden = torch.nn.Linear(1, n_hidden)
        self.out = torch.nn.Linear(n_hidden, 1)
    def forward(self, x):
        x = self.act(self.hidden(x))
        x = self.out(x)
        return x

criterion = torch.nn.MSELoss()
n_folds = 5
data_dict = {}
for pattern in "sin", "linear", "quadratic":
    # first download data set
    f = "data_%s.csv" % pattern
    if not os.path.exists(f):
        u = "https://raw.githubusercontent.com/tdhock/2020-yiqi-summer-school/master/" + f
        urlretrieve(u, f)
    df = pandas.read_csv(f)
    nrow = df.shape[0]
    # randomly assign fold IDs
    numpy.random.seed(123)
    fold_vec = numpy.repeat(
        numpy.arange(n_folds),
        nrow/n_folds)
    numpy.random.shuffle(fold_vec)
    # use fold=0 as validation set
    validation_fold = 0
    by_set = df.set_index(numpy.where(fold_vec == validation_fold, "validation", "subtrain"))
    tensors = {}
    for s in "validation", "subtrain":
        set_data = {}
        for xy in "x", "y":
            set_data[xy] = to_torch(by_set.loc[s, xy])
        tensors[s] = set_data
    net = Net()
    # optimizer = torch.optim.SGD(net.parameters(), lr=0.4)
    # max_epochs = 2000
    # todo L-BFGS https://pytorch.org/docs/stable/optim.html
    optimizer = torch.optim.LBFGS(net.parameters(), lr=0.03)
    max_epochs = 100
    for epoch in range(max_epochs):
        loss_dict = {"epoch":epoch, "pattern":pattern}
        for s in "subtrain", "validation":
            pred = net(tensors[s]["x"])
            loss = criterion(pred, tensors[s]["y"])
            loss_dict[s] = loss
            writer_dict[s].add_scalar(pattern+'/Loss', loss, epoch)
            # TODO try add_image https://pytorch.org/tutorials/intermediate/tensorboard_tutorial.html#tracking-model-training-with-tensorboard
            if s is "subtrain":
                def closure():
                    optimizer.zero_grad()
                    pred = net(tensors[s]["x"])
                    loss = criterion(pred, tensors[s]["y"])
                    loss.backward()
                    return loss                
                optimizer.step(closure)    # Does the update
        print("pattern=%(pattern)s epoch=%(epoch)d subtrain=%(subtrain)f validation=%(validation)f" % loss_dict)
