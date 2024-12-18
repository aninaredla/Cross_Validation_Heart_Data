proc import out=work.heart_copy
            datafile="/home/u63898787/Data/sashelp_heart.xlsx"
            dbms=xlsx
            replace;
    getnames=yes;
run;

proc surveyselect data=heart_copy out=heart_split
    method=srs
    samprate=0.7
    seed=3858
    outall;
run;

data training validation;
    set heart_split;
    if Selected then output training;
    else output validation;
run;

proc freq data=heart_split;
    tables Selected;
run;



/* PART 2: model Using training set */

proc reg data=training;
    model systolic = height weight cholesterol / vif;
    output out=reg_out p=Predicted r=Residual student=StudentRes cookd=CookD;
run;



/* Splitting training set into 5 folds */
data training_folds;
    set training;
    FoldID = mod(_N_, 5) + 1; /* Assign fold numbers 1 to 5 */
run;

/* Checking Fold Distribution */
proc freq data=training_folds;
    tables FoldID;
run;

/* training and test sets for fold 1 */
data train_fold valid_fold;
    set training_folds;
    if FoldID = 2 then output valid_fold; /* Validation set */
    else output train_fold;               /* Training set */
run;

/* training model from part 2 */
proc reg data=training outest=model_params noprint;
    model systolic = height weight cholesterol / vif;
    output out=reg_out_fold p=Predicted r=Residual; /* Predictions for train_fold */
run;

/* calculating model predictions using validation set created in part 1 */
proc score data=validation score=model_params out=predictions_valid_fold type=parms;
    var height weight cholesterol;
run;

/* calculating root mean squared residual */
data valid_fold_errors;
    set predictions_valid_fold;
    Residual = Systolic - MODEL1; /* Actual - Predicted */
    SquaredError = Residual**2;     /* Square of residual */
run;

proc means data=valid_fold_errors mean noprint;
    var SquaredError;
    output out=rmse_results mean=MeanSquaredError; /* calculating MSE */
run;

data rmse_final;
    set rmse_results;
    RMSE = sqrt(MeanSquaredError); /* Calculate RMSE */
run;

/* final output for rmse */ 
proc print data=rmse_final noobs;
    title "Root Mean Squared Error (RMSE)";
run;

/* E N D  M O D E L  1 */


/* S T A R T  M O D E L  2 */
/* training and test sets for fold 2 */
data train_fold2 valid_fold2;
    set training_folds;
    if FoldID = 2 then output valid_fold2; /* Validation set */
    else output train_fold2;               /* Training set */
run;

/* CV model 2: trained on folds 1, 3, 4, 5 */
proc reg data=train_fold2 outest=model_params2 noprint;
    model systolic = height weight cholesterol / vif;
    output out=reg_out_fold2 p=Predicted r=Residual; /* Predictions for train_fold1 */
run;

/* calculating model 2 predictions using fold 2 */
proc score data=valid_fold2 score=model_params2 out=predictions_valid_fold2 type=parms;
    var height weight cholesterol;
run;

/* calculating squared residual for model 2 */
data valid_fold2_errors;
    set predictions_valid_fold2;
    Residual = Systolic - MODEL1; /* Actual - Predicted */
    SquaredError = Residual**2;     /* Square of residual */
run;

/* calculating mean squared residual */
proc means data=valid_fold2_errors mean noprint;
    var SquaredError;
    output out=rmse_results mean=MeanSquaredError;
run;

/* calculating root mean squared residual for model 2 */
data rmse_final;
    set rmse_results;
    RMSE = sqrt(MeanSquaredError); /* Calculate RMSE */
run;

/* final output for rmse for model 2 */ 
proc print data=rmse_final noobs;
    title "Root Mean Squared Error (RMSE) for Fold 1 Validation Set";
run;
