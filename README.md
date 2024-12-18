# Project Goal
Using the sashelp.heart dataset (results from the Framingham Heart Study) to perform 5-fold cross validation and compare the selected model to the full model.

# Parameters Used
Response Variable(s): Systolic (Systolic Blodd Pressure).
Predictor Variables: Height, Weight and Cholesterol.

# Models Created
Full Model: Regression model created using ALL instances.
Cross-Validation Models: 5 Regression models created using 4-folds (80% of dataset) and tested on the validation fold (20% holdout set).

# Results
The accuracy of the model created using the entire training set is identical to the accuracy of model 2 created using 4/5 of the training set. While cross validation has not improved the predictive accuracy of a candidate model, it has managed to produce a model using a lower amount of training instances.
