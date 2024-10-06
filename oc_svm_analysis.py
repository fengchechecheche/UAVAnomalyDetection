import numpy as np
from matplotlib import pyplot as plt
from sklearn import svm
import pandas as pd
import itertools
from sklearn.metrics import roc_curve, auc, roc_auc_score, log_loss, accuracy_score, confusion_matrix
from sklearn.decomposition import KernelPCA


# Import X and Y data
x_data = pd.read_csv("X_data.csv")
y_data = np.loadtxt(open("Y_data.csv", "rb"), delimiter=",")
y_labels = pd.read_csv("Y_labels.csv")
# Show first 5 rows of the data and print size
print(x_data.shape)
x_data.head()

# First we will run OC-SVM in a unsupervised environment (inliers and outliers together no labels)
# Fit model
outliers_fraction = 0.80
svm_obj = svm.OneClassSVM(
    kernel='rbf',
    nu=outliers_fraction,
    gamma=10)

# 1: inliers, -1: Outliers
# 10 Samples are Non-failure
# 37 are Failure
x_np = x_data.to_numpy()
y_pred = svm_obj.fit(x_np).predict(x_np)

n_error_inliers = y_pred[y_pred == 1].size
n_error_outliers = y_pred[y_pred == -1].size
print(n_error_inliers)
print(n_error_outliers)
# 47 Total Flights, OC-SVM Detected 9 as Inlier and 38 as Inlier.
# 32 being failure and 15 being normal


# Helper functions to get error types and performance statistics
def get_accuracy(y_truth, y_est, sample_size):
    """
        Function to compute accuracy on how well the classification algorithm works

        Returns accuracy
    """
    acc = 0
    for i in range(len(y_truth)):
        acc = acc + (y_truth[i] == y_est[i])
    acc = (1/sample_size) * acc

    return acc


acc = get_accuracy(y_data, y_pred, y_data.size)
print(acc*100)


# Get Confusion matrix plot
def plot_cm(ax, y_true, y_pred, classes, title, th=0.5, cmap=plt.cm.Blues):
    y_pred_labels = (y_pred > th).astype(int)

    cm = confusion_matrix(y_true, y_pred_labels)

    im = ax.imshow(cm, interpolation='nearest', cmap=cmap)
    ax.set_title(title)

    tick_marks = np.arange(len(classes))
    ax.set_xticks(tick_marks)
    ax.set_yticks(tick_marks)
    ax.set_xticklabels(classes)
    ax.set_yticklabels(classes)

    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        ax.text(j, i, cm[i, j],
                horizontalalignment="center",
                color="white" if cm[i, j] > thresh else "black")
    ax.set_ylabel('True label')
    ax.set_xlabel('Predicted label')


# Remap the classes
# 0: Inlier, 1: Outlier
y_data_new = np.where(np.array(y_data) == -1, 0, 1)
y_pred_new = np.where(np.array(y_pred) == -1, 0, 1)
fig1, ax1 = plt.subplots()
plot_cm(ax1, y_data_new, y_pred_new, [0, 1], "OC-SVM Unsupervised Confusion Matrix")


# Semi-Supervised OC-SVM
x_data_train = pd.read_csv("X_data_train.csv")
x_np = x_data_train.to_numpy()

outliers_fraction = 0.80
svm_obj_ss = svm.OneClassSVM(
    kernel='rbf',
    nu=outliers_fraction,
    gamma=10)
svm_obj_ss.fit(x_np)
y_pred_ss = svm_obj_ss.predict(x_data)

n_error_inliers = y_pred_ss[y_pred_ss == 1].size
print(n_error_inliers)
n_error_outliers = y_pred_ss[y_pred_ss == -1].size
print(n_error_outliers)
# 47 Total Flights, OC-SVM Detected 2 as Abnormal and 45 as Normal.
acc = get_accuracy(y_data, y_pred_ss, y_data.size)
print(acc*100)
# Remap the classes
y_data_new = np.where(np.array(y_data) == -1, 0, 1)
y_pred_new_ss = np.where(np.array(y_pred_ss) == -1, 0, 1)
fig2, ax2 = plt.subplots()
plot_cm(ax2, y_data_new, y_pred_new_ss, [0, 1], "OC-SVM Semi-Supervised Confusion Matrix")

# Run Other UAV Data (All Successful Flights)
x_data_val = pd.read_csv("X_data_Val.csv")
print(x_data_val.shape)
# Run this data on both the unsupervised and semi-supervised models we trained
y_pred_val_un = svm_obj.predict(x_data_val.to_numpy())
y_pred_val_ss = svm_obj_ss.predict(x_data_val.to_numpy())

print(y_pred_val_un)
print(y_pred_val_ss)

n_error_inliers = y_pred_val_un[y_pred_val_un == 1].size
n_error_outliers = y_pred_val_un[y_pred_val_un == -1].size
print("Unsupervised")
print(n_error_inliers)
print(n_error_outliers)

n_error_inliers = y_pred_val_ss[y_pred_val_ss == 1].size
print("Semi-Supervised")
print(n_error_inliers)
n_error_outliers = y_pred_val_ss[y_pred_val_ss == -1].size
print(n_error_outliers)

# Now for the last one
# Run Other UAV Data (All Successful Flights)
x_data_val2 = pd.read_csv("X_data_Val2.csv")
# Run this data on both the unsupervised and semi-supervised models we trained
y_pred_val2_un = svm_obj.predict(x_data_val2.to_numpy())
y_pred_val2_ss = svm_obj_ss.predict(x_data_val2.to_numpy())
print(y_pred_val2_un)
print(y_pred_val2_ss)


n_error_inliers = y_pred_val2_un[y_pred_val2_un == 1].size
n_error_outliers = y_pred_val2_un[y_pred_val2_un == -1].size
print("Unsupervised")
print(n_error_inliers)
print(n_error_outliers)

n_error_inliers = y_pred_val2_ss[y_pred_val2_ss == 1].size
print("Semi-Supervised")
print(n_error_inliers)
n_error_outliers = y_pred_val2_ss[y_pred_val2_ss == -1].size
print(n_error_outliers)

